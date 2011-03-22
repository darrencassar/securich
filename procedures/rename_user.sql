#######################################################################################
##                                                                                   ##
##   This is rename_user, a script used to rename a particular user.                 ##
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

DROP PROCEDURE IF EXISTS rename_user;

DELIMITER $$


CREATE PROCEDURE `securich`.`rename_user`( usernamein varchar(16), newusernamein varchar(16), newemailaddressin varchar(50))
  BEGIN

      DECLARE userexists int;
      DECLARE newuserexists int;
      DECLARE usernameincount int;
      DECLARE newusernameincount int;

      DECLARE randomnumber int;
      DECLARE randompassword char(15);
      DECLARE randompasswordvalue char(41);

      DECLARE hostname VARCHAR(60);

      DECLARE done INT DEFAULT 0;

                       /* list of privileges a particular user entity (username@hostname) will be granted on a particular combination of database and tables */

      DECLARE cur_host CURSOR FOR
	       select distinct ho.HOSTNAME
	       from  sec_hosts ho join sec_us_ho usho join sec_users us
	       where ho.id=usho.HO_ID and
	       usho.US_ID=us.ID and
	       us.USERNAME=newusernamein;


      DECLARE CONTINUE HANDLER FOR not found SET done = 1;

/*      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         SELECT 'Error occurred - terminating - USER CREATION AND / OR PRIVILEGES GRANT FAILED';
      END; 
*/
      FLUSH PRIVILEGES;
                      /* Security feature does not permit an empty user / root user being granted through this package! */

      SET usernameincount = (select count(*) from sec_reserved_usernames where USERNAME=usernamein);
      SET newusernameincount = (select count(*) from sec_reserved_usernames where USERNAME=newusernamein);
      
      IF usernameincount > 0 THEN

         select "Illegal username entry - username is reserved." as ERROR;

      ELSEIF newusernameincount > 0 THEN

         select "Illegal new username entry - username is reserved." as ERROR;

      ELSE

         SET userexists = (
            select count(*)
            from sec_users
            where USERNAME=usernamein
            );

         SET newuserexists = (
            select count(*)
            from sec_users
            where USERNAME=newusernamein
            );

         IF userexists < 1 THEN
            select "Source username does not exist" as ERROR;
         ELSEIF newuserexists > 0 THEN
            select "Destination username already exists" as ERROR;
         ELSE
            update sec_users set USERNAME=newusernamein, EMAIL_ADDRESS=newemailaddressin where USERNAME=usernamein;

            SET randomnumber = 0;

            WHILE randomnumber < 12 OR randomnumber > 20 DO
               SET randomnumber=(select round(rand()*100));
            END WHILE;

            SET randompassword = (select substring(md5(rand()) from 1 for randomnumber));

            OPEN cur_host;

            cur_host_loop:WHILE(done=0) DO

            FETCH cur_host INTO hostname;

                /* once done, just leave the loop */

            IF done=1 THEN

               LEAVE cur_host_loop;
            END IF;
            
            call reconciliation('securichsync');

            call set_password(newusernamein,hostname,'xxx',randompassword);

            END WHILE cur_host_loop;
            CLOSE cur_host;

            SET @randomp = CONCAT('select "Password for user -- ' , newusernamein , ' -- contactable at -- ' , newemailaddressin , ' -- is -- ' , randompassword , ' --" as USER_PASSWORD');

            PREPARE randompasswordcom FROM @randomp;
            EXECUTE randompasswordcom;

         END IF;

      END IF;

END$$

DELIMITER ;
