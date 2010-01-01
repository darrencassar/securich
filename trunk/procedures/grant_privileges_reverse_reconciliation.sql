#######################################################################################
##                                                                                   ##
##   This is grant_privileges_reverse_reconciliation, a script used to grant roles   ##
##   to combinations of user, database, host, tables, stored procedures etc.         ##
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

DROP PROCEDURE IF EXISTS grant_privileges_reverse_reconciliation;

DELIMITER $$

CREATE  DEFINER=`root`@`localhost` PROCEDURE `securich`.`grant_privileges_reverse_reconciliation`( usernamein VARCHAR(16), hostnamein VARCHAR(60), dbnamein VARCHAR(64), tbnamein VARCHAR(64), tabletype VARCHAR(16), rolein VARCHAR(60), emailaddressin VARCHAR(50))
  BEGIN

      DECLARE userexists INT;
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
      DECLARE randompassword CHAR(15);
      DECLARE randompasswordvalue CHAR(41);
      DECLARE tbname VARCHAR(64);
      DECLARE spname VARCHAR(64);
      DECLARE reservedusername INT;

      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         SELECT 'Error occurred - terminating - MySQL to Securich reconciliation failed';
      END;

      FLUSH PRIVILEGES;

                      /* Security feature does not permit the user of reserved usernames through this package! */

      SET reservedusername = (
         SELECT COUNT(*)
         FROM sec_reserved_usernames
         WHERE USERNAME=usernamein
         );

      IF reservedusername > 0 /*usernamein = 'root' or usernamein = 'msandbox' or usernamein = '' or any other reserved usernames*/ THEN

         SELECT "Illegal username entry";
         
      ELSEIF dbnamein = 'mysql' THEN

         SELECT "Illegal database name entry";
         
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

         IF roleexists = 0 OR ( databaseexists = 0 AND tabletype = 'singletable' )THEN

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

                  INSERT INTO sec_us_ho (US_ID,HO_ID) VALUES (usidvalue, hoidvalue);
                  SET ushoidvalue = (SELECT ID FROM sec_us_ho WHERE US_ID=usidvalue AND HO_ID=hoidvalue);

                  SET randompasswordvalue= (SELECT Password from mysql.user where User=usernamein and Host =hostnamein);

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

                         /* update the status of the user and privilege combination to active */

                  UPDATE sec_us_ho_db_tb
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     TB_ID=tbidvalue;

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

                         /* update the status of the user and privilege combination to active */

                  UPDATE sec_us_ho_db_sp
                     SET STATE ='A'
                     WHERE US_ID=usidvalue AND
                     HO_ID=hoidvalue AND
                     DB_ID=dbidvalue AND
                     SP_ID=spidvalue;

               END IF;

               COMMIT;

            END IF;

         END IF;

      END IF;
                 
      IF ushoidcount < 1 then
      
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
      END IF;
              
      CALL reconciliation('sync');

      FLUSH PRIVILEGES;

  END$$

DELIMITER ;
