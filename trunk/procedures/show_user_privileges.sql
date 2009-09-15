#######################################################################################
##                                                                                   ##
##   This is show_user_privileges, a script used to find out the list of privileges ##
##   a user has on a database for a particular role or all roles.                    ##
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

USE securich;

DROP PROCEDURE IF EXISTS show_user_privileges;

DELIMITER $$

CREATE PROCEDURE `securich`.`show_user_privileges`( usernamein char(16), hostnamein varchar(60), dbnamein varchar(64), rolein varchar(64))
  BEGIN

    DECLARE roleexists int;

	  SET roleexists = (
	     select count(*)
	     from sec_roles as r join (
	        select ID
	        from sec_us_ho_db_tb a
	        where a.US_ID=(
	           select ID
	           from sec_users
	           where USERNAME=usernamein
	           )
	        and a.HO_ID=(
	           select ID
	           from sec_hosts
	           where HOSTNAME=hostnamein
	           )
	        and a.DB_ID=(
	           select ID
	           from sec_databases
	           where DATABASENAME=dbnamein
	           )
	        ) ids join sec_us_ho_db_tb_ro as uhdr
	     where r.ID=uhdr.RO_ID and
	     ids.ID=uhdr.US_HO_DB_TB_ID
	     and r.ROLE=rolein
	     );


	  IF rolein = 'ALL' THEN
	  select distinct PRIVILEGE
	  from  sec_privileges inner join (
	     select PR_ID from sec_ro_pr
	     where RO_ID in (
	        select distinct r.ID
	        from sec_roles as r join (
	           select ID
	           from sec_us_ho_db_tb a
	           where a.US_ID=(
	              select ID
	              from sec_users
	              where USERNAME=usernamein
	              )
	           and a.HO_ID=(
	              select ID
	              from sec_hosts
	              where HOSTNAME=hostnamein
	              )
	           and a.DB_ID=(
	              select ID
	              from sec_databases
	              where DATABASENAME=dbnamein
	              )
	           ) ids join sec_us_ho_db_tb_ro as uhdr
	        where r.ID=uhdr.RO_ID and
	        ids.ID=uhdr.US_HO_DB_TB_ID
	        )
	     ) IDS
	  where sec_privileges.ID=IDS.PR_ID
	  order by 1 asc;

    ELSE
	    IF roleexists = '0' THEN
	    select "ROLE DOES NOT EXIST FOR THIS USER";
	    select "Please check the role name and retry";

	    ELSE

        select distinct PRIVILEGE
        from  sec_privileges inner join (
           select PR_ID
           from sec_ro_pr
           where RO_ID in (
              select distinct r.ID
              from sec_roles as r join (
                 select ID
                 from sec_us_ho_db_tb a
                 where a.US_ID=(
                    select ID
                    from sec_users
                    where USERNAME=usernamein
                    )
                 and a.HO_ID=(
                    select ID
                    from sec_hosts
                    where HOSTNAME=hostnamein
                    )
                 and a.DB_ID=(
                    select ID
                    from sec_databases
                    where DATABASENAME=dbnamein
                    )
                 ) ids join sec_us_ho_db_tb_ro as uhdr
              where r.ID=uhdr.RO_ID and
              ids.ID=uhdr.US_HO_DB_TB_ID
              and r.ROLE=rolein
              )
           ) prids
        where sec_privileges.ID=prids.PR_ID
        order by 1 asc;

        END IF;

    END IF;

  END$$

DELIMITER ;