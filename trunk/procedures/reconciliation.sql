#######################################################################################
##                                                                                   ##
##   This is reconciliation, a script used to check and repair any differences       ##
##   between the mysql privileges tables and securich db.                            ##
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

DROP PROCEDURE IF EXISTS reconciliation;

DELIMITER $$


CREATE PROCEDURE `reconciliation`(command VARCHAR(50))
BEGIN
      DECLARE PRIVILEGEPARAM VARCHAR(64);
      DECLARE DATABASENAMEPARAM VARCHAR(64);
      DECLARE TABLENAMEPARAM VARCHAR(64);
      DECLARE GRANTEEPARAM VARCHAR(82);
      DECLARE SYSTEMPARAM VARCHAR(25);
      DECLARE TYPEPARAM VARCHAR(25);
      DECLARE PRIVTYPEPARAM INT;
      DECLARE PRIV_RECON VARCHAR(50);
      DECLARE randompassword CHAR(15);
      DECLARE randompasswordvalue VARCHAR(80);
      DECLARE usernameid INT;
      DECLARE hostnameid INT;
      DECLARE userhostid INT;
      DECLARE rowcount INT;
      DECLARE reservedusername VARCHAR(50);
      DECLARE list_id INT(10);
      DECLARE done INT DEFAULT 0;
 
      DECLARE cur_reconcile CURSOR FOR
	       SELECT ID FROM sec_grantee_privileges_reconcile;
	
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
      
      SET @@session.max_sp_recursion_depth=30;
 
      CALL update_databases_tables_storedprocedures_list();
 
      IF command <> 'list' AND command <> 'sync' AND command <> 'securichsync' AND command <> 'mysqlsync' THEN
         SELECT "WRONG PARAMETER PASSED THROUGH RECONCILIATION" AS ERROR;
 
      ELSEIF command = 'mysqlsync' THEN
 
         FLUSH PRIVILEGES;
         CALL mysql_reconciliation('mysqlsync');
 
      ELSE
 
         FLUSH PRIVILEGES;
 
         IF command = 'sync' THEN
            IF (SELECT `value` FROM sec_config WHERE property='priv_mode') = 'safe' THEN
               CALL mysql_reconciliation('');
 
            END IF;
         END IF;
 
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
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA,PRIVILEGE,TYPE)
         SELECT  GRANTEE, sch.SCHEMA_NAME, PRIVILEGE_TYPE, 't' 
         FROM information_schema.USER_PRIVILEGES JOIN information_schema.SCHEMATA sch
            WHERE grantee IN 
               (SELECT DISTINCT (grantee) 
                FROM information_schema.user_privileges)
            AND sch.SCHEMA_NAME != 'information_schema' ;
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA,PRIVILEGE,TYPE)
            SELECT GRANTEE, TABLE_SCHEMA, PRIVILEGE_TYPE,'t'
            FROM information_schema.SCHEMA_PRIVILEGES;
 
         INSERT INTO inf_grantee_privileges (GRANTEE,TABLE_SCHEMA, TABLE_NAME,PRIVILEGE,TYPE)
            SELECT GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE,'t'
            FROM information_schema.TABLE_PRIVILEGES;
 
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
 
            PREPARE delcom FROM @g;
            EXECUTE delcom;
 
            DELETE FROM sec_tmp_reserved_usernames WHERE USERNAME=reservedusername;
 
         UNTIL (SELECT COUNT(*) FROM sec_tmp_reserved_usernames) = 0
         END REPEAT;
	
         DELETE
         FROM inf_grantee_privileges
         WHERE PRIVILEGE='USAGE';
 
         DELETE
         FROM inf_grantee_privileges
         WHERE GRANTEE LIKE '\'\'%';
 
         UPDATE inf_grantee_privileges grpr 
            JOIN sec_privileges pr ON grpr.PRIVILEGE = pr.PRIVILEGE 
            SET TABLE_NAME = NULL 
               WHERE pr.TYPE = '2' 
                  OR TABLE_NAME = '' ;
                     
         UPDATE inf_grantee_privileges grpr 
            JOIN sec_privileges pr ON grpr.PRIVILEGE = pr.PRIVILEGE 
            SET TABLE_NAME = NULL 
               WHERE (pr.TYPE = '1' 
                  OR TABLE_NAME = '') 
                  AND grpr.TYPE = 't' ;
           
         UPDATE inf_grantee_privileges grpr 
            JOIN sec_privileges pr ON grpr.PRIVILEGE = pr.PRIVILEGE 
            SET TABLE_SCHEMA = NULL, TABLE_NAME = NULL 
               WHERE pr.TYPE = '3' 
               OR TABLE_SCHEMA = '*' ;
 
         DROP TABLE IF EXISTS sec_grantee_privileges;
         CREATE TEMPORARY TABLE sec_grantee_privileges
         (
           ID INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
           GRANTEE VARCHAR(81),
           TABLE_SCHEMA VARCHAR (64) DEFAULT NULL,
           TABLE_NAME VARCHAR(64) DEFAULT NULL,
           PRIVILEGE VARCHAR (30),
           TYPE CHAR(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MYISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 
         DROP TABLE IF EXISTS sec_grantee_privileges_reconcile;
         CREATE TEMPORARY TABLE sec_grantee_privileges_reconcile
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
 
         INSERT INTO sec_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
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
 
         INSERT INTO sec_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
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
 
         UPDATE sec_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_NAME=NULL
         WHERE pr.TYPE='2' OR TABLE_NAME='';
 
         UPDATE sec_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_NAME=NULL
         WHERE (pr.TYPE='1' OR TABLE_NAME='') AND grpr.TYPE='t';
 
         UPDATE sec_grantee_privileges grpr JOIN sec_privileges pr ON grpr.PRIVILEGE=pr.PRIVILEGE
         SET TABLE_SCHEMA=NULL, TABLE_NAME=NULL
         WHERE pr.TYPE='3' OR TABLE_SCHEMA='*';
 
         INSERT INTO sec_grantee_privileges_reconcile (SYSTEM,GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
         SELECT MIN(System), GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         FROM
         (
           SELECT 'MySQL' AS System, inf_grantee_privileges.GRANTEE, inf_grantee_privileges.TABLE_SCHEMA, inf_grantee_privileges.TABLE_NAME, inf_grantee_privileges.PRIVILEGE, inf_grantee_privileges.TYPE
           FROM inf_grantee_privileges
           UNION ALL
           SELECT 'Securich' AS System, sec_grantee_privileges.GRANTEE, sec_grantee_privileges.TABLE_SCHEMA, sec_grantee_privileges.TABLE_NAME, sec_grantee_privileges.PRIVILEGE, sec_grantee_privileges.TYPE
           FROM sec_grantee_privileges
         ) tmp
         GROUP BY GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         HAVING COUNT(*) = 1;
 
         IF command = 'list' THEN
 
            SELECT MIN(System) AS System, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
            FROM
            (
              SELECT 'MySQL' AS System, inf_grantee_privileges.GRANTEE, inf_grantee_privileges.TABLE_SCHEMA, inf_grantee_privileges.TABLE_NAME, inf_grantee_privileges.PRIVILEGE, inf_grantee_privileges.TYPE
              FROM inf_grantee_privileges
              UNION ALL
              SELECT 'Securich' AS System, sec_grantee_privileges.GRANTEE, sec_grantee_privileges.TABLE_SCHEMA, sec_grantee_privileges.TABLE_NAME, sec_grantee_privileges.PRIVILEGE, sec_grantee_privileges.TYPE
              FROM sec_grantee_privileges
            ) tmp
            GROUP BY GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
            HAVING COUNT(*) = 1
            ORDER BY GRANTEE;
 
         ELSEIF command = 'sync' OR command = 'securichsync' THEN
 
            UPDATE sec_grantee_privileges_reconcile
            SET TABLE_NAME='*'
            WHERE TABLE_NAME IS NULL;
 
            UPDATE sec_grantee_privileges_reconcile
            SET TABLE_SCHEMA='*'
            WHERE TABLE_SCHEMA IS NULL;
 
            DROP TABLE IF EXISTS temp_tbl_users;
            CREATE TEMPORARY TABLE temp_tbl_users (users VARCHAR(82));
 
            INSERT INTO temp_tbl_users SELECT DISTINCT GRANTEE FROM information_schema.USER_PRIVILEGES;
            INSERT INTO temp_tbl_users SELECT DISTINCT GRANTEE FROM information_schema.TABLE_PRIVILEGES WHERE GRANTEE NOT IN (SELECT GRANTEE FROM information_schema.USER_PRIVILEGES);
            INSERT INTO temp_tbl_users SELECT DISTINCT GRANTEE FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE NOT IN (SELECT GRANTEE FROM information_schema.TABLE_PRIVILEGES) AND GRANTEE NOT IN (SELECT GRANTEE FROM information_schema.USER_PRIVILEGES);
 
            OPEN cur_reconcile;
 
            cur_reconcile_loop:WHILE(done=0) DO
            FETCH cur_reconcile INTO list_id;
 
            IF done=1 THEN
               LEAVE cur_reconcile_loop;
            END IF;
 
            SET SYSTEMPARAM=(SELECT SYSTEM FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
            SET PRIVILEGEPARAM=(SELECT PRIVILEGE FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
            SET PRIVTYPEPARAM=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIVILEGEPARAM);
            SET DATABASENAMEPARAM=(SELECT TABLE_SCHEMA FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
            SET TABLENAMEPARAM=(SELECT TABLE_NAME FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
            SET GRANTEEPARAM=(SELECT GRANTEE FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
            SET TYPEPARAM=(SELECT TYPE FROM sec_grantee_privileges_reconcile WHERE ID=list_id);
 
            IF (SELECT COUNT(*) FROM temp_tbl_users WHERE users=GRANTEEPARAM) = 0 THEN
               
               SET randompassword = (SELECT SUBSTRING(MD5(RAND()) FROM 1 FOR 15));
               SET @c = CONCAT('create user ' , GRANTEEPARAM , ' identified by "' , randompassword , '"');
 
               PREPARE createcom FROM @c;
               EXECUTE createcom;
 
               SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
               SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
 
               INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
               
               SET randompasswordvalue= (SELECT PASSWORD(randompassword));
               
               SET usernameid = (SELECT ID FROM sec_users WHERE USERNAME=(SELECT TRIM(BOTH "'" FROM SUBSTRING_INDEX(GRANTEEPARAM, '@',1))));
               SET hostnameid = (SELECT ID FROM sec_hosts WHERE HOSTNAME=(SELECT TRIM(BOTH "'" FROM SUBSTRING_INDEX(GRANTEEPARAM, '@',-1))));
               SET userhostid = (SELECT ID FROM sec_us_ho WHERE US_ID=usernameid AND HO_ID=hostnameid);
 
               IF (SELECT COUNT(*) FROM sec_us_ho_profile WHERE US_HO_ID=userhostid) = 0 THEN
                  INSERT INTO sec_us_ho_profile (US_HO_ID,PW0,CREATE_TIMESTAMP,UPDATE_TIMESTAMP,TYPE) VALUES (ushoidvalue,randompasswordvalue,NOW(),NOW(),'USER');
               END IF;
 
               INSERT INTO temp_tbl_users (users) VALUES (GRANTEEPARAM);
 
            END IF;
 
            IF PRIVTYPEPARAM=3 THEN
 
               SET DATABASENAMEPARAM='*';
               SET TABLENAMEPARAM='*';
 
            END IF;
 
            IF TYPEPARAM = 't' THEN
 
               IF PRIVTYPEPARAM=2 OR PRIVTYPEPARAM=1 THEN
                  SET TABLENAMEPARAM='*';
               END IF;
 
               IF SYSTEMPARAM = 'MySQL' THEN
                  SET @g = CONCAT('revoke ', PRIVILEGEPARAM , ' on ' , DATABASENAMEPARAM , '.' , TABLENAMEPARAM , ' from ' , GRANTEEPARAM);
               ELSE
                  SET @g = CONCAT('grant ', PRIVILEGEPARAM , ' on ' , DATABASENAMEPARAM , '.' , TABLENAMEPARAM , ' to ' , GRANTEEPARAM);
               END IF;
 
            ELSEIF TYPEPARAM = 's' THEN
 
               IF PRIVTYPEPARAM=2 THEN
                  SET TABLENAMEPARAM='*';
               END IF;
 
               IF SYSTEMPARAM = 'MySQL' THEN
                  SET @g = CONCAT('revoke ', PRIVILEGEPARAM , ' on procedure ' , DATABASENAMEPARAM , '.' , TABLENAMEPARAM , ' from ' , GRANTEEPARAM);
               ELSE
                  SET @g = CONCAT('grant ', PRIVILEGEPARAM , ' on procedure ' , DATABASENAMEPARAM , '.' , TABLENAMEPARAM , ' to ' , GRANTEEPARAM);
               END IF;
 
            END IF;
 
            PREPARE grantcom FROM @g;
            EXECUTE grantcom;
 
            SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
            SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
 
            INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());
 
            END WHILE cur_reconcile_loop;
 
            CLOSE cur_reconcile;
            FLUSH PRIVILEGES;
 
         ELSE
            SELECT "Incorrect command - should be either -list- or -sync-" AS ERROR;
         END IF;
 
      END IF;
 
  END$$
 
DELIMITER ;
