#######################################################################################
##                                                                                   ##
##   This is mysql_reconciliation, used to migrate MySQL user accounts to            ##
##   Securich.                                                                       ##
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

DROP PROCEDURE IF EXISTS mysql_reconciliation;

DELIMITER $$

CREATE PROCEDURE `mysql_reconciliation`(command_mysqlrecon VARCHAR(50))
BEGIN
      DECLARE dbnamein VARCHAR(60);
      DECLARE rowcount INT;
      DECLARE reservedusername VARCHAR(50);
      DECLARE usernameinathostnamein VARCHAR(76);
      DECLARE SYSTEMPARAM VARCHAR(10);
      DECLARE tableschema VARCHAR(60);
      DECLARE tablename VARCHAR(60);
      DECLARE role VARCHAR(60);
      DECLARE objecttype CHAR(1);
      DECLARE defobjecttype VARCHAR(20);
      DECLARE roletype INT;
      DECLARE privilegerole VARCHAR(60);
      DECLARE done INT DEFAULT 0;
      DECLARE dbdone INT DEFAULT 0;
 
      DECLARE cur_role CURSOR FOR
         SELECT DISTINCT(PRIVILEGE)
         FROM inf_grantee_privileges;
 
      DECLARE cur_user CURSOR FOR
         SELECT SYSTEM, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         FROM sec_two_grantee_privileges_reconcile;
 
      DECLARE cur_databases CURSOR FOR
         SELECT DISTINCT(db)
         FROM dbnames;
 
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
 
      UPDATE sec_config SET VALUE = '1' WHERE PROPERTY = 'mysql_to_securich_reconciliation_in_progress';
 
         FLUSH PRIVILEGES;
       
         DROP TABLE IF EXISTS dbnames;
         CREATE TEMPORARY TABLE dbnames 
         (
           DB VARCHAR(50)
         ) ENGINE=MYISAM; 
 
         INSERT INTO dbnames SELECT DISTINCT(db) FROM mysql.db;
         INSERT INTO dbnames SELECT DISTINCT(db) FROM mysql.tables_priv;
         INSERT INTO dbnames SELECT DISTINCT(db) FROM mysql.procs_priv;
         INSERT INTO dbnames SELECT DISTINCT(SCHEMA_NAME) FROM information_schema.SCHEMATA;
 
         DROP TABLE IF EXISTS inf_grantee_privileges;
         CREATE TEMPORARY TABLE inf_grantee_privileges
         (
           ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
           GRANTEE VARCHAR(81),
           TABLE_SCHEMA VARCHAR (64) DEFAULT NULL,
           TABLE_NAME VARCHAR (64) DEFAULT NULL,
           PRIVILEGE VARCHAR (30),
           TYPE CHAR(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 
         INSERT INTO inf_grantee_privileges  (GRANTEE,TABLE_SCHEMA,PRIVILEGE,TYPE) 
         SELECT GRANTEE,sch.SCHEMA_NAME,PRIVILEGE_TYPE,'t' 
         FROM information_schema.USER_PRIVILEGES JOIN information_schema.SCHEMATA sch
            WHERE grantee IN (
               SELECT DISTINCT(grantee) 
               FROM information_schema.user_privileges
            ) AND sch.SCHEMA_NAME != 'information_schema' ;
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA,PRIVILEGE,TYPE)
            SELECT GRANTEE, TABLE_SCHEMA, PRIVILEGE_TYPE,'t'
            FROM information_schema.SCHEMA_PRIVILEGES
               WHERE grantee IN (
                  SELECT DISTINCT(grantee)
                  FROM information_schema.user_privileges
               );
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA, TABLE_NAME,PRIVILEGE,TYPE)
            SELECT GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE,'t'
            FROM information_schema.TABLE_PRIVILEGES
               WHERE grantee IN (
                  SELECT DISTINCT(grantee)
                  FROM information_schema.user_privileges
               );
 
         DROP TABLE IF EXISTS temp_tbl_PROCS_PRIVILEGES;
         CREATE TEMPORARY TABLE temp_tbl_PROCS_PRIVILEGES (
            GRANTEE VARCHAR(81),
            TABLE_SCHEMA VARCHAR (64) DEFAULT NULL,
            TABLE_NAME VARCHAR (64) DEFAULT NULL,
            PRIVILEGE VARCHAR (30)
         ) ENGINE=MYISAM DEFAULT CHARSET=latin1;
 
         INSERT INTO temp_tbl_PROCS_PRIVILEGES
            SELECT CONCAT("'",USER,"'@'",HOST,"'"),Db,Routine_name,SUBSTRING_INDEX(Proc_priv,',',1)
            FROM mysql.procs_priv;
 
         INSERT INTO temp_tbl_PROCS_PRIVILEGES
            SELECT CONCAT("'",USER,"'@'",HOST,"'"),Db,Routine_name,SUBSTRING_INDEX(Proc_priv,',',-1)
            FROM mysql.procs_priv;
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA, TABLE_NAME,PRIVILEGE, TYPE)
            SELECT DISTINCT GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE,'s'
            FROM temp_tbl_PROCS_PRIVILEGES;
 
         DROP TABLE IF EXISTS sec_tmp_reserved_usernames;
         CREATE TEMPORARY TABLE sec_tmp_reserved_usernames
            (
              ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
              USERNAME VARCHAR(50) DEFAULT NULL,
              PRIMARY KEY (`ID`)
            ) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 
         INSERT INTO sec_tmp_reserved_usernames SELECT ID,USERNAME FROM sec_reserved_usernames;
         
         SET rowcount = (SELECT COUNT(*) FROM sec_tmp_reserved_usernames);
         REPEAT
 
            SET reservedusername = (SELECT USERNAME FROM sec_tmp_reserved_usernames LIMIT 1);
 
            SET @g = CONCAT('delete from inf_grantee_privileges where GRANTEE regexp "^\'', reservedusername ,'\'"');
 
            PREPARE deletecom FROM @g;
            EXECUTE deletecom;
 
            DELETE FROM sec_tmp_reserved_usernames WHERE USERNAME=reservedusername;
 
         UNTIL (SELECT COUNT(*) FROM sec_tmp_reserved_usernames) = 0
         END REPEAT;
 
         DELETE
         FROM inf_grantee_privileges
         WHERE GRANTEE LIKE '%\'\'%';
 
         DELETE
         FROM inf_grantee_privileges
         WHERE PRIVILEGE='USAGE';
 
         UPDATE 
            inf_grantee_privileges grpr 
            JOIN
            sec_privileges pr 
            ON grpr.PRIVILEGE = pr.PRIVILEGE 
         SET
            TABLE_NAME = NULL 
         WHERE pr.TYPE = '2' 
            OR TABLE_NAME = '' ;
                    
         UPDATE 
            inf_grantee_privileges grpr 
            JOIN
            sec_privileges pr 
            ON grpr.PRIVILEGE = pr.PRIVILEGE 
         SET
            TABLE_NAME = NULL 
         WHERE (pr.TYPE = '1' 
               OR TABLE_NAME = '') 
            AND grpr.TYPE = 't' ;
                    
         UPDATE 
            inf_grantee_privileges grpr 
            JOIN
            sec_privileges pr 
            ON grpr.PRIVILEGE = pr.PRIVILEGE 
         SET
            TABLE_SCHEMA = NULL,
            TABLE_NAME = NULL 
         WHERE pr.TYPE = '3' 
            OR TABLE_SCHEMA = '*' ;

         DROP TABLE IF EXISTS sec_two_grantee_privileges;
         CREATE TEMPORARY TABLE sec_two_grantee_privileges
         (
           ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
           GRANTEE VARCHAR(81),
           TABLE_SCHEMA VARCHAR (64) DEFAULT NULL,
           TABLE_NAME VARCHAR(64) DEFAULT NULL,
           PRIVILEGE VARCHAR (30),
           TYPE CHAR(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 
         DROP TABLE IF EXISTS sec_two_grantee_privileges_reconcile;
         CREATE TEMPORARY TABLE sec_two_grantee_privileges_reconcile
         (
           ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
           SYSTEM VARCHAR(20),
           GRANTEE VARCHAR(81),
           TABLE_SCHEMA VARCHAR (64) DEFAULT NULL,
           TABLE_NAME VARCHAR(64) DEFAULT NULL,
           PRIVILEGE VARCHAR (30),
           TYPE CHAR(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 
         INSERT INTO sec_two_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
            SELECT CONCAT("'", us.USERNAME , "'@'" , ho.HOSTNAME , "'"), db.DATABASENAME, tb.TABLENAME, ushodbids.PRIVILEGE,'t'
            FROM sec_users us, sec_hosts ho, sec_databases db, sec_tables tb JOIN (
               SELECT US_ID,HO_ID,DB_ID,TB_ID,ushodbroids.PRIVILEGE
               FROM sec_us_ho_db_tb ushodbtb JOIN (
                  SELECT ushodbro.US_HO_DB_TB_ID, pr.PRIVILEGE
                  FROM sec_us_ho_db_tb_ro ushodbro JOIN sec_ro_pr ropr JOIN  sec_privileges pr
                  WHERE ropr.PR_ID=pr.ID AND
                  ropr.RO_ID=ushodbro.RO_ID AND
                  ushodbro.STATE='A'
                  ) ushodbroids
               WHERE ushodbtb.ID=ushodbroids.US_HO_DB_TB_ID AND
               ushodbtb.STATE='A' 
               ) ushodbids
            WHERE us.ID=ushodbids.US_ID AND
            ho.ID=ushodbids.HO_ID AND
            db.ID=ushodbids.DB_ID AND
            tb.ID=ushodbids.TB_ID
            ORDER BY 1 ASC;
 
         INSERT INTO sec_two_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
            SELECT CONCAT("'", us.USERNAME , "'@'" , ho.HOSTNAME , "'"), db.DATABASENAME, sp.STOREDPROCEDURENAME, ushodbids.PRIVILEGE,'s'
            FROM sec_users us, sec_hosts ho, sec_databases db, sec_storedprocedures sp JOIN (
               SELECT US_ID,HO_ID,DB_ID,SP_ID,ushodbroids.PRIVILEGE
               FROM sec_us_ho_db_sp ushodbsp JOIN (
                  SELECT ushodbro.US_HO_DB_SP_ID, pr.PRIVILEGE
                  FROM sec_us_ho_db_sp_ro ushodbro JOIN sec_ro_pr ropr JOIN  sec_privileges pr
                  WHERE ropr.PR_ID=pr.ID AND
                  ropr.RO_ID=ushodbro.RO_ID AND
                  ushodbro.STATE='A'
                  ) ushodbroids
               WHERE ushodbsp.ID=ushodbroids.US_HO_DB_SP_ID AND
               ushodbsp.STATE='A' 
               ) ushodbids
            WHERE us.ID=ushodbids.US_ID AND
            ho.ID=ushodbids.HO_ID AND
            db.ID=ushodbids.DB_ID AND
            sp.ID=ushodbids.SP_ID
            ORDER BY 1 ASC;
 
         UPDATE sec_two_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_NAME=NULL
         WHERE pr.TYPE='2' OR TABLE_NAME='';
 
         UPDATE sec_two_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_NAME=NULL
         WHERE (pr.TYPE='1' OR TABLE_NAME='') AND grpr.TYPE='t';
 
         UPDATE sec_two_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_SCHEMA=NULL, TABLE_NAME=NULL
         WHERE pr.TYPE='3' OR TABLE_SCHEMA='*';
 
         INSERT INTO sec_two_grantee_privileges_reconcile (SYSTEM,GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
         SELECT MIN(System), GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         FROM
         (
           SELECT 'MySQL' AS System, inf_grantee_privileges.GRANTEE, inf_grantee_privileges.TABLE_SCHEMA, inf_grantee_privileges.TABLE_NAME, inf_grantee_privileges.PRIVILEGE, inf_grantee_privileges.TYPE
           FROM inf_grantee_privileges
           UNION ALL
           SELECT 'Securich' AS System, sec_two_grantee_privileges.GRANTEE, sec_two_grantee_privileges.TABLE_SCHEMA, sec_two_grantee_privileges.TABLE_NAME, sec_two_grantee_privileges.PRIVILEGE, sec_two_grantee_privileges.TYPE
           FROM sec_two_grantee_privileges
         ) tmp
         GROUP BY GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         HAVING COUNT(*) = 1
         ORDER BY GRANTEE;

         IF (SELECT COUNT(*) FROM sec_two_grantee_privileges_reconcile WHERE SYSTEM = 'MySQL') > 0 THEN
 
           OPEN cur_role;
              cur_role_loop:WHILE(done=0) DO
              FETCH cur_role INTO privilegerole;
   
              IF done=1 THEN
                 SET done=0;
                 LEAVE cur_role_loop;
              END IF;
   
              SET @a= CONCAT('set @b=(SELECT COUNT(*) FROM sec_roles WHERE ROLE="' , privilegerole , '")');
   
              PREPARE temporarycom FROM @a;
              EXECUTE temporarycom;
   
              IF @b < 1 THEN
                 SET @c = CONCAT('call create_update_role ("add","' , LOWER(privilegerole) , '","' , LOWER(privilegerole) , '")');
                 PREPARE rolecreatecom FROM @c;
                 EXECUTE rolecreatecom;
              END IF;
   
              END WHILE cur_role_loop;
   
           CLOSE cur_role;
   
           OPEN cur_user;
   
              cur_user_loop:WHILE(done=0) DO
              FETCH cur_user INTO SYSTEMPARAM, usernameinathostnamein, tableschema, tablename, role, objecttype;
   
              IF done=1 THEN
                 SET done=0;
                 LEAVE cur_user_loop;
              END IF;
   
              IF objecttype = 't' AND tablename IS NULL THEN
                 SET defobjecttype = 'all' ;
              ELSEIF objecttype = 't' AND tablename IS NOT NULL THEN
                 SET defobjecttype = 'singletable' ;
              ELSEIF objecttype = 's' THEN
                 SET defobjecttype = 'storedprocedure';
              END IF;
   
              IF tablename IS NULL THEN
                 SET tablename = '';
              END IF;
   
              SET roletype=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=role);
              IF SYSTEMPARAM = 'MySQL' THEN
                 SET @i=CONCAT('call grant_privileges_reverse_reconciliation("' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', 1)) , '","' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', -1)) , '","' , tableschema , '","' , tablename , '","' , defobjecttype , '","' , role , '","");');
              ELSE
                 IF command_mysqlrecon= 'mysqlsync' THEN
                    SET @i=CONCAT('call revoke_privileges("' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', 1)) , '","' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', -1)) , '","' , tableschema , '","' , tablename , '","' , defobjecttype , '","' , role , '","");');
                 END IF;
              END IF;
   
              IF @i IS NOT NULL THEN
                 PREPARE grantcomrecon FROM @i;
                 EXECUTE grantcomrecon;
              END IF;

              END WHILE cur_user_loop;

           CLOSE cur_user;

         END IF;
 
         UPDATE sec_config SET VALUE = '0' WHERE PROPERTY = 'mysql_to_securich_reconciliation_in_progress';
 
  END$$

DELIMITER ;
