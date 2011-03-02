#######################################################################################
##                                                                                   ##
##   This is block_user, a script used to revoke roles from combinations of user,    ##
##   database, host.                                                                 ##
##                                                                                   ##
##   This program was originally sponsored by TradingScreen Inc                      ##
##   Information about TS is found at www.tradingscreen.com                          ##
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

use securich;

DROP PROCEDURE IF EXISTS block_user;

DELIMITER $$

CREATE PROCEDURE `securich`.`block_user`( usernamein varchar(16), hostnamein varchar(60), dbnamein varchar(64), terminateconnections char(1))
  BEGIN

    DECLARE userexists int;
    DECLARE remid int;
    DECLARE ushodbtbid int;
    DECLARE usidvalue int;
    DECLARE hoidvalue int;
    DECLARE dbidvalue int;
    DECLARE ushoidvalue int;


    FLUSH PRIVILEGES;
    call update_databases_tables_storedprocedures_list();

    SET userexists = (
       select count(*)
       from sec_us_ho usho join (
          select ID
          from sec_users
          where USERNAME=usernamein
          ) us join (
          select ID
          from sec_hosts
          where HOSTNAME=hostnamein
          ) ho
       where us.ID=usho.US_ID and
       ho.ID=usho.HO_ID
       );


    IF ( select count(*) from sec_users where USERNAME=usernamein) = 0 THEN

       select "Username supplied is incorrect or does not exist";

    ELSEIF (select count(*) from sec_hosts where HOSTNAME=hostnamein) = 0 THEN

       select "Hostname supplied is incorrect or does not exist";

    ELSEIF userexists = 0 THEN

       select "USER DOES NOT EXIST";

    ELSEIF (select count(*) from sec_databases where DATABASENAME=dbnamein) = 0 THEN

       select "Database supplied is incorrect";

    ELSE

       SET usidvalue = (select ID from sec_users where USERNAME=usernamein);
       SET hoidvalue = (select ID from sec_hosts where HOSTNAME=hostnamein);
       SET dbidvalue = (select ID from sec_databases where DATABASENAME=dbnamein);
       SET ushoidvalue = (select ID from sec_us_ho where US_ID=usidvalue and HO_ID=hoidvalue );

       update sec_us_ho_db_tb set STATE='B' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue;
       update sec_us_ho_db_tb_ro inner join (select ID from sec_us_ho_db_tb where STATE='B') removed set STATE='B' where sec_us_ho_db_tb_ro.US_HO_DB_TB_ID = removed.ID;
       update sec_us_ho_db_sp set STATE='B' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue;
       update sec_us_ho_db_sp_ro inner join (select ID from sec_us_ho_db_sp where STATE='B') removed set STATE='B' where sec_us_ho_db_sp_ro.US_HO_DB_SP_ID = removed.ID;


/*If the role revoked was the last role, thus user ended up without roles, then user is dropped*/
       call reconciliation('sync');


       IF terminateconnections = 'Y' or terminateconnections = 'y' THEN

          SET @CNT = (
             select count(*)
             from information_schema.processlist
             where USER=usernamein and
             ( HOST like CONCAT(hostnamein ,':%') or
               HOST like hostnamein ) limit 1
             );

          SET @VAR=1;

          WHILE ( @VAR <= @CNT) DO

              SET @TID = (
                 select id
                 from information_schema.processlist
                 where USER=usernamein and
                 ( HOST like CONCAT(hostnamein ,':%') or
                 HOST like hostnamein ) limit 1
                 );

              SET @k = CONCAT('kill ' , @TID);
              PREPARE killcom FROM @k;
              EXECUTE killcom;
              set @k=NULL;

              SET @VAR=@VAR+1;

          END WHILE;

       END IF;

    END IF;

    FLUSH PRIVILEGES;

END$$

DELIMITER ;
