#######################################################################################
##                                                                                   ##
##   This is clone_user, a script used to clone a particular user from another.      ##
##                                                                                   ##
##   This program was written by Darren Cassar 2009.                                 ##
##   Feedback and improvements are welcome at:                                       ##
##   info [at] securich.com / info [at] mysqlpreacher.com                            ##
##                                                                                   ##
##   THIS PROGRAM IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED             ##
##   WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF            ##
##   MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.                           ##
##                                                                                   ##
##   This program is free software; you can redistribute it and/or modify it under   ##
##   the terms of the GNU General Public License as published by the Free Software   ##
##   Foundation, version 2.                                                          ##
##                                                                                   ##
##   You should have received a copy of the GNU General Public License along with    ##
##   this program; if not, write to the Free Software Foundation, Inc., 59 Temple    ##
##   Place, Suite 330, Boston, MA  02111-1307  USA.                                  ##
##                                                                                   ##
#######################################################################################

USE securich;

DROP PROCEDURE IF EXISTS clone_user;

DELIMITER $$


CREATE PROCEDURE `securich`.`clone_user`( usernamein varchar(16), hostnamein varchar(60), newusernamein varchar(16), newhostnamein varchar(60), emailaddressin varchar(50))
  BEGIN

      DECLARE userexists int;
      DECLARE hostexists int;
      DECLARE newuserexists int;
      DECLARE newhostexists int;

      DECLARE usidvalue int;
      DECLARE hoidvalue int;
      DECLARE ushoidvalue int;
      DECLARE newusidvalue int;
      DECLARE newhoidvalue int;
      DECLARE newushoidvalue int;

      DECLARE randomnumber int;
      DECLARE randompassword char(15);
      DECLARE randompasswordvalue char(41);
      DECLARE sourcereservedusername int;
      DECLARE destinationreservedusername int;

                      /* Security feature does not permit an empty user / root user being granted through this package! */

      SET sourcereservedusername = (
         select count(*)
         from sec_reserved_usernames
         where USERNAME=usernamein
         );

      SET destinationreservedusername = (
         select count(*)
         from sec_reserved_usernames
         where USERNAME=newusernamein
         );

      IF sourcereservedusername > 0 THEN

         select "Illegal source username";

      ELSEIF destinationreservedusername > 0 THEN

         select "Illegal destination username";

      ELSEIF hostnamein = '' OR newhostnamein = ''  THEN

         select "Illegal hostname entry";

      ELSE

         SET userexists = (
            select count(*)
            from sec_users
            where USERNAME=usernamein
            );

         SET hostexists = (
            select count(*)
            from sec_hosts
            where HOSTNAME=hostnamein
            );

         SET newuserexists = (
            select count(*)
            from sec_users
            where USERNAME=newusernamein
            );

         SET newhostexists = (
            select count(*)
            from sec_hosts
            where HOSTNAME=newhostnamein
            );

         SET usidvalue = (select ID from sec_users where USERNAME=usernamein);
         SET hoidvalue = (select ID from sec_hosts where HOSTNAME=hostnamein);

         IF userexists < 1 THEN
            select "Source username does not exist";
         ELSEIF hostexists < 1 THEN
            select "Source hostname does not exist";
         ELSEIF (select count(*) from sec_us_ho where US_ID=usidvalue and HO_ID=hoidvalue) < 1 THEN
            select "Source username at Source hostname combination do not exist. Please recheck users using check_user_list() or check_user_entries('username')";
         ELSE
            IF newuserexists < 1 THEN
               insert into sec_users (USERNAME,EMAIL_ADDRESS) values (newusernamein,emailaddressin);
            END IF;

            IF newhostexists < 1 THEN
               insert into sec_hosts (HOSTNAME) values (newhostnamein);
            END IF;

            SET newusidvalue = (select ID from sec_users where USERNAME=newusernamein);
            SET newhoidvalue = (select ID from sec_hosts where HOSTNAME=newhostnamein);

            IF (select count(*) from sec_us_ho where US_ID=newusidvalue and HO_ID=newhoidvalue) > 0 THEN

               select "Illegal operation - User you are trying to clone out already exists! issue a `call check_user_entries(USERNAME);` for further details.";

            ELSE

               SET randomnumber = 0;

               WHILE randomnumber < 12 OR randomnumber > 20 DO
                  SET randomnumber=(select round(rand()*100));
               END WHILE;


               SET randompassword = (select substring(md5(rand()) from 1 for randomnumber));

               SET @c = CONCAT('create user "' , newusernamein , '"@"' , newhostnamein , '" identified by "' , randompassword , '"');

               PREPARE createcom FROM @c;
               EXECUTE createcom;

                   /* insert a record of the user entity (username@host) in sec_us_ho */

               insert into sec_us_ho (US_ID,HO_ID) values (newusidvalue, newhoidvalue);

               SET ushoidvalue = (select ID from sec_us_ho where US_ID=newusidvalue and HO_ID=newhoidvalue);

               SET randompasswordvalue= (select password(randompassword));

                   /* store an entry for a particular user entity (username@host) in sec_us_ho_profile which holds password history, creation history, last update history, password change count etc */

               insert into sec_us_ho_profile (US_HO_ID,PW0,CREATE_TIMESTAMP,UPDATE_TIMESTAMP,TYPE) values (ushoidvalue,randompasswordvalue,now(),now(),'USER');

               SET @randomp = CONCAT('select "Password for user -- ' , newusernamein , ' -- contactable at -- ' , emailaddressin , ' -- is -- ' , randompassword , ' --" as USER_PASSWORD');

               PREPARE randompasswordcom FROM @randomp;
               EXECUTE randompasswordcom;

               FLUSH PRIVILEGES;

               insert into sec_us_ho_db_tb (US_ID,HO_ID,DB_ID,TB_ID,STATE)
                  select us.ID, ho.ID, uhdt.DB_ID, uhdt.TB_ID, uhdt.STATE
                  from sec_us_ho_db_tb uhdt, sec_users us, sec_hosts ho
                  where uhdt.US_ID=usidvalue
                  and uhdt.HO_ID=hoidvalue
                  and us.ID=newusidvalue
                  and ho.ID=newhoidvalue;

               insert into sec_us_ho_db_sp (US_ID,HO_ID,DB_ID,SP_ID,STATE)
                  select us.ID, ho.ID, uhds.DB_ID, uhds.SP_ID, uhds.STATE
                  from sec_us_ho_db_sp uhds, sec_users us, sec_hosts ho
                  where uhds.US_ID=usidvalue
                  and uhds.HO_ID=hoidvalue
                  and us.ID=newusidvalue
                  and ho.ID=newhoidvalue;

               drop table if exists tempt2;
               create temporary table if not exists tempt2(ID int, US_ID int, HO_ID int, DB_ID int, TB_ID int, RO_ID int);
               insert into tempt2
                  select uhdt.ID, uhdt.US_ID,uhdt.HO_ID,uhdt.DB_ID,uhdt.TB_ID,uhdtr.RO_ID
                  from sec_us_ho_db_tb uhdt, sec_us_ho_db_tb_ro uhdtr
                  where uhdt.US_ID=usidvalue
                  and uhdt.HO_ID=hoidvalue
                  and uhdt.STATE <> 'R'
                  and uhdtr.US_HO_DB_TB_ID=uhdt.ID;

               drop table if exists tempt3;
               create temporary table if not exists tempt3(ID int, US_ID int, HO_ID int, DB_ID int, TB_ID int);
               insert into tempt3
                  select uhdt.ID, uhdt.US_ID,uhdt.HO_ID,uhdt.DB_ID,uhdt.TB_ID
                  from sec_us_ho_db_tb uhdt, sec_us_ho_db_tb_ro uhdtr
                  where uhdt.US_ID=newusidvalue
                  and uhdt.HO_ID=newhoidvalue
                  and uhdt.STATE <> 'R'
                  and uhdt.ID not in (select US_HO_DB_TB_ID from sec_us_ho_db_tb_ro) group by ID;

               insert into sec_us_ho_db_tb_ro (US_HO_DB_TB_ID,RO_ID)
                  select tempt3.ID, tempt2.RO_ID
                  from tempt3, tempt2
                  where tempt3.DB_ID = tempt2.DB_ID
                  and tempt3.TB_ID = tempt2.TB_ID;


               drop table if exists tempt2;
               create temporary table if not exists tempt2(ID int, US_ID int, HO_ID int, DB_ID int, SP_ID int, RO_ID int);
               insert into tempt2
                  select uhds.ID, uhds.US_ID,uhds.HO_ID,uhds.DB_ID,uhds.SP_ID,uhdsr.RO_ID
                  from sec_us_ho_db_sp uhds, sec_us_ho_db_sp_ro uhdsr
                  where uhds.US_ID=usidvalue
                  and uhds.HO_ID=hoidvalue
                  and uhds.STATE <> 'R'
                  and uhdsr.US_HO_DB_SP_ID=uhds.ID;

               drop table if exists tempt3;
               create temporary table if not exists tempt3(ID int, US_ID int, HO_ID int, DB_ID int, SP_ID int);
               insert into tempt3
                  select uhds.ID, uhds.US_ID,uhds.HO_ID,uhds.DB_ID,uhds.SP_ID
                  from sec_us_ho_db_sp uhds, sec_us_ho_db_sp_ro uhdsr
                  where uhds.US_ID=newusidvalue
                  and uhds.HO_ID=newhoidvalue
                  and uhds.STATE <> 'R'
                  and uhds.ID not in (select US_HO_DB_SP_ID from sec_us_ho_db_sp_ro) group by ID;

               insert into sec_us_ho_db_sp_ro (US_HO_DB_SP_ID,RO_ID)
                  select tempt3.ID, tempt2.RO_ID
                  from tempt3, tempt2
                  where tempt3.DB_ID = tempt2.DB_ID
                  and tempt3.SP_ID = tempt2.SP_ID;

               call reconciliation('sync');

            END IF;

         END IF;

      END IF;

END$$

DELIMITER ;