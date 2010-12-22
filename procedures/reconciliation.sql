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

CREATE PROCEDURE `securich`.`reconciliation`(command varchar(50))
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
	       select ID from sec_grantee_privileges_reconcile;

      DECLARE CONTINUE HANDLER FOR not found SET done = 1;

      /* Exception handler
      DECLARE EXIT HANDLER FOR SQLEXCEPTION
      BEGIN
         ROLLBACK;
         IF (select count(*) from sec_users) > 0 THEN
            SELECT 'Error occurred - terminating - USER CREATION AND / OR PRIVILEGES GRANT FAILED' as ERROR;
         END IF;
      END;*/

	  SET @@session.max_sp_recursion_depth=30;

      CALL update_databases_tables_storedprocedures_list();

      IF command <> 'list' AND command <> 'sync' AND command <> 'securichsync' AND command <> 'mysqlsync' THEN

         select "WRONG PARAMETER PASSED THROUGH RECONCILIATION" as ERROR;

      ELSEIF command = 'mysqlsync' THEN

         FLUSH PRIVILEGES;
         call mysql_reconciliation('mysqlsync');

      ELSE

         FLUSH PRIVILEGES;

         IF command = 'sync' THEN

            IF (select `value` from sec_config where property='prive_mode') = 'safe' THEN

               call mysql_reconciliation('');

        	END IF;

         END IF;

         drop table if exists inf_grantee_privileges;

/* Tables used to hold mysql privs */

         create temporary table inf_grantee_privileges
         (
           ID int(10) unsigned NOT NULL AUTO_INCREMENT,
           GRANTEE varchar(81),
           TABLE_SCHEMA varchar (64) DEFAULT NULL,
           TABLE_NAME varchar (64) DEFAULT NULL,
           PRIVILEGE varchar (30),
           TYPE char(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

/* Build up a list of privileges mysql ownes in order to be compared later (in the same stored proc) with privileges owned by securich */

         insert into inf_grantee_privileges (GRANTEE,PRIVILEGE,TYPE)
            select GRANTEE,PRIVILEGE_TYPE,'t'
            from information_schema.USER_PRIVILEGES;

         insert into inf_grantee_privileges (GRANTEE,TABLE_SCHEMA,PRIVILEGE,TYPE)
            select GRANTEE, TABLE_SCHEMA, PRIVILEGE_TYPE,'t'
            from information_schema.SCHEMA_PRIVILEGES;

         insert into inf_grantee_privileges (GRANTEE,TABLE_SCHEMA, TABLE_NAME,PRIVILEGE,TYPE)
            select GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE,'t'
            from information_schema.TABLE_PRIVILEGES;

         drop table if exists temp_tbl_PROCS_PRIVILEGES;

         create temporary table temp_tbl_PROCS_PRIVILEGES (
            GRANTEE varchar(81),
            TABLE_SCHEMA varchar (64) DEFAULT NULL,
            TABLE_NAME varchar (64) DEFAULT NULL,
            PRIVILEGE varchar (30)
         ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

         insert into temp_tbl_PROCS_PRIVILEGES
            select concat("'",User,"'@'",Host,"'"),Db,Routine_name,substring_index(Proc_priv,',',1)
            from mysql.procs_priv;

         insert into temp_tbl_PROCS_PRIVILEGES
            select concat("'",User,"'@'",Host,"'"),Db,Routine_name,substring_index(Proc_priv,',',-1)
            from mysql.procs_priv;

         insert into inf_grantee_privileges (GRANTEE,TABLE_SCHEMA, TABLE_NAME,PRIVILEGE, TYPE)
            select distinct GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE,'s'
            from temp_tbl_PROCS_PRIVILEGES;

         drop table if exists sec_tmp_reserved_usernames;

         create temporary table sec_tmp_reserved_usernames
            (
              ID int(10) unsigned NOT NULL AUTO_INCREMENT,
              USERNAME varchar(50) DEFAULT NULL,
              PRIMARY KEY (`ID`)
            ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

	     insert into sec_tmp_reserved_usernames select ID,USERNAME from sec_reserved_usernames;

         /* Remove any records of privileges for reserved usernames inside of the above tables */

         SET rowcount = (select count(*) from sec_tmp_reserved_usernames);

         REPEAT

            SET reservedusername = (select USERNAME from sec_tmp_reserved_usernames limit 1);

            SET @g = CONCAT('delete from inf_grantee_privileges where GRANTEE regexp "^\'', reservedusername ,'\'"');

            PREPARE delcom FROM @g;
            EXECUTE delcom;

            delete from sec_tmp_reserved_usernames where USERNAME=reservedusername;

         UNTIL (select count(*) from sec_tmp_reserved_usernames) = 0
         END REPEAT;

         delete
         from inf_grantee_privileges
         where PRIVILEGE='USAGE';

         drop table if exists sec_grantee_privileges;

/* Tables used to hold securich privs */

         create temporary table sec_grantee_privileges
         (
           ID int(10) unsigned NOT NULL AUTO_INCREMENT,
           GRANTEE varchar(81),
           TABLE_SCHEMA varchar (64) DEFAULT NULL,
           TABLE_NAME varchar(64) DEFAULT NULL,
           PRIVILEGE varchar (30),
           TYPE char(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

         drop table if exists sec_grantee_privileges_reconcile;

         create temporary table sec_grantee_privileges_reconcile
         (
           ID int(10) unsigned NOT NULL AUTO_INCREMENT,
           SYSTEM varchar(20),
           GRANTEE varchar(81),
           TABLE_SCHEMA varchar (64) DEFAULT NULL,
           TABLE_NAME varchar(64) DEFAULT NULL,
           PRIVILEGE varchar (30),
           TYPE char(1),
           PRIMARY KEY (`ID`)
         ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

/* Build up a list of privileges securich ownes in order to be compared later (in the same stored proc) with privileges owned by mysql tables (user, db, tables_priv and procs_priv) */

         insert into sec_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
            select CONCAT("'", us.USERNAME , "'@'" , ho.HOSTNAME , "'"), db.DATABASENAME, tb.TABLENAME, ushodbids.PRIVILEGE,'t'
            from sec_users us, sec_hosts ho, sec_databases db, sec_tables tb join (
               select US_ID,HO_ID,DB_ID,TB_ID,ushodbroids.PRIVILEGE
               from sec_us_ho_db_tb ushodbtb join (
                  select ushodbro.US_HO_DB_TB_ID, pr.PRIVILEGE
                  from sec_us_ho_db_tb_ro ushodbro join sec_ro_pr ropr join  sec_privileges pr
                  where ropr.PR_ID=pr.ID and
                  ropr.RO_ID=ushodbro.RO_ID and
                  ushodbro.STATE='A'
                  ) ushodbroids
               where ushodbtb.ID=ushodbroids.US_HO_DB_TB_ID and
               ushodbtb.STATE='A' /* do not take up any records which are revoked or blocked */
               ) ushodbids
            where us.ID=ushodbids.US_ID and
            ho.ID=ushodbids.HO_ID and
            db.ID=ushodbids.DB_ID and
            tb.ID=ushodbids.TB_ID
            order by 1 asc;

         insert into sec_grantee_privileges (GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
            select CONCAT("'", us.USERNAME , "'@'" , ho.HOSTNAME , "'"), db.DATABASENAME, sp.STOREDPROCEDURENAME, ushodbids.PRIVILEGE,'s'
            from sec_users us, sec_hosts ho, sec_databases db, sec_storedprocedures sp join (
               select US_ID,HO_ID,DB_ID,SP_ID,ushodbroids.PRIVILEGE
               from sec_us_ho_db_sp ushodbsp join (
                  select ushodbro.US_HO_DB_SP_ID, pr.PRIVILEGE
                  from sec_us_ho_db_sp_ro ushodbro join sec_ro_pr ropr join  sec_privileges pr
                  where ropr.PR_ID=pr.ID and
                  ropr.RO_ID=ushodbro.RO_ID and
                  ushodbro.STATE='A'
                  ) ushodbroids
               where ushodbsp.ID=ushodbroids.US_HO_DB_SP_ID and
               ushodbsp.STATE='A' /* do not take up any records which are revoked or blocked */
               ) ushodbids
            where us.ID=ushodbids.US_ID and
            ho.ID=ushodbids.HO_ID and
            db.ID=ushodbids.DB_ID and
            sp.ID=ushodbids.SP_ID
            order by 1 asc;

         update sec_grantee_privileges grpr join sec_privileges pr on grpr.PRIVILEGE=pr.PRIVILEGE
         set TABLE_NAME=NULL
         where pr.TYPE='2' OR TABLE_NAME='';

         update sec_grantee_privileges grpr join sec_privileges pr on grpr.PRIVILEGE=pr.PRIVILEGE
         set TABLE_NAME=NULL
         where (pr.TYPE='1' OR TABLE_NAME='') AND grpr.TYPE='t';

         update sec_grantee_privileges grpr join sec_privileges pr on grpr.PRIVILEGE=pr.PRIVILEGE
         set TABLE_SCHEMA=NULL, TABLE_NAME=NULL
         where pr.TYPE='3' OR TABLE_SCHEMA='*';

         insert into sec_grantee_privileges_reconcile (SYSTEM,GRANTEE,TABLE_SCHEMA,TABLE_NAME,PRIVILEGE,TYPE)
         SELECT MIN(System), GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         FROM
         (
           SELECT 'MySQL' as System, inf_grantee_privileges.GRANTEE, inf_grantee_privileges.TABLE_SCHEMA, inf_grantee_privileges.TABLE_NAME, inf_grantee_privileges.PRIVILEGE, inf_grantee_privileges.TYPE
           FROM inf_grantee_privileges
           UNION ALL
           SELECT 'Securich' as System, sec_grantee_privileges.GRANTEE, sec_grantee_privileges.TABLE_SCHEMA, sec_grantee_privileges.TABLE_NAME, sec_grantee_privileges.PRIVILEGE, sec_grantee_privileges.TYPE
           FROM sec_grantee_privileges
         ) tmp
         GROUP BY GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
         HAVING COUNT(*) = 1
         ORDER BY GRANTEE;

         IF command = 'list' THEN

            SELECT MIN(System) as System, GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
            FROM
            (
              SELECT 'MySQL' as System, inf_grantee_privileges.GRANTEE, inf_grantee_privileges.TABLE_SCHEMA, inf_grantee_privileges.TABLE_NAME, inf_grantee_privileges.PRIVILEGE, inf_grantee_privileges.TYPE
              FROM inf_grantee_privileges
              UNION ALL
              SELECT 'Securich' as System, sec_grantee_privileges.GRANTEE, sec_grantee_privileges.TABLE_SCHEMA, sec_grantee_privileges.TABLE_NAME, sec_grantee_privileges.PRIVILEGE, sec_grantee_privileges.TYPE
              FROM sec_grantee_privileges
            ) tmp
            GROUP BY GRANTEE, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE, TYPE
            HAVING COUNT(*) = 1
            ORDER BY GRANTEE;

         ELSEIF command = 'sync' or command = 'securichsync' THEN

            update sec_grantee_privileges_reconcile
            set TABLE_NAME='*'
            where TABLE_NAME is NULL;

            update sec_grantee_privileges_reconcile
            set TABLE_SCHEMA='*'
            where TABLE_SCHEMA is NULL;

            drop table if exists temp_tbl_users;
            create temporary table temp_tbl_users (users varchar(82));
            insert into temp_tbl_users select distinct GRANTEE from information_schema.USER_PRIVILEGES;
            insert into temp_tbl_users select distinct GRANTEE from information_schema.TABLE_PRIVILEGES where GRANTEE not in (select GRANTEE from information_schema.USER_PRIVILEGES);
            insert into temp_tbl_users select distinct GRANTEE from information_schema.SCHEMA_PRIVILEGES where GRANTEE not in (select GRANTEE from information_schema.TABLE_PRIVILEGES) and GRANTEE not in (select GRANTEE from information_schema.USER_PRIVILEGES);


            OPEN cur_reconcile;

            cur_reconcile_loop:WHILE(done=0) DO

            FETCH cur_reconcile INTO list_id;

            IF done=1 THEN
               LEAVE cur_reconcile_loop;
            END IF;

            SET SYSTEMPARAM=(select SYSTEM from sec_grantee_privileges_reconcile where ID=list_id);
            SET PRIVILEGEPARAM=(select PRIVILEGE from sec_grantee_privileges_reconcile where ID=list_id);
            SET PRIVTYPEPARAM=(select TYPE from sec_privileges where PRIVILEGE=PRIVILEGEPARAM);
            SET DATABASENAMEPARAM=(select TABLE_SCHEMA from sec_grantee_privileges_reconcile where ID=list_id);
            SET TABLENAMEPARAM=(select TABLE_NAME from sec_grantee_privileges_reconcile where ID=list_id);
            SET GRANTEEPARAM=(select GRANTEE from sec_grantee_privileges_reconcile where ID=list_id);
            SET TYPEPARAM=(select TYPE from sec_grantee_privileges_reconcile where ID=list_id);

            IF (select count(*) from temp_tbl_users where users=GRANTEEPARAM) = 0 THEN

               /* if user is not there, create it */
               SET randompassword = (select substring(md5(rand()) from 1 for 15));

               SET @c = CONCAT('create user ' , GRANTEEPARAM , ' identified by "' , randompassword , '"');

               PREPARE createcom FROM @c;
               EXECUTE createcom;

               /* insert a record of the user entity (username@host) in sec_us_ho */

               SET randompasswordvalue= (select password(randompassword));

               /* store an entry for a particular user entity (username@host) in sec_us_ho_profile which holds password history, creation history, last update history, password change count etc */

               SET usernameid = (select ID from sec_users where USERNAME=(select trim(both "'" from substring_index(GRANTEEPARAM, '@',1))));
               SET hostnameid = (select ID from sec_hosts where HOSTNAME=(select trim(both "'" from substring_index(GRANTEEPARAM, '@',-1))));
               SET userhostid = (select ID from sec_us_ho where US_ID=usernameid and HO_ID=hostnameid);

               IF (select count(*) from sec_us_ho_profile where US_HO_ID=userhostid) = 0 THEN

                  insert into sec_us_ho_profile (US_HO_ID,PW0,CREATE_TIMESTAMP,UPDATE_TIMESTAMP,TYPE) values (ushoidvalue,randompasswordvalue,now(),now(),'USER');

               END IF;

               insert into temp_tbl_users (users) values (GRANTEEPARAM);

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

            END WHILE cur_reconcile_loop;

            CLOSE cur_reconcile;

            FLUSH PRIVILEGES;

            SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
            SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
            INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());


         ELSE

            select "Incorrect command - should be either -list- or -sync-" as ERROR;

         END IF;

      END IF;

  END$$

DELIMITER ;
