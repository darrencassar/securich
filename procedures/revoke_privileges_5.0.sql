#######################################################################################
##                                                                                   ##
##   This is revoke_privileges, a script used to revoke roles from combinations      ##
##   of user, database, host, tables, stored procedures etc..                        ##
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

use securich;

DROP PROCEDURE IF EXISTS revoke_privileges;

DELIMITER $$

CREATE PROCEDURE `securich`.`revoke_privileges`( usernamein varchar(16), hostnamein varchar(60), dbnamein varchar(64), tbnamein varchar(64), tabletype varchar(16), rolein varchar(64), terminateconnections char(1))
  BEGIN

    DECLARE roledatabasetableexists int;
    DECLARE roletableexists int;
    DECLARE tableindatabaseexists int;
    DECLARE rolestoredprocedureexists int;
    DECLARE storedprocedureindatabaseexists int;
    DECLARE roledatabasestoredprocedureexists int;
    DECLARE userexists int;
    DECLARE remid int;
    DECLARE sp_rolecount int;
    DECLARE tb_rolecount int;
    DECLARE rolecount int;
    DECLARE ushodbtbid int;
    DECLARE tbidvalue int;
    DECLARE usidvalue int;
    DECLARE roidvalue varchar(10);
    DECLARE hoidvalue int;
    DECLARE dbidvalue int;
    DECLARE ushoidvalue int;
    DECLARE tbcount int;
    DECLARE mybigversion VARCHAR(10);
    DECLARE mymidversion INT(10);
    DECLARE mysmallversion VARCHAR(10);

    FLUSH PRIVILEGES;
    call update_databases_tables_storedprocedures_list();

    SET roledatabasetableexists = (
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
          ) ids
       join sec_us_ho_db_tb_ro as uhdr
       where r.ID=uhdr.RO_ID and
       ids.ID=uhdr.US_HO_DB_TB_ID and
       r.ROLE=rolein
       );

    SET roledatabasestoredprocedureexists = (
       select count(*)
       from sec_roles as r join (
          select ID
          from sec_us_ho_db_sp a
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
          ) ids
       join sec_us_ho_db_sp_ro as uhdr
       where r.ID=uhdr.RO_ID and
       ids.ID=uhdr.US_HO_DB_SP_ID and
       r.ROLE=rolein
       );

    SET roletableexists = (
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
          and a.TB_ID=(
             select ID
             from sec_tables
             where TABLENAME=tbnamein
             )
          ) ids
       join sec_us_ho_db_tb_ro as uhdr
       where r.ID=uhdr.RO_ID and
       ids.ID=uhdr.US_HO_DB_TB_ID and
       r.ROLE=rolein
       );

    SET rolestoredprocedureexists = (
       select count(*)
       from sec_roles as r join (
          select ID
          from sec_us_ho_db_sp a
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
          and a.SP_ID=(
             select ID
             from sec_storedprocedures
             where STOREDPROCEDURENAME=tbnamein
             )
          ) ids
       join sec_us_ho_db_sp_ro as uhdr
       where r.ID=uhdr.RO_ID and
       ids.ID=uhdr.US_HO_DB_SP_ID and
       r.ROLE=rolein
       );

    SET tableindatabaseexists = (
       select count(*)
       from sec_db_tb dbtb join (
          select ID
          from sec_databases
          where DATABASENAME=dbnamein
          ) db join (
          select ID
          from sec_tables
          where TABLENAME like tbnamein
          ) tb
       where db.ID=dbtb.DB_ID and
       tb.ID=dbtb.TB_ID
       );

    SET storedprocedureindatabaseexists = (
       select count(*)
       from sec_db_sp dbsp join (
          select ID
          from sec_databases
          where DATABASENAME=dbnamein
          ) db join (
          select ID
          from sec_storedprocedures
          where STOREDPROCEDURENAME like tbnamein
          ) sp
       where db.ID=dbsp.DB_ID and
       sp.ID=dbsp.SP_ID
       );

    SET userexists = (
       select count(*)
       from sec_us_ho usho join (
          select ID
          from sec_users
          where USERNAME=usernamein
          ) us join (
          select ID
          from sec_hosts
          where HOSTNAME=hostnamein
          ) ho
       where us.ID=usho.US_ID and
       ho.ID=usho.HO_ID
       );


    IF ( select count(*) from sec_users where USERNAME=usernamein) = 0 THEN

       select "Username supplied is incorrect or does not exist";

    ELSEIF (select count(*) from sec_hosts where HOSTNAME=hostnamein) = 0 THEN

       select "Hostname supplied is incorrect or does not exist";

    ELSEIF userexists = 0 THEN

       select "USER DOES NOT EXIST";

    ELSEIF (select count(*) from sec_databases where DATABASENAME=dbnamein) = 0 THEN

       select "Database supplied is incorrect";

    ELSEIF (tableindatabaseexists) = 0 and tabletype = 'table' THEN

       select "Table supplied does not exist in database supplied";

    ELSEIF (storedprocedureindatabaseexists) = 0 and tabletype = 'storedprocedure' THEN

       select "Stored Procedure supplied does not exist in database supplied";

    ELSEIF rolein = '' and (tbnamein <> '' or tabletype <> '') THEN

       select "Role must be specified unless both table/sp name and type are left empty meaning revoking everything from the user";

    ELSEIF dbnamein = '' AND tbnamein <> '' THEN

       select "Can't specify a table without specifying a database";

    ELSEIF roledatabasetableexists = 0 AND roledatabasestoredprocedureexists = 0 AND roletableexists = 0 AND rolestoredprocedureexists = 0 AND rolein != 'ALL' THEN

	     select "ROLE DOES NOT EXIST FOR THIS USER";
	     select "Please check the role name and retry";

    ELSE

       SET usidvalue = (select ID from sec_users where USERNAME=usernamein);
       SET roidvalue = (select ID from sec_roles where ROLE=rolein);
       SET hoidvalue = (select ID from sec_hosts where HOSTNAME=hostnamein);
       SET dbidvalue = (select ID from sec_databases where DATABASENAME=dbnamein);
       SET ushoidvalue = (select ID from sec_us_ho where US_ID=usidvalue and HO_ID=hoidvalue );

       IF rolein='ALL' THEN
          SET roidvalue='%';
       END IF;

       IF (rolein = 'ALL' or rolein = 'all') AND tbnamein = '' AND dbnamein = '' THEN

          update sec_us_ho_db_tb set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue;
          delete sec_us_ho_db_tb_ro.* from sec_us_ho_db_tb_ro inner join (select ID from sec_us_ho_db_tb where STATE='R') removed where sec_us_ho_db_tb_ro.US_HO_DB_TB_ID = removed.ID and RO_ID like roidvalue;
          update sec_us_ho_db_sp set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue;
          delete sec_us_ho_db_sp_ro.* from sec_us_ho_db_sp_ro inner join (select ID from sec_us_ho_db_sp where STATE='R') removed where sec_us_ho_db_sp_ro.US_HO_DB_SP_ID = removed.ID and RO_ID like roidvalue;

          SET @d = CONCAT('drop user "', usernamein , '"@"' , hostnamein , '"');
	        PREPARE dropcom FROM @d;
		      EXECUTE dropcom;

       ELSEIF tbnamein = '' and tabletype = '' THEN

          update sec_us_ho_db_tb set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue;
          delete sec_us_ho_db_tb_ro.* from sec_us_ho_db_tb_ro inner join (select ID from sec_us_ho_db_tb where STATE='R') removed where sec_us_ho_db_tb_ro.US_HO_DB_TB_ID = removed.ID and RO_ID like roidvalue;
          update sec_us_ho_db_sp set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue;
          delete sec_us_ho_db_sp_ro.* from sec_us_ho_db_sp_ro inner join (select ID from sec_us_ho_db_sp where STATE='R') removed where sec_us_ho_db_sp_ro.US_HO_DB_SP_ID = removed.ID and RO_ID like roidvalue;

       ELSE
          IF tabletype='table' OR tabletype ='regexp' THEN

             drop table if exists sec_tmp_tables;

             create temporary table sec_tmp_tables
                (
                  ID int(10) unsigned NOT NULL AUTO_INCREMENT,
                  TABLENAME varchar(64) DEFAULT NULL,
                  PRIMARY KEY (`ID`)
                ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

						 IF tabletype='table' THEN
						    insert into sec_tmp_tables select ID,TABLENAME from sec_tables where TABLENAME like tbnamein;
						 ELSEIF tabletype='regexp' THEN
                insert into sec_tmp_tables select ID,TABLENAME from sec_tables where TABLENAME regexp tbnamein;
             ELSE
                select "this is an error you should not have seen!!! something is wrong in this procedgure BIGTIME";
             END IF;

             SET tbcount = (select count(*) from sec_tmp_tables);

             REPEAT

                SET tbidvalue = (select ID from sec_tmp_tables limit 1);

                update sec_us_ho_db_tb set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue and TB_ID=tbidvalue;
                delete sec_us_ho_db_tb_ro.* from sec_us_ho_db_tb_ro inner join (select ID from sec_us_ho_db_tb where STATE='R') removed where sec_us_ho_db_tb_ro.US_HO_DB_TB_ID = removed.ID and RO_ID like roidvalue;

                delete from sec_tmp_tables where ID=tbidvalue;

             UNTIL (select count(*) from sec_tmp_tables) = 0
             END REPEAT;

          ELSEIF tabletype='storedprocedure' THEN

             drop table if exists sec_tmp_storedprocedures;

             create temporary table sec_tmp_storedprocedures
                (
                  ID int(10) unsigned NOT NULL AUTO_INCREMENT,
                  STOREDPROCEDURENAME varchar(64) DEFAULT NULL,
                  PRIMARY KEY (`ID`)
                ) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

			 insert into sec_tmp_storedprocedures select ID,STOREDPROCEDURENAME from sec_storedprocedures where STOREDPROCEDURENAME like tbnamein;

             REPEAT
             SET tbcount = (select count(*) from sec_tmp_storedprocedures);

             SET tbidvalue = (select ID from sec_tmp_storedprocedures limit 1);

                update sec_us_ho_db_sp set STATE='R' where US_ID=usidvalue and HO_ID=hoidvalue and DB_ID=dbidvalue and SP_ID=tbidvalue;
                delete sec_us_ho_db_sp_ro.* from sec_us_ho_db_sp_ro inner join (select ID from sec_us_ho_db_sp where STATE='R') removed where sec_us_ho_db_sp_ro.US_HO_DB_SP_ID = removed.ID and RO_ID like roidvalue;

                delete from sec_tmp_storedprocedures where ID=tbidvalue;

             UNTIL (select count(*) from sec_tmp_storedprocedures) = 0
             END REPEAT;

          ELSE

             select "table type value is incorrect";

          END IF;

       END IF;


/*If the role revoked was the last role, thus user ended up without roles, then user is dropped*/
       call reconciliation('sync');

       SET tb_rolecount = (
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
             ) ids
          join sec_us_ho_db_tb_ro as uhdr
          where r.ID=uhdr.RO_ID and
          ids.ID=uhdr.US_HO_DB_TB_ID
          );
          
       SET sp_rolecount = (
          select count(*)
          from sec_roles as r join (
             select ID
             from sec_us_ho_db_sp a
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
             ) ids
          join sec_us_ho_db_sp_ro as uhdr
          where r.ID=uhdr.RO_ID and
          ids.ID=uhdr.US_HO_DB_SP_ID
          );
       
       SET rolecount = sp_rolecount + tb_rolecount;

       IF rolecount < 1 AND (rolein != 'ALL' or rolein != 'all') THEN

           SET @d = CONCAT('drop user "', usernamein , '"@"' , hostnamein , '"');

	       PREPARE dropcom FROM @d;
		   EXECUTE dropcom;
		   
		   SET @USID = (select ID from sec_users where USERNAME=usernamein);
		   SET @HOID = (select ID from sec_hosts where HOSTNAME=hostnamein);
		   SET @USHOID = (select ID from sec_us_ho where US_ID=@USID and HO_ID=@HOID);
		   
		   delete from sec_users where ID=@USID;
		   delete from sec_us_ho where ID=@USHOID;
		   delete from sec_us_ho_profile where US_HO_ID=@USHOID;
		   delete from sec_us_ho_db_sp where US_ID=@USID and HO_ID=@HOID;
		   delete from sec_us_ho_db_tb where US_ID=@USID and HO_ID=@HOID;
		   
           SET @g = CONCAT('User "', usernamein , '"@"' , hostnamein , '" completely dropped from securich');
		   
		   SET @un=(SELECT SUBSTRING_INDEX(USER(),'@',1));
           SET @hn=(SELECT SUBSTRING_INDEX(USER(),'@',-1));
           INSERT INTO aud_grant_revoke (USERNAME,HOSTNAME,COMMAND,TIMESTAMP) VALUES (@un,@hn,@g,NOW());

       END IF;

    END IF;
    
    IF terminateconnections = 'Y' or terminateconnections = 'y' THEN

       select "Can't kill connections since MySQL version is prior to 5.1.8 but otherwise block worked." as Warning;
          
    END IF;

    FLUSH PRIVILEGES;

  END$$

DELIMITER ;