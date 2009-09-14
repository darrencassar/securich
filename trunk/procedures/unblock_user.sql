#######################################################################################
##                                                                                   ##
##   This is unblock_user, a script used to restore privileges to a user@host on a   ##
##   specific database.                                                              ##
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

DROP PROCEDURE IF EXISTS unblock_user;

DELIMITER $$

CREATE PROCEDURE `securich`.`unblock_user`( usernamein varchar(16), hostnamein varchar(60), dbnamein varchar(64))
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

       update sec_us_ho_db_tb set STATE='A' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue and STATE ='B';

       update sec_us_ho_db_tb_ro join (
          select ID
          from sec_us_ho_db_tb
          where US_ID=usidvalue and
          HO_ID=hoidvalue and
          DB_ID=dbidvalue
          ) ushodbtb
       set STATE='A'
       where US_HO_DB_TB_ID=ushodbtb.ID and STATE='B';

       update sec_us_ho_db_sp set STATE='A' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue and STATE ='B';

       update sec_us_ho_db_sp_ro join (
          select ID
          from sec_us_ho_db_sp
          where US_ID=usidvalue and
          HO_ID=hoidvalue and
          DB_ID=dbidvalue
          ) ushodbsp
       set STATE='A'
       where US_HO_DB_SP_ID=ushodbsp.ID and STATE='B';

/*If the role revoked was the last role, thus user ended up without roles, then user is dropped*/
       call reconciliation('sync');

    END IF;

    FLUSH PRIVILEGES;

END$$

DELIMITER ;