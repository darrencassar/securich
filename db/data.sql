USE mysql;

### DROP USER ''@'%';
### DROP USER ''@'localhost';

flush privileges;

USE securich;

INSERT INTO `sec_config` (`PROPERTY`,`VALUE`) values ('reverse_reconciliation_in_progress',0);

INSERT INTO `sec_databases` (`ID`,`DATABASENAME`) VALUES
(1,'');

INSERT INTO `sec_tables` (`ID`,`TABLENAME`) VALUES
(1,'');

INSERT INTO `sec_storedprocedures` (`ID`,`STOREDPROCEDURENAME`) VALUES
(1,'');

INSERT  INTO `sec_privileges`(`ID`,`PRIVILEGE`,`TYPE`) VALUES
(1,'SELECT',0),
(2,'INSERT',0),
(3,'UPDATE',0),
(4,'DELETE',0),
(5,'ALTER',0),
(6,'CREATE',0),
(7,'DROP',0),
(8,'INDEX',0),
(9,'REFERENCES',0),
(10,'CREATE TEMPORARY TABLES',2),
(11,'LOCK TABLES',2),
(12,'TRIGGER',2),
(13,'CREATE VIEW',2),
(14,'SHOW VIEW',2),
(15,'ALTER ROUTINE',1),
(16,'CREATE ROUTINE',2),
(17,'EXECUTE',1),
(18,'EVENT',2),
(19,'CREATE USER',3),
(20,'PROCESS',3),
(21,'RELOAD',3),
(22,'REPLICATION CLIENT',3),
(23,'REPLICATION SLAVE',3),
(24,'SHOW DATABASES',3),
(25,'SHUTDOWN',3),
(26,'SUPER',3),
(27,'FILE',3);


INSERT INTO `sec_roles` VALUES
(1,'read'),
(2,'write');

INSERT INTO `sec_reserved_usernames` VALUES
(1,'root'),
(2,''),
(3,'msandbox');

INSERT INTO `sec_ro_pr` VALUES
(1,1,1),
(3,2,2),
(4,2,3),
(5,2,4);

INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (1,'','\r\n   Securich is there to help you administer and secure your data easier and in a more friendly manner.\r\n\r\n   Cheers,\r\n   Darren\r\n');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (2,'add_reserved_username','add_reserved_username(\'usernamein\'); (version 0.1.4)\r\n-- Used to add a username to the reserved list of usernames');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (3,'block_user','block_user(\'usernamein\',\'hostnamein\',\'dbnamein\',\'terminateconnections\'); (version 0.1.4)\r\n-- Used to block a particular user, terminating his/her connections if necessary and leave the account around to be unblocked if necessary. This is a useful feature for when a user needs temporary rights.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (4,'show_full_user_entries','show_full_user_entries(\'username\'); (version 0.1.1)\r\n-- Checks the roles assigned to a particular user and on which database, table and from which host those privileges can be used');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (5,'show_users_with_privilege','show_users_with_privilege(\'privilege\'); (version 0.1.1)\r\n-- Shows a list of users who have been granted a particular privilege\r\n    show_users_with_privilege(\'privilege\',\'databasename\',\'tablename\') (version 0.1.2);\r\n-- Shows a list of users who have been granted a particular privilege on a particular table in a particular database.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (6,'show_privileges_in_roles','show_privileges_in_roles(\'rolename\'); (version 0.1.1)\r\n-- Shows a list of privileges belonging to a particular role');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (7,'show_roles','show_roles(); (version 0.1.1)\r\n-- Run the above in order to check which roles are available');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (8,'show_user_entries','show_user_entries(\'username\'); (version 0.1.1)\r\n-- Checks the roles assigned to a particular user and on which database and from which host those privileges can be used');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (9,'show_user_list','show_user_list(); (version 0.1.1)\r\n-- Run the above in order to obtain a list of user@host present in the system');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (10,'show_user_privileges','show_user_privileges(\'username\',\'hostname\',\'databasename\',\'rolename\'); (version 0.1.1)\r\n-- Lets the administrator check the privileges a user has on that database or place \'all\' instead of \'rolename\' in order to have a look at all the privileges on that particular combination.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (11,'clone_user','clone_user(\'sourceusernanme\',\'sourcehostname\',\'destusername\',\'desthostname\',\'destemailaddress\'); (version 0.1.2)\r\n-- If you have a particular user in a team already set up and you just want to create other users likewise, why not just clone them? The new user will of course have a different password which is supplied to the creator upon creation.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (12,'create_update_role','create_update_role(\'way\',\'rolename\',\'privilege\'); (version 0.1.2) (version 0.1.4 added \'way\') \r\n-- Run the above in order to create/update roles at will. Note that updates in role privileges will reflect on users having the updated role on the system. The \'way\' can either be \"add\" or \"remove\" which are self-explanatory');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (13,'grant_privileges','grant_privileges(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'emailaddress\'); (version 0.1.1)\r\n-- Used to create a user with any particular combination/privileges. The tablename should be left empty if database / global level privileges are to be assigned. Note that rolename can not be substituted with all in this case. The limitations on length of each field are:\r\nFIELD           MAX LENGTH\r\nusername      - 16\r\nhostname      - 60\r\ndatabasename  - 64\r\ntablename     - 64\r\ntabletype     - 16\r\nrolename      - 60\r\nemailaddress  - 50\r\n\r\nFailure to abide to the limitations will cause truncation of any of the above parameters.\r\n\r\ntable type / tablename can be:\r\ntabletype           -   tablename            -   description\r\nall                 -                        -   all database         -   db.*                         -   used generally like `grant privilege on db.* to \'user\'@\'hostname\';`\r\nalltables           -                        -   all tables           -   db.tb1 db.tb2 db.tb3 etc     -   for all tables separately (used when there is a need to grant on all and revoke on a few tables)\r\nsingletable         -   tablename            -   single table         -   tb1                          -   for individual tables `grant privilege on db.tb1 to \'user\'@\'hostname\';`\r\nregexp              -   regular expression   -   regexp               -   tb1 2tb but not table3       -   this uses regexp ***\r\nstoredprocedure     -   procedure name       -   single procedurure   -   pr1                          -   for individual procedures\r\n*** note that for regexp usage, if tables need to have a common prefix the best way would be to add a ^ in front of the prefix i.e. ^prefix');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (14,'help','help(\'storedprocedurenamein\'); (version 0.1.4)\r\n-- Displays the help about each individual stored procedure and how to use it');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (15,'my_privileges','my_privileges(\'dbname\'); (version 0.1.2)\r\n-- This script is to be executed by any user (if grant has been permitted by the dba to run it) thus letting any user know what privileges he / she has. It is not totally recommended but might be helpful in development, qa and uat environments. The user can either type in a dbname he likes or \'*\' to get a full detailed list of privileges he/she got on individual tables, stored procedures / databases.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (16,'reconciliation','reconciliation(\'value\'); (version 0.1.1)\r\n-- This list ignores root privileges as well as the privilege \'usage\'. It caters both for database privileges as well as for global privileges and supplies the difference between the the securich package privileges and those actually in the mysql system. Using parameter \'list\' provides the differences explaining where a particular grant is found thus implying where it is not found (MySQL meaning it is found in MySQL database and not in securich database and vice versa). The parameter \'sync\' can be used to re-synchronize the two systems thus obtaining a consistent state.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (17,'remove_reserved_username','remove_reserved_username(\'usernamein\'); (version 0.1.4)\r\n-- Does the opposite of add_reserved_username, removes a username from the reserved list');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (18,'rename_user','rename_user(\'oldusername\',\'newusername\',\'newemailaddress\');\r\n-- Renames an old user to the new username leaving all privileges intact and changing only the password and the email address.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (19,'revoke_privileges','revoke_privileges(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'terminateconnections\');\r\n-- Revokes a privilege for a particular combination of username / hostname / databasename / tablename / role. The terminateconnectionsy is there to kill all threads for a particular user if set to Y which is revoked. Should you not want to cut off the user, just substitute it with n and the user won\'t be able to connect next time round but current connections remain intact. - tabletype should either be table (for a table) and storedprocedure (for a stored proc).');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (20,'set_password','set_password(\'username\',\'hostname\',\'oldpassword\',\'newpassword\'); (version 0.1.1) (version 0.1.4 added \'oldpassword\')\r\n-- Changes password for any user (if current user is root), otherwise changes own password if current user is not root. can change the password up to 11times in 1 day and stores the last 5 passwords which were not changed for at least 24hrs. Does not permit the new password to be the same as any of the old passwords. Resets update count if more than 24hrs passed from last first update of the day. Password must be longer than 10 characters, contain at least one number, one letter and one special character (minimum complexity requirement). In order for a user to change one\'s old password, the user needs to supply the old password apart from the new one as well.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (21,'unblock_user ','unblock_user ( \'usernamein\',\'hostnamein\',\'dbnamein\' )\r\n-- Unblocks any user specified if it had blocked privileges / roles');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (22,'update_databases_tables_storedprocedures_list','update_databases_tables_storedprocedures_list();\r\n-- Updates the tables and databases tables (sec_tables, sec_databases, sec_storecprocedures and their relationship table sec_db_tb and sec_db_sp) with the full list of tables / databases / storedprocedures.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (23,'grant_privileges_reverse_reconciliation','grant_privileges_reverse_reconciliation(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'emailaddress\'); (version 0.2.0)\r\nUsed in conjunction with `reverse_reconciliation` to reconcile MySQL grants with Securich tables.');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (24,'reverse_reconciliation','reverse_reconciliation(); (version 0.2.0)\r\nUsed in conjunction with `grant_privileges_reverse_reconciliation` to reconcile MySQL grants with Securich tables.');

CALL update_databases_tables_storedprocedures_list();
