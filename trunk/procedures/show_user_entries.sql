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

CREATE PROCEDURE `securich`.`show_user_entries`( usernamein VARCHAR(16))
  BEGIN

    IF (SELECT COUNT(*) FROM sec_users WHERE USERNAME=usernamein) = 0 THEN

       SELECT "USER SPECIFIED DOES NOT EXIST";

    ELSE

# Table section

       DROP TABLE IF EXISTS temp_tbl_2;
       CREATE TEMPORARY TABLE temp_tbl_2
       ( `ID` INT,
         `STATE` CHAR(1),
         `USERNAME` VARCHAR(16),
         `HOSTNAME` VARCHAR (60),
         `DATABASENAME` VARCHAR(64),
         `TABLENAME` VARCHAR(64),
         `TYPE` CHAR(2) DEFAULT 'TB'
       );

       INSERT INTO temp_tbl_2
       SELECT ids.ID, ids.STATE, sec_users.USERNAME, sec_hosts.HOSTNAME, sec_databases.DATABASENAME, sec_tables.TABLENAME, 'TB'
       FROM sec_users, sec_hosts, sec_databases, sec_tables
       JOIN (
          SELECT *
          FROM sec_us_ho_db_tb a
          WHERE a.US_ID=(
             SELECT ID
             FROM sec_users
             WHERE USERNAME=usernamein
             )
          ) ids
       WHERE sec_users.ID=ids.US_ID AND
       sec_hosts.ID=ids.HO_ID AND
       sec_databases.ID=ids.DB_ID AND
       sec_tables.ID=ids.TB_ID;

# Stored Procedure section

       DROP TABLE IF EXISTS temp_tbl_12;
       CREATE TEMPORARY TABLE temp_tbl_12
       ( `ID` INT,
         `STATE` CHAR(1),
         `USERNAME` VARCHAR(16),
         `HOSTNAME` VARCHAR (60),
         `DATABASENAME` VARCHAR(64),
         `STOREDPROCEDURENAME` VARCHAR(64),
         `TYPE` CHAR(2) DEFAULT 'SP'
       );

       INSERT INTO temp_tbl_12
       SELECT ids.ID, ids.STATE, sec_users.USERNAME, sec_hosts.HOSTNAME, sec_databases.DATABASENAME, sec_storedprocedures.STOREDPROCEDURENAME, 'SP'
       FROM sec_users, sec_hosts, sec_databases, sec_storedprocedures
       JOIN (
          SELECT *
          FROM sec_us_ho_db_sp a
          WHERE a.US_ID=(
             SELECT ID
             FROM sec_users
             WHERE USERNAME=usernamein
             )
          ) ids
       WHERE sec_users.ID=ids.US_ID AND
       sec_hosts.ID=ids.HO_ID AND
       sec_databases.ID=ids.DB_ID AND
       sec_storedprocedures.ID=ids.SP_ID;
       
       
# Table section

       DROP TABLE IF EXISTS temp_tbl_1;
       CREATE TEMPORARY TABLE temp_tbl_1 (`ID` INT, `ROLE` VARCHAR(60));

       INSERT INTO temp_tbl_1
       SELECT DISTINCT  ro.ID, ro.ROLE
       FROM sec_roles ro JOIN sec_us_ho_db_tb_ro ushodbro JOIN (
          SELECT ushodbtb.ID
          FROM sec_us_ho_db_tb ushodbtb JOIN (
             SELECT ID
             FROM sec_users
             WHERE USERNAME=usernamein
             ) usid
          WHERE usid.ID=ushodbtb.US_ID
          ) rids
       WHERE rids.ID=ushodbro.US_HO_DB_TB_ID AND
       ushodbro.RO_ID=ro.ID;

# Stored Procedure section

       DROP TABLE IF EXISTS temp_tbl_11;
       CREATE TEMPORARY TABLE temp_tbl_11 (`ID` INT, `ROLE` VARCHAR(60));

       INSERT INTO temp_tbl_11
       SELECT DISTINCT  ro.ID, ro.ROLE
       FROM sec_roles ro JOIN sec_us_ho_db_sp_ro ushodbro JOIN (
          SELECT ushodbsp.ID
          FROM sec_us_ho_db_sp ushodbsp JOIN (
             SELECT ID
             FROM sec_users
             WHERE USERNAME=usernamein
             ) usid
          WHERE usid.ID=ushodbsp.US_ID
          ) rids
       WHERE rids.ID=ushodbro.US_HO_DB_SP_ID AND
       ushodbro.RO_ID=ro.ID;

       
# Table section
       
       DROP TABLE IF EXISTS temp_tbl_3;
       CREATE TEMPORARY TABLE temp_tbl_3
       (  `RO_ID` INT,
          `US_HO_DB_TB_ID` INT
       );       
       
# Stored Procedure section
       
       DROP TABLE IF EXISTS temp_tbl_13;
       CREATE TEMPORARY TABLE temp_tbl_13
       (  `RO_ID` INT,
          `US_HO_DB_SP_ID` INT
       );

       INSERT INTO temp_tbl_3
       SELECT DISTINCT c.RO_ID AS roid, c.US_HO_DB_TB_ID AS ushodbid
       FROM sec_us_ho_db_tb_ro c JOIN temp_tbl_2 d
       WHERE c.US_HO_DB_TB_ID=d.ID;
       
       INSERT INTO temp_tbl_13
       SELECT DISTINCT c.RO_ID AS roid, c.US_HO_DB_SP_ID AS ushodbid
       FROM sec_us_ho_db_sp_ro c JOIN temp_tbl_12 d
       WHERE c.US_HO_DB_SP_ID=d.ID;


# Combine both results into one table for show

       DROP TABLE IF EXISTS temp_tbl_4;
       CREATE TEMPORARY TABLE temp_tbl_4
       ( 
         `USERNAME` VARCHAR(16),
         `HOSTNAME` VARCHAR (60),
         `DATABASENAME` VARCHAR(64),
         `OBJECT` VARCHAR(64),
         `ROLE` VARCHAR(65),
         `TYPE` CHAR(2),
         `STATE` CHAR(1)         
       );
       
       
       INSERT INTO temp_tbl_4 SELECT b.USERNAME, b.HOSTNAME, b.DATABASENAME, b.TABLENAME, a.ROLE, b.TYPE, b.STATE
       FROM temp_tbl_2 b, temp_tbl_1 a JOIN temp_tbl_3 c
       WHERE b.ID=c.US_HO_DB_TB_ID AND
       a.ID=c.RO_ID
       GROUP BY USERNAME, HOSTNAME, DATABASENAME, TABLENAME, ROLE, STATE;
       
       INSERT INTO temp_tbl_4 SELECT b.USERNAME, b.HOSTNAME, b.DATABASENAME, b.STOREDPROCEDURENAME, a.ROLE, b.TYPE, b.STATE
       FROM temp_tbl_12 b, temp_tbl_11 a JOIN temp_tbl_13 c
       WHERE b.ID=c.US_HO_DB_SP_ID AND
       a.ID=c.RO_ID
       GROUP BY USERNAME, HOSTNAME, DATABASENAME, STOREDPROCEDURENAME, ROLE, STATE;
       
       SELECT * FROM temp_tbl_4;

    END IF;

  END$$

DELIMITER ;