#######################################################################################
##                                                                                   ##
##   This is show_user_entries, a script used to check the roles assigned to a       ##
##   particular user on which database and from which host.                          ##
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

DROP PROCEDURE IF EXISTS show_user_entries;

DELIMITER $$

CREATE PROCEDURE `securich`.`show_user_entries`( usernamein varchar(16))
  BEGIN

    IF (select count(*) from sec_users where USERNAME=usernamein) = 0 THEN

       select "USER SPECIFIED DOES NOT EXIST";

    ELSE

       drop table if exists temp_tbl_2;
       create temporary table temp_tbl_2
       ( `ID` int,
         `STATE` char(1),
         `USERNAME` varchar(16),
         `HOSTNAME` varchar (60),
         `DATABASENAME` varchar(64),
         `TABLENAME` varchar(64)
       );

       insert into temp_tbl_2
       select ids.ID, ids.STATE, sec_users.USERNAME, sec_hosts.HOSTNAME, sec_databases.DATABASENAME, sec_tables.TABLENAME
       from sec_users, sec_hosts, sec_databases, sec_tables
       join (
          select *
          from sec_us_ho_db_tb a
          where a.US_ID=(
             select ID
             from sec_users
             where USERNAME=usernamein
             )
          ) ids
       where sec_users.ID=ids.US_ID and
       sec_hosts.ID=ids.HO_ID and
       sec_databases.ID=ids.DB_ID and
       sec_tables.ID=ids.TB_ID;

       insert into temp_tbl_2
       select ids.ID, ids.STATE, sec_users.USERNAME, sec_hosts.HOSTNAME, sec_databases.DATABASENAME, sec_storedprocedures.STOREDPROCEDURENAME
       from sec_users, sec_hosts, sec_databases, sec_storedprocedures
       join (
          select *
          from sec_us_ho_db_sp a
          where a.US_ID=(
             select ID
             from sec_users
             where USERNAME=usernamein
             )
          ) ids
       where sec_users.ID=ids.US_ID and
       sec_hosts.ID=ids.HO_ID and
       sec_databases.ID=ids.DB_ID and
       sec_storedprocedures.ID=ids.SP_ID;

       drop table if exists temp_tbl_1;
       create temporary table temp_tbl_1 (`ID` int, `ROLE` varchar(60));

       insert into temp_tbl_1
       select distinct  ro.ID, ro.ROLE
       from sec_roles ro join sec_us_ho_db_tb_ro ushodbro join (
          select ushodbtb.ID
          from sec_us_ho_db_tb ushodbtb join (
             select ID
             from sec_users
             where USERNAME=usernamein
             ) usid
          where usid.ID=ushodbtb.US_ID
          ) rids
       where rids.ID=ushodbro.US_HO_DB_TB_ID and
       ushodbro.RO_ID=ro.ID;

       insert into temp_tbl_1
       select distinct  ro.ID, ro.ROLE
       from sec_roles ro join sec_us_ho_db_sp_ro ushodbro join (
          select ushodbsp.ID
          from sec_us_ho_db_sp ushodbsp join (
             select ID
             from sec_users
             where USERNAME=usernamein
             ) usid
          where usid.ID=ushodbsp.US_ID
          ) rids
       where rids.ID=ushodbro.US_HO_DB_SP_ID and
       ushodbro.RO_ID=ro.ID;

       drop table if exists temp_tbl_3;
       create temporary table temp_tbl_3
       (  `RO_ID` int,
          `US_HO_DB_TB_ID` int
       );

       insert into temp_tbl_3
       select distinct c.RO_ID as roid, c.US_HO_DB_TB_ID as ushodbid
       from sec_us_ho_db_tb_ro c join temp_tbl_2 d
       where c.US_HO_DB_TB_ID=d.ID;
       
       insert into temp_tbl_3
       select distinct c.RO_ID as roid, c.US_HO_DB_SP_ID as ushodbid
       from sec_us_ho_db_sp_ro c join temp_tbl_2 d
       where c.US_HO_DB_SP_ID=d.ID;

       select b.USERNAME, b.HOSTNAME, b.DATABASENAME, b.TABLENAME, a.ROLE, b.STATE
       from temp_tbl_2 b, temp_tbl_1 a join temp_tbl_3 c
       where b.ID=c.US_HO_DB_TB_ID and
       a.ID=c.RO_ID
       GROUP BY USERNAME, HOSTNAME, DATABASENAME, TABLENAME, ROLE, STATE;

    END IF;

  END$$

DELIMITER ;