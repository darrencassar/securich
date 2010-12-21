#######################################################################################
##                                                                                   ##
##   This is reverse_reconciliation, used to migrate MySQL user accounts to          ##
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

DROP PROCEDURE IF EXISTS reverse_reconciliation;

DELIMITER $$

CREATE PROCEDURE `securich`.`reverse_reconciliation`()
  BEGIN

      DECLARE dbnamein VARCHAR(60);
      DECLARE rowcount INT;
      DECLARE reservedusername VARCHAR(50);
      DECLARE usernameinathostnamein VARCHAR(76);
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
         SELECT GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         FROM inf_grantee_privileges;
      
      DECLARE cur_databases CURSOR FOR
         SELECT DATABASENAME
         FROM sec_databases
         WHERE DATABASENAME <> '';         

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         /* The below if statement blocks an alert if reconciliation is not possible due to no users to reconcile (happens normally at the beginning of an installation) */
         IF (SELECT COUNT(*) FROM sec_users) > 0 THEN
            SELECT 'Error occurred - terminating - reverse reconciliation failed';
         END IF;
      END;

         update sec_config set VALUE = '1' where PROPERTY = 'reverse_reconciliation_in_progress';

         FLUSH PRIVILEGES;

         DROP TABLE IF EXISTS inf_grantee_privileges;

/* Tables used to hold mysql privs */

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

/* Build up a list of privileges mysql ownes in order to be compared later (in the same stored proc) with privileges owned by securich */

         INSERT INTO inf_grantee_privileges (GRANTEE,PRIVILEGE,TYPE)
            SELECT GRANTEE,PRIVILEGE_TYPE,'t'
            FROM information_schema.USER_PRIVILEGES
               WHERE grantee IN (
                  SELECT DISTINCT(grantee) 
                  FROM information_schema.user_privileges
               );


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


/* Adding stored procedures privileges to the list */
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

         /* Remove any records of privileges for reserved usernames inside of the above tables */

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
         
         DROP TABLE IF EXISTS temp_table_reconciliation;
         CREATE TEMPORARY TABLE temp_table_reconciliation (commands TEXT)ENGINE=MYISAM;  
         
         OPEN cur_role;

            cur_role_loop:WHILE(done=0) DO

            FETCH cur_role INTO privilegerole;

            IF done=1 THEN
               SET done=0;
               LEAVE cur_role_loop;
            END IF;
            
            SET @a= CONCAT('set @b=(SELECT COUNT(*) FROM sec_roles WHERE ROLE="' , privilegerole , '")');

            PREPARE tempcom FROM @a;
            EXECUTE tempcom;
            
            
            IF @b < 1 THEN

               SET @c = CONCAT('call create_update_role ("add","' , LOWER(privilegerole) , '","' , LOWER(privilegerole) , '")');

               PREPARE rolecom FROM @c;
               EXECUTE rolecom;
            
            END IF;

            END WHILE cur_role_loop;

         CLOSE cur_role;
            
         OPEN cur_user;

            cur_user_loop:WHILE(done=0) DO

            FETCH cur_user INTO usernameinathostnamein, tableschema, tablename, role, objecttype;

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
            
            SET roletype=(select type from sec_privileges where PRIVILEGE=role);
            
            IF tableschema IS NULL THEN
            
            /* If roletype is global just grant the privilege on a single database */
            
               IF roletype > 2 THEN
               
                  SET dbnamein=(SELECT DATABASENAME FROM sec_databases WHERE DATABASENAME <> '' limit 1);
               
                  SET @g=CONCAT('call grant_privileges_reverse_reconciliation("' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', 1)) , '","' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', -1)) , '","' , dbnamein , '","' , tablename , '","' , defobjecttype , '","' , role , '","");');
                  INSERT INTO temp_table_reconciliation SELECT @g;
               
               ELSE
               
                  OPEN cur_databases;

                     cur_databases_loop:WHILE(done=0) DO

                     FETCH cur_databases INTO dbnamein;

                     IF done=1 THEN
                        SET done=0;
                        LEAVE cur_databases_loop;
                     END IF;
           
                        SET @h=CONCAT('call grant_privileges_reverse_reconciliation("' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', 1)) , '","' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', -1)) , '","' , dbnamein , '","' , tablename , '","' , defobjecttype , '","' , role , '","");');
                        INSERT INTO temp_table_reconciliation SELECT @h;

                     END WHILE cur_databases_loop;

                  CLOSE cur_databases;
               
               END IF;
  
            ELSE
         
               SET @i=CONCAT('call grant_privileges_reverse_reconciliation("' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', 1)) , '","' , TRIM(BOTH '\'' FROM SUBSTRING_INDEX(usernameinathostnamein, '@', -1)) , '","' , tableschema , '","' , tablename , '","' , defobjecttype , '","' , role , '","");');
               INSERT INTO temp_table_reconciliation SELECT @i;
                           
            END IF;
                        
            END WHILE cur_user_loop;

         CLOSE cur_user;
         
         update sec_config set VALUE = '0' where PROPERTY = 'reverse_reconciliation_in_progress';

         SELECT distinct(commands) FROM temp_table_reconciliation INTO OUTFILE '/tmp/securich_reconciliation.sql';
         
         call reconciliation('sync');
  END$$

DELIMITER ;
