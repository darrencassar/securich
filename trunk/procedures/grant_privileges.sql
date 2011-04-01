#######################################################################################
##                                                                                   ##
##   This is grant_privileges, a script used to grant roles to combinations          ##
##   of user, database, host, tables, stored procedures etc.                         ##
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

DROP PROCEDURE IF EXISTS grant_privileges;

DELIMITER $$

/*
Details below are quite straightforward:
usernameinin = username to be used
hostnamein = hostname from where the user is going to connect (can have %) or can provide subnets and stuff as you'd do with mysql grant command
dbnamein = database name privileges are to be granted on
tbnamein = name of table for a single table, common part of name if using regexp, can be left empty if using all or alltables as table type
tabletype = all, alltables, singletable, regexp
rolein = name of role to be used
emailaddressin = email address of the user who is being granted access
*/

CREATE  PROCEDURE `securich`.`grant_privileges`( usernamein VARCHAR(16), hostnamein VARCHAR(60), dbnamein VARCHAR(64), tbnamein VARCHAR(64), tabletype VARCHAR(16), rolein VARCHAR(60), emailaddressin VARCHAR(50))
  BEGIN

      DECLARE userexists INT;
      DECLARE userexistsonmysql INT;
      DECLARE roleexists INT;
      DECLARE hostexists INT;
      DECLARE databaseexists INT;
      DECLARE tableexists INT;
      DECLARE storedprocedureexists INT;
      DECLARE userroleexists INT;

      DECLARE usidvalue INT;
      DECLARE roidvalue INT;
      DECLARE hoidvalue INT;
      DECLARE dbidvalue INT;
      DECLARE tbidvalue INT;
      DECLARE spidvalue INT;
      DECLARE ushoidvalue INT;
      DECLARE ushodbtbidvalue INT;
      DECLARE ushodbspidvalue INT;

      DECLARE ushodbtbidcount INT;
      DECLARE ushodbspidcount INT;
      DECLARE ushoidcount INT;
      DECLARE ushodbtbrocount INT;
      DECLARE ushodbsprocount INT;
      DECLARE tbindbcheck INT;
      DECLARE spindbcheck INT;

      DECLARE randomnumber INT;
      DECLARE randompassword VARCHAR(35);
      DECLARE randompasswordvalue CHAR(41);
      DECLARE createuser VARCHAR(400);
      DECLARE tbname VARCHAR(64);
      DECLARE spname VARCHAR(64);
      DECLARE reservedusername INT;
      DECLARE modeofoperation VARCHAR(40);
      DECLARE usercreated INT;

      DECLARE RL VARCHAR(20);
      DECLARE PRIV_OBO_GRANT VARCHAR(50);

      DECLARE done INT DEFAULT 0;

                      /* list of privileges a particular user entity (username@hostname) will be granted on a particular combination of database and tables */

      DECLARE cur_priv CURSOR FOR
	       SELECT DISTINCT PRIVILEGE
	       FROM  sec_privileges INNER JOIN (
	          SELECT PR_ID FROM sec_ro_pr
	          WHERE RO_ID IN (
	             SELECT DISTINCT r.ID
	             FROM sec_roles AS r JOIN (
	                SELECT ID
	                FROM sec_us_ho_db_tb a
	                WHERE a.US_ID=(
	                   SELECT ID
	                   FROM sec_users
	                   WHERE USERNAME=usernamein
	                   )
	                AND a.HO_ID=(
	                   SELECT ID
	                   FROM sec_hosts
	                   WHERE HOSTNAME=hostnamein
	                   )
	                AND a.DB_ID=(
	                   SELECT ID
	                   FROM sec_databases
	                   WHERE DATABASENAME=dbnamein
	                   )
	                AND a.TB_ID=(
	                   SELECT ID
	                   FROM sec_tables
	                   WHERE TABLENAME=tbname
	                   )
	                ) ids JOIN sec_us_ho_db_tb_ro AS uhdr
	             WHERE r.ID=uhdr.RO_ID AND
	             ids.ID=uhdr.US_HO_DB_TB_ID
	             )
	          ) IDS
	       WHERE sec_privileges.ID=IDS.PR_ID;

      DECLARE cur_priv_proc CURSOR FOR
	       SELECT DISTINCT PRIVILEGE
	       FROM  sec_privileges INNER JOIN (
	          SELECT PR_ID FROM sec_ro_pr
	          WHERE RO_ID IN (
	             SELECT DISTINCT r.ID
	             FROM sec_roles AS r JOIN (
	                SELECT ID
	                FROM sec_us_ho_db_sp a
	                WHERE a.US_ID=(
	                   SELECT ID
	                   FROM sec_users
	                   WHERE USERNAME=usernamein
	                   )
	                AND a.HO_ID=(
	                   SELECT ID
	                   FROM sec_hosts
	                   WHERE HOSTNAME=hostnamein
	                   )
	                AND a.DB_ID=(
	                   SELECT ID
	                   FROM sec_databases
	                   WHERE DATABASENAME=dbnamein
	                   )
	                AND a.SP_ID=(
	                   SELECT ID
	                   FROM sec_storedprocedures
	                   WHERE STOREDPROCEDURENAME=spname
	                   )
	                ) ids JOIN sec_us_ho_db_sp_ro AS uhdr
	             WHERE r.ID=uhdr.RO_ID AND
	             ids.ID=uhdr.US_HO_DB_SP_ID
	             )
	          ) IDS
	       WHERE sec_privileges.ID=IDS.PR_ID;

                      /* list of all tables in a particular database */

      DECLARE cur_tables_all_tables CURSOR FOR
	          SELECT TABLENAME
	          FROM sec_tables JOIN sec_db_tb JOIN (
	             SELECT ID
	             FROM sec_databases
	             WHERE DATABASENAME=dbnamein
	             ) dbids
	          WHERE dbids.ID = sec_db_tb.DB_ID AND
	          sec_tables.ID = sec_db_tb.TB_ID AND
            sec_tables.TABLENAME <> '';

                      /* list of tables when using regexp function */

	    DECLARE cur_tables_regexp CURSOR FOR
	          SELECT TABLENAME
	          FROM sec_tables JOIN sec_db_tb JOIN (
	             SELECT ID
	             FROM sec_databases
	             WHERE DATABASENAME=dbnamein
	             ) dbids
	          WHERE dbids.ID = sec_db_tb.DB_ID AND
	          sec_tables.id = sec_db_tb.TB_ID AND
	          TABLENAME REGEXP binary(tbnamein);

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
/*
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         call reconciliation('sync');
         FLUSH PRIVILEGES;

         SELECT 'Error occurred - terminating - USER CREATION AND / OR PRIVILEGES GRANT FAILED' as ERROR;
      END;
*/

      FLUSH PRIVILEGES;
      CALL update_databases_tables_storedprocedures_list();


                      /* Security feature does not permit the user of reserved usernames through this package! */

      SET modeofoperation= (
         SELECT VALUE
         FROM sec_config
         WHERE PROPERTY='sec_mode'
         );

      SET reservedusername = (
         SELECT COUNT(*)
         FROM sec_reserved_usernames
         WHERE USERNAME=usernamein
         );

      IF reservedusername > 0 /*usernamein = 'root' or usernamein = 'msandbox' or usernamein = '' or any other reserved usernames */ THEN

         SELECT "Illegal username entry: Username used is a reserved username in securich" as ERROR;

      ELSEIF dbnamein = 'mysql' and modeofoperation='9' THEN

         SELECT "Illegal database name entry: `mysql` db can not be used when securich is running in 'strict' mode" as ERROR;

      ELSEIF tabletype != 'all' and tabletype != 'alltables' and tabletype != 'singletable' and tabletype != 'regexp' and tabletype != 'storedprocedure' then

         SELECT "Tabletype specified incorrect- Please choose from either, all, alltables, singletable, regexp or storedprocedure" as ERROR;

      ELSE

         SET userexists = (
            SELECT COUNT(*)
            FROM sec_users
            WHERE USERNAME=usernamein
            );

         SET roleexists = (
            SELECT COUNT(*)
            FROM sec_roles
            WHERE ROLE=rolein
            );

         SET hostexists = (
            SELECT COUNT(*)
            FROM sec_hosts
            WHERE HOSTNAME=hostnamein
            );

         SET tableexists = (
            SELECT COUNT(*)
            FROM sec_tables
            WHERE TABLENAME=tbnamein
            );

         SET databaseexists = (
            SELECT COUNT(*)
            FROM sec_databases
            WHERE DATABASENAME=dbnamein
            );

         IF databaseexists = 0  THEN
               insert into sec_databases (DATABASENAME) values (dbnamein);
         END IF;

                      /* provide some error handling and graceful output if there is a problem */

         IF roleexists = 0 OR ( databaseexists = 0 AND (tabletype = 'singletable' or tabletype = 'regexp' ) )THEN

	          IF roleexists = 0 THEN
               SELECT "Role specified does not exist, please check role list and retry";
	          END IF;

	          IF databaseexists = 0 /* AND tabletype = 'singletable' */ THEN
               SELECT "Database does not exist";
               DELETE from sec_databases where DATABASENAME=dbnamein; /* If the database just created is not needed, then remove it from the list*/
            END IF;

         ELSE
                      /* Check if user already has the specified role assigned to it. */

            SET userroleexists = (
               SELECT COUNT(ROLE)
               FROM sec_roles AS r JOIN (
                  SELECT ID
                  FROM sec_us_ho_db_tb a
                  WHERE a.US_ID=(
                     SELECT ID
                     FROM sec_users
   			      			WHERE USERNAME=usernamein
   			      			)
   			      	  AND a.HO_ID=(
   			      		 	SELECT ID
   			      		 	FROM sec_hosts
   			      		 	WHERE HOSTNAME=hostnamein
   			      		 	)
   			      	  AND a.DB_ID=(
   			      	     SELECT ID
   			      	     FROM sec_databases
   			      	     WHERE DATABASENAME=dbnamein
   			      	     )
   			      	  AND a.TB_ID=(
   			      	     SELECT ID
   			      	     FROM sec_tables
   			      	     WHERE TABLENAME=NULL
   			      	     )
   			      	  ) ids
   			      	  JOIN sec_us_ho_db_tb_ro AS uhdr
    	         WHERE r.ID=uhdr.RO_ID AND
    		       ids.ID=uhdr.US_HO_DB_TB_ID AND
    		       r.ROLE=rolein
    		       );

            IF userroleexists > 0 AND tbnamein = '' THEN
	             SELECT "Username specified already contains role specified";
            ELSE

                      /* run most of the code in transaction mode thus rolling back most of it if things don't work out (apart from DDL statments like create, drop and alter) */

               CALL update_databases_tables_storedprocedures_list();
               START TRANSACTION;

                      /* if usernames or hostnames don't exist in the securich database, then insert them */

               IF userexists < 1 THEN
                  INSERT INTO sec_users (USERNAME,EMAIL_ADDRESS) VALUES (usernamein,emailaddressin);
               END IF;

               IF hostexists < 1 THEN
                  INSERT INTO sec_hosts (HOSTNAME) VALUES (hostnamein);
               END IF;

                      /* setting flags in order to be used in checks further down */
                      /* checks include checking if a username@host is created, if the latter entity has any relations with databases, tables etc */

               SET usidvalue = (SELECT ID FROM sec_users WHERE USERNAME=usernamein);

               SET roidvalue = (SELECT ID FROM sec_roles WHERE ROLE=rolein);

               SET hoidvalue = (SELECT ID FROM sec_hosts WHERE HOSTNAME=hostnamein);

               SET dbidvalue = (SELECT ID FROM sec_databases WHERE DATABASENAME=dbnamein);

               SET ushoidvalue = (SELECT ID FROM sec_us_ho WHERE US_ID=usidvalue AND HO_ID=hoidvalue );

               SET randomnumber = 0;

               WHILE randomnumber < 12 OR randomnumber > 20 DO
                  SET randomnumber=(SELECT ROUND(RAND()*100));
               END WHILE;


               SET randompassword = (SELECT SUBSTRING(MD5(RAND()) FROM 1 FOR randomnumber));

               SET ushoidcount = (SELECT COUNT(*) FROM sec_us_ho_profile WHERE US_HO_ID=ushoidvalue );

                      /* if the user doesn't exist, then create it and provide a random 15character password (never create a user without a password) */

               IF ushoidcount < 1 THEN

                  SET userexistsonmysql=(select count(*) from  information_schema.USER_PRIVILEGES where grantee=concat("'",usernamein,"'@'",hostnamein,"'"));

                  IF userexistsonmysql = 1 THEN

                     IF (select count(*) from  information_schema.SCHEMA_PRIVILEGES where grantee=concat("'",usernamein,"'@'",hostnamein,"'")) = 0 THEN

                        SET @d = CONCAT('drop user "' , usernamein , '"@"' , hostnamein , '"');

                        PREPARE dropcom FROM @d;
                        EXECUTE dropcom;

                        SET @c = CONCAT('create user "' , usernamein , '"@"' , hostnamein , '" identified by "' , randompassword , '"');

                        PREPARE createcom FROM @c;
                        EXECUTE createcom;

                        SET usercreated = 1;

                     END IF;

                  END IF;

                      /* insert a record of the user entity (username@host) in sec_us_ho */

                  INSERT INTO sec_us_ho (US_ID,HO_ID) VALUES (usidvalue, hoidvalue);
                  SET ushoidvalue = (SELECT ID FROM sec_us_ho WHERE US_ID=usidvalue AND HO_ID=hoidvalue);

                  SET randompasswordvalue= (SELECT PASSWORD(randompassword));

                      /* store an entry for a particular user entity (username@host) in sec_us_ho_profile which holds password history, creation history, last update history, password change count etc */

                  INSERT INTO sec_us_ho_profile (US_HO_ID,PW0,CREATE_TIMESTAMP,UPDATE_TIMESTAMP,TYPE) VALUES (ushoidvalue,randompasswordvalue,NOW(),NOW(),'USER');

               END IF;



               IF  tabletype = 'all' THEN

                         /* grant provileges to a particular user on the whole database */

                  SET tbname = '';
                  SET tbidvalue = '1';

                         /* used to create a combination of the objects in sec_us_ho_db_tb if there exists none */

                  SET ushodbtbidcount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_tb
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue
                     );

                  IF ushodbtbidcount < 1 THEN
                     INSERT INTO sec_us_ho_db_tb (US_ID,HO_ID,DB_ID,TB_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, tbidvalue, 'I');
                  END IF;

                  SET ushodbtbidvalue = (
                     SELECT ID
                     FROM sec_us_ho_db_tb
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue
                     );

                         /* if there is no entry in sec_us_ho_db_tb_ro, then create one */

                  SET ushodbtbrocount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_tb_ro
                     WHERE US_HO_DB_TB_ID = ushodbtbidvalue AND
                     RO_ID = roidvalue
                     );

                  IF ushodbtbrocount < 1 THEN
                     INSERT INTO sec_us_ho_db_tb_ro (US_HO_DB_TB_ID,RO_ID) VALUES (ushodbtbidvalue, roidvalue);
                  END IF;

                         /* open cursor and start fetching privileges in order to grant them*/

                     OPEN cur_priv;

                     cur_priv_loop:WHILE(done=0) DO

                     FETCH cur_priv INTO PRIV_OBO_GRANT;

                         /* once done, just leave the loop */

                     IF done=1 THEN
                        LEAVE cur_priv_loop;

                     END IF;

                         /* check privilege type, if it is table level, db level or global in order to know how to compile the grant command */

                     SET @t=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIV_OBO_GRANT);

                         /* depending on the type of priv, a different kind of grant command is built */

                     IF @t<3 THEN
                        SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.*' , ' to "' , usernamein , '"@"' , hostnamein , '"');

                     ELSE
                        SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on *.* to "' , usernamein , '"@"' , hostnamein , '"');

                     END IF;

                     PREPARE grantcom FROM @g;
                     EXECUTE grantcom;



                         /* loop untill there is no more privileges to grant */

                     END WHILE cur_priv_loop;
                     CLOSE cur_priv;

                         /* update the status of the user and privilege combination to active */

                  UPDATE sec_us_ho_db_tb
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue;

               ELSEIF tabletype = 'singletable' THEN

                      /* grant privileges on a single table in a particular database */

                  SET tbname = tbnamein;

                  IF tableexists < 1 THEN

                     INSERT INTO sec_tables (TABLENAME) VALUES (tbnamein);
                  END IF;

                  SET tbidvalue = (SELECT ID FROM sec_tables WHERE TABLENAME=tbname);

                  SET tbindbcheck = (
                     SELECT COUNT(*) FROM sec_tables tb JOIN sec_db_tb dbtb JOIN (SELECT ID FROM sec_databases WHERE DATABASENAME=dbnamein) db
                     WHERE tb.TABLENAME=tbname AND
                     dbtb.TB_ID=tb.ID AND
                     db.ID=dbtb.DB_ID
                     );

                         /* if table does exist in table, create a record of it in sec_db_tb */

                  IF tbindbcheck < 1 THEN
                     INSERT INTO sec_db_tb (DB_ID,TB_ID) VALUES (dbidvalue,tbidvalue);
                  END IF;

                         /* used to create a combination of the objects in sec_us_ho_db_tb if there exists none */

                  SET ushodbtbidcount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_tb
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue
                     );

                  IF ushodbtbidcount < 1 THEN
                     INSERT INTO sec_us_ho_db_tb (US_ID,HO_ID,DB_ID,TB_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, tbidvalue, 'I');
                  END IF;

                  SET ushodbtbidvalue = (
                     SELECT ID
                     FROM sec_us_ho_db_tb
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue
                     );

                         /* if there is no entry in sec_us_ho_db_tb_ro, then create one */

                  SET ushodbtbrocount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_tb_ro
                     WHERE US_HO_DB_TB_ID = ushodbtbidvalue AND
                     RO_ID = roidvalue
                     );

                  IF ushodbtbrocount < 1 THEN
                     INSERT INTO sec_us_ho_db_tb_ro (US_HO_DB_TB_ID,RO_ID) VALUES (ushodbtbidvalue, roidvalue);
                  END IF;

                         /* open cursor and start fetching privileges in order to grant them*/

                     OPEN cur_priv;

                     cur_priv_loop:WHILE(done=0) DO

                     FETCH cur_priv INTO PRIV_OBO_GRANT;

                         /* once done, just leave the loop */

                     IF done=1 THEN
                        LEAVE cur_priv_loop;

                     END IF;

                         /* check privilege type, if it is table level, db level or global in order to know how to compile the grant command */

                     SET @t=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIV_OBO_GRANT);

                         /* if table does not exist physically on the database, attach CREATE to each privilege as otherwise the grant will fail */

                     IF tbindbcheck < 1 THEN
                        SET PRIV_OBO_GRANT = CONCAT ('CREATE , ', PRIV_OBO_GRANT);

                     END IF;

                         /* depending on the type of priv, a different kind of grant command is built */

                     IF @t<1 THEN
                        SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.' , tbname , ' to "' , usernamein , '"@"' , hostnamein , '"');

                     ELSEIF @t<3 THEN
                        SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.*' , ' to "' , usernamein , '"@"' , hostnamein , '"');

                     ELSEIF @t=3 THEN
                        SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on *.* to "' , usernamein , '"@"' , hostnamein , '"');

                     END IF;

                     PREPARE grantcom FROM @g;
                     EXECUTE grantcom;

                         /* loop untill there is no more privileges to grant */

                     END WHILE cur_priv_loop;
                     CLOSE cur_priv;

                         /* update the status of the user and privilege combination to active */

                  UPDATE sec_us_ho_db_tb
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue;

               /* Granting privileges on a per table basis */
               ELSEIF tabletype = 'alltables' THEN

                  /* If the database doesn't contain any tables, then granting roles to `ALLTABLES` is not possible, thus a warning is issued */
                  IF (SELECT COUNT(ID) FROM sec_db_tb WHERE DB_ID=(SELECT ID FROM sec_databases WHERE DATABASENAME=dbnamein) AND TB_ID <> 1) > 0 THEN

                     OPEN cur_tables_all_tables;
                     REPEAT
                        FETCH cur_tables_all_tables INTO tbname;

                            /* for each table, obtain a table id from sec_tables to be used in most of the counts and checks further down */

                           SET tbidvalue = (SELECT ID FROM sec_tables WHERE TABLENAME=tbname);

                            /* used to create a combination of the objects in sec_us_ho_db_tb if there exists none */

                           SET ushodbtbidcount = (
                              SELECT COUNT(*)
                              FROM sec_us_ho_db_tb
                              WHERE US_ID=usidvalue AND
                              HO_ID=hoidvalue AND
                              DB_ID=dbidvalue AND
                              TB_ID=tbidvalue
                              );

                           IF ushodbtbidcount < 1 THEN
                              INSERT INTO sec_us_ho_db_tb (US_ID,HO_ID,DB_ID,TB_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, tbidvalue, 'I');
                           END IF;

                           SET ushodbtbidvalue = (
                              SELECT ID
                              FROM sec_us_ho_db_tb
                              WHERE US_ID=usidvalue AND
                              HO_ID=hoidvalue AND
                              DB_ID=dbidvalue AND
                              TB_ID=tbidvalue
                              );

                            /* if there is no entry in sec_us_ho_db_tb_ro, then create one */

                           SET ushodbtbrocount = (
                              SELECT COUNT(*)
                              FROM sec_us_ho_db_tb_ro
                              WHERE US_HO_DB_TB_ID = ushodbtbidvalue AND
                              RO_ID = roidvalue
                              );

                           IF ushodbtbrocount < 1 THEN
                              INSERT INTO sec_us_ho_db_tb_ro (US_HO_DB_TB_ID,RO_ID) VALUES (ushodbtbidvalue, roidvalue);
                           END IF;

                            /* open cursor and start fetching privileges in order to grant them*/

                              OPEN cur_priv;

                              cur_priv_loop:WHILE(done=0) DO

                              FETCH cur_priv INTO PRIV_OBO_GRANT;

                            /* once done, just leave the loop */

                            	IF done=1 THEN
                            	   SET done=0;
                                 LEAVE cur_priv_loop;
                              END IF;

                            /* check privilege type, if it is table level, db level or global in order to know how to compile the grant command */

                              SET @t=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIV_OBO_GRANT);

                            /* depending on the type of priv, a different kind of grant command is built */

                              IF @t<1 THEN

                                 SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.' , tbname , ' to "' , usernamein , '"@"' , hostnamein , '"');

                              ELSEIF @t<3 THEN

                                 SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.*' , ' to "' , usernamein , '"@"' , hostnamein , '"');

                              ELSEIF @t=3 THEN
                                 SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on *.* to "' , usernamein , '"@"' , hostnamein , '"');

                              END IF;

                              PREPARE grantcom FROM @g;
                              EXECUTE grantcom;

                            /* loop untill there is no more privileges to grant */

                              END WHILE cur_priv_loop;
                              CLOSE cur_priv;

                            /* update the status of the user and privilege combination to active */

                           UPDATE sec_us_ho_db_tb
                              SET STATE ='A'
                              WHERE US_ID=usidvalue AND
                              HO_ID=hoidvalue AND
                              DB_ID=dbidvalue AND
                              TB_ID=tbidvalue;

                           UNTIL done END REPEAT;

                        CLOSE cur_tables_all_tables;
                   ELSE

                      SELECT "There are no tables in the database specified, therefore please use `all` instead of `alltables`";

                   END IF;
               ELSEIF tabletype = 'regexp' THEN

                      /* granting privileges to a set of tables who'se name has something in common */

               OPEN cur_tables_regexp;
               REPEAT

                     FETCH cur_tables_regexp INTO tbname;

                     SET tbidvalue = (SELECT ID FROM sec_tables WHERE TABLENAME= binary(tbname));

                      /* used to create a combination of the objects in sec_us_ho_db_tb if there exists none */

                     SET ushodbtbidcount = (
                        SELECT COUNT(*)
                        FROM sec_us_ho_db_tb
                        WHERE US_ID=usidvalue AND
                        HO_ID=hoidvalue AND
                        DB_ID=dbidvalue AND
                        TB_ID=tbidvalue
                        );

                     IF ushodbtbidcount < 1 THEN
                        INSERT INTO sec_us_ho_db_tb (US_ID,HO_ID,DB_ID,TB_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, tbidvalue, 'I');
                     END IF;

                     SET ushodbtbidvalue = (
                        SELECT ID
                        FROM sec_us_ho_db_tb
                        WHERE US_ID=usidvalue AND
                        HO_ID=hoidvalue AND
                        DB_ID=dbidvalue AND
                        TB_ID=tbidvalue
                        );

                      /* if there is no entry in sec_us_ho_db_tb_ro, then create one */

                     SET ushodbtbrocount = (
                        SELECT COUNT(*)
                        FROM sec_us_ho_db_tb_ro
                        WHERE US_HO_DB_TB_ID = ushodbtbidvalue AND
                        RO_ID = roidvalue
                        );

                     IF ushodbtbrocount < 1 THEN
                        INSERT INTO sec_us_ho_db_tb_ro (US_HO_DB_TB_ID,RO_ID) VALUES (ushodbtbidvalue, roidvalue);
                     END IF;

                      /* open cursor and start fetching privileges in order to grant them*/

                        OPEN cur_priv;

                        cur_priv_loop:WHILE(done=0) DO

                        FETCH cur_priv INTO PRIV_OBO_GRANT;

                      /* once done, just leave the loop */
                      	IF done=1 THEN
                      	   SET done=0;

                           LEAVE cur_priv_loop;
                        END IF;

                      /* check privilege type, if it is table level, db level or global in order to know how to compile the grant command */

                        SET @t=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIV_OBO_GRANT);

                      /* depending on the type of priv, a different kind of grant command is built */

                        IF @t<1 THEN

                           SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.' , tbname , ' to "' , usernamein , '"@"' , hostnamein , '"');

                        ELSEIF @t<3 THEN

                           SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on ' , dbnamein , '.*' , ' to "' , usernamein , '"@"' , hostnamein , '"');

                        ELSEIF @t=3 THEN
                           SET @g = CONCAT('grant ', PRIV_OBO_GRANT , ' on *.* to "' , usernamein , '"@"' , hostnamein , '"');

                        END IF;

                        PREPARE grantcom FROM @g;
                        EXECUTE grantcom;

                      /* loop untill there is no more privileges to grant */

                        END WHILE cur_priv_loop;
                        CLOSE cur_priv;

                      /* update the status of the user and privilege combination to active */

                     UPDATE sec_us_ho_db_tb
                        SET STATE ='A'
                        WHERE US_ID=usidvalue AND
                        HO_ID=hoidvalue AND
                        DB_ID=dbidvalue AND
                        TB_ID=tbidvalue;

                     UNTIL done END REPEAT;

                  CLOSE cur_tables_regexp;

               ELSEIF tabletype = 'storedprocedure' THEN

                      /* grant privileges on a single table in a particular database */

                  SET spname = tbnamein;

                  SET storedprocedureexists = (SELECT COUNT(*) FROM sec_storedprocedures WHERE STOREDPROCEDURENAME=spname);

                  IF storedprocedureexists < 1 THEN
                     INSERT INTO sec_storedprocedures (STOREDPROCEDURENAME) VALUES (spname);
                  END IF;

                  SET spidvalue = (SELECT ID FROM sec_storedprocedures WHERE STOREDPROCEDURENAME=spname);

                  SET spindbcheck = (
                     SELECT COUNT(*) FROM sec_storedprocedures sp JOIN sec_db_sp dbsp JOIN (SELECT ID FROM sec_databases WHERE DATABASENAME=dbnamein) db
                     WHERE sp.STOREDPROCEDURENAME=spname AND
                     dbsp.SP_ID=sp.ID AND
                     db.ID=dbsp.DB_ID
                     );

                         /* if stored procedure does exist in table, create a record of it in sec_db_sp */

                  IF spindbcheck < 1 THEN
                     INSERT INTO sec_db_sp (DB_ID,SP_ID) VALUES (dbidvalue,spidvalue);
                  END IF;

                         /* used to create a combination of the objects in sec_us_ho_db_sp if there exists none */

                  SET ushodbspidcount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                  IF ushodbspidcount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp (US_ID,HO_ID,DB_ID,SP_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, spidvalue, 'I');
                  END IF;

                  SET ushodbspidvalue = (
                     SELECT ID
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                         /* if there is no entry in sec_us_ho_db_sp_ro, then create one */

                  SET ushodbsprocount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp_ro
                     WHERE US_HO_DB_SP_ID = ushodbspidvalue AND
                     RO_ID = roidvalue
                     );

                  IF ushodbsprocount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp_ro (US_HO_DB_SP_ID,RO_ID) VALUES (ushodbspidvalue, roidvalue);
                  END IF;
                         /* open cursor and start fetching privileges in order to grant them*/

                     OPEN cur_priv_proc;

                     cur_priv_loop:WHILE(done=0) DO

                     FETCH cur_priv_proc INTO PRIV_OBO_GRANT;

                         /* once done, just leave the loop */

                     IF done=1 THEN
                        LEAVE cur_priv_loop;

                     END IF;

                         /* check privilege type, if it is stored procedure level, db level or global in order to know which can be used with the grant command */

                     SET @p=(SELECT TYPE FROM sec_privileges WHERE PRIVILEGE=PRIV_OBO_GRANT);
                         /* only alter routine and execute can be granted to stored procs, most of the others will have to be run on a db level at least */
                     IF @p = 1 THEN
                        SET @g = CONCAT('grant ' , PRIV_OBO_GRANT , ' on procedure ' , dbnamein , '.' , spname , ' to "' , usernamein , '"@"' , hostnamein , '";');
                     ELSE
                        SET @g = CONCAT('select "Privilege ' , PRIV_OBO_GRANT , ' can not be granted to a stored procedure." as ERROR;');
                     END IF;


                     PREPARE grantcom FROM @g;
                     EXECUTE grantcom;

                         /* loop untill there is no more privileges to grant */

                     END WHILE cur_priv_loop;
                     CLOSE cur_priv_proc;
                         /* update the status of the user and privilege combination to active */

                  UPDATE sec_us_ho_db_sp
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue;

               END IF;

               SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
               SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
               INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());

                      /* output the password to be sent to the user */

               IF ushoidcount < 1 THEN

                  IF usercreated = 1 THEN

                     SET @randomp = CONCAT('select "Password for user -- ' , usernamein , ' -- contactable at -- ' , emailaddressin , ' -- is -- ' , randompassword , ' --" as USER_PASSWORD');

                     PREPARE randompasswordcom FROM @randomp;
                     EXECUTE randompasswordcom;

                  END IF;


                  SET spname = 'set_my_password';

                  SET spidvalue = (SELECT ID FROM sec_storedprocedures WHERE STOREDPROCEDURENAME=spname);


                  SET dbidvalue = (SELECT ID FROM sec_databases WHERE DATABASENAME='securich');

                  SET ushodbspidcount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                  IF ushodbspidcount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp (US_ID,HO_ID,DB_ID,SP_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, spidvalue, 'I');
                  END IF;

                  SET ushodbspidvalue = (
                     SELECT ID
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                  SET roidvalue = (SELECT ID FROM sec_roles WHERE ROLE='execute');

                  SET ushodbsprocount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp_ro
                     WHERE US_HO_DB_SP_ID = ushodbspidvalue AND
                     RO_ID = roidvalue
                     );

                  IF ushodbsprocount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp_ro (US_HO_DB_SP_ID,RO_ID) VALUES (ushodbspidvalue, roidvalue);
                  END IF;

                  SET @g = CONCAT('grant execute on procedure securich.set_my_password to "' , usernamein , '"@"' , hostnamein , '";');

                  PREPARE grantcom FROM @g;
                  EXECUTE grantcom;

                  UPDATE sec_us_ho_db_sp
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue;

                  SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
                  SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
                  INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());

                  SET spname = 'set_password';

                  SET spidvalue = (SELECT ID FROM sec_storedprocedures WHERE STOREDPROCEDURENAME=spname);


                  SET dbidvalue = (SELECT ID FROM sec_databases WHERE DATABASENAME='securich');

                  SET ushodbspidcount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                  IF ushodbspidcount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp (US_ID,HO_ID,DB_ID,SP_ID,STATE) VALUES (usidvalue, hoidvalue, dbidvalue, spidvalue, 'I');
                  END IF;

                  SET ushodbspidvalue = (
                     SELECT ID
                     FROM sec_us_ho_db_sp
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue
                     );

                  SET roidvalue = (SELECT ID FROM sec_roles WHERE ROLE='execute');

                  SET ushodbsprocount = (
                     SELECT COUNT(*)
                     FROM sec_us_ho_db_sp_ro
                     WHERE US_HO_DB_SP_ID = ushodbspidvalue AND
                     RO_ID = roidvalue
                     );

                  IF ushodbsprocount < 1 THEN
                     INSERT INTO sec_us_ho_db_sp_ro (US_HO_DB_SP_ID,RO_ID) VALUES (ushodbspidvalue, roidvalue);
                  END IF;

                  SET @g = CONCAT('grant execute on procedure securich.set_password to "' , usernamein , '"@"' , hostnamein , '";');

                  PREPARE grantcom FROM @g;
                  EXECUTE grantcom;

                  UPDATE sec_us_ho_db_sp
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue;

                  SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
                  SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
                  INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());

               ELSE

/* RE copy password to make sure it wasn't tempred with and also useful when a user has been deleted due to revoking of all privileges (but is still in securich
system therefore once recreated with grant, reissuing the set password will be necessary. */

                  SET @reppas = (  SELECT PW0
                     FROM sec_us_ho_profile ushopr JOIN (
                        SELECT suh.ID
                        FROM sec_us_ho AS suh JOIN (
                           SELECT sus.ID
                           FROM sec_users AS sus
                           WHERE USERNAME=usernamein
                           ) us
                        JOIN (
                           SELECT sho.ID
                           FROM sec_hosts AS sho
                           WHERE HOSTNAME=hostnamein
                           ) ho
                        WHERE US_ID=us.ID AND
                        HO_ID=ho.ID
                        ) usho
                     WHERE ushopr.US_HO_ID=usho.ID
                     );

                  SET @reppascom = CONCAT('SET PASSWORD FOR \'' , usernamein , '\'@\'' , hostnamein , '\' = \'' , @reppas , '\';');

                  PREPARE refreshpasswordcom FROM @reppascom;
                  EXECUTE refreshpasswordcom;

               END IF;

               COMMIT;

            END IF;

         END IF;

      END IF;

      FLUSH PRIVILEGES;

  END$$

DELIMITER ;
