#######################################################################################
##                                                                                   ##
##   This is update_databases_tables_storedprocedures_list, a script used to update  ##
##   the securich db tables with new database names, tables, stored procedures etc.  ##
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

DROP PROCEDURE IF EXISTS update_databases_tables_storedprocedures_list;

DELIMITER $$

CREATE PROCEDURE `securich`.`update_databases_tables_storedprocedures_list`()
  BEGIN

  
     DROP TABLE IF EXISTS updtdbnames;  
     CREATE TEMPORARY TABLE updtdbnames 
     ( 
      DB VARCHAR(50)
     ) ENGINE=MYISAM; 

     insert into updtdbnames select distinct(db) from mysql.db;
     insert into updtdbnames select distinct(db) from mysql.tables_priv;
     insert into updtdbnames select distinct(db) from mysql.procs_priv;
     insert into updtdbnames select distinct(SCHEMA_NAME) from information_schema.SCHEMATA where SCHEMA_NAME != 'information_schema';                                  
              
     insert into securich.sec_databases (DATABASENAME)
        select distinct(db)
        from updtdbnames
        where db not in (
           select DATABASENAME
           from securich.sec_databases
           );

     insert into securich.sec_tables (TABLENAME)
        select distinct TABLE_NAME
        from information_schema.tables
        where table_schema <> 'information_schema' and
        TABLE_NAME not in (
           select TABLENAME
           from securich.sec_tables
           );

     insert into securich.sec_storedprocedures (STOREDPROCEDURENAME)
        select distinct SPECIFIC_NAME
        from information_schema.routines
        where ROUTINE_SCHEMA <> 'information_schema' and
        SPECIFIC_NAME not in (
           select STOREDPROCEDURENAME
           from securich.sec_storedprocedures
           );

     insert into sec_db_tb (DB_ID,TB_ID)
        select DB_ID,TB_ID
        from
        (
           select db.ID as DB_ID, tb.ID as TB_ID
           from sec_databases db, sec_tables tb join (
              select TABLE_SCHEMA, TABLE_NAME
              from information_schema.tables
              where table_schema <> 'information_schema' 
              ) nms
           where nms.TABLE_SCHEMA = db.DATABASENAME and
           nms.TABLE_NAME = tb.TABLENAME
           UNION ALL
           select DB_ID,TB_ID
           from sec_db_tb
        ) tmp
        group by DB_ID, TB_ID
        having count(*) = 1 ;

     insert into sec_db_sp (DB_ID,SP_ID)
        select DB_ID,SP_ID
        from
        (
           select db.ID as DB_ID, sp.ID as SP_ID
           from sec_databases db, sec_storedprocedures sp join (
              select ROUTINE_SCHEMA, SPECIFIC_NAME
              from information_schema.routines
              where ROUTINE_SCHEMA <> 'information_schema' 
              ) nms
           where nms.ROUTINE_SCHEMA = db.DATABASENAME and
           nms.SPECIFIC_NAME = sp.STOREDPROCEDURENAME
           UNION ALL
           select DB_ID,SP_ID
           from sec_db_sp
        ) tmp
        group by DB_ID, SP_ID
        having count(*) = 1 ;

     insert into sec_db_tb (DB_ID,TB_ID)
        select ID, 1
        from sec_databases d
        where d.ID not in (
           select DB_ID
           from sec_db_tb
           where TB_ID='1'
           );

  END$$

DELIMITER ;
