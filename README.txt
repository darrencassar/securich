INSTALLATION

   Drop all users apart from root@localhost and msandbox@localhost if you are using MySQL sandbox.
   create database securich;

   tar -zxf securich-<version>.tar.gz

   source db/securich.sql
   source db/data.sql

   source procedures/*.sql

WEB

   http://www.securich.com
   http://code.google.com/p/securich/


DOCUMENTATION

###########################################################################################
#####################################  PLEASE NOTE!!  #####################################
###########################################################################################
##                                                                                       ##
## STRICTLY USE ROOT OR OTHER RESERVED USERNAMES USERS TO GRANT REVOKE OR RECONCILE.     ##
## PLEASE NOTE THAT ITS BEST THAT ONLY ROOT SHOULD HAVE ACCESS TO THE SECURITY DATABASE  ##
## AS THIS IS A VERY SECURITY SENSITIVE PLUGIN.                                          ##
##                                                                                       ##
## GRANTING PRIVILEGES ON ANY OF MYSQL OR SECURITY DATABASES IS A SECURITY RISK.         ##
## THIS SHOULD BE AVOIDED AT ALL COSTS BUT IS STILL PERMITTED THROUGH THE STORED         ##
## PROCEDURES JUST IN CASE ANYONE NEEDS THAT FUNCTIONALITY.                              ##
##                                                                                       ##
## FURTHER INFORMATION ABOUT MYSQL PRIVILEGES CAN BE FOUND AT:                           ##
## http://dev.mysql.com/doc/refman/5.1/en/privileges-provided.html#priv_show-databases   ##
##                                                                                       ##
###########################################################################################
###########################################################################################


THE ONLY TWO STORED PROCEDURES WHICH USERS MIGHT BE ALLOWED TO CALL UPON ARE set_password AND my_privileges.
ALL OTHER STORED PROCEDURES ARE VERY SENSITIVE AND POTENTIALLY DANGEROUS.

note that stored proc check_roles was renamed to show_roles
note that stored proc check_role_privileges was renamed to show_privileges_in_roles
note that stored proc check_user_privileges was renamed to show_user_privileges
note that stored proc check_privilege_users was renamed to show_users_with_privilege
note that stored proc check_user_list was renamed to show_user_list
note that stored proc check_user_entries was renamed to show_user_entries
note that stored proc check_full_user_entries was renamed to show_full_user_entries


The stored procedures currently included are:

1) add_reserved_username('usernamein'); (version 0.1.4)
-- Used to add a username to the reserved list of usernames

2) block_user('usernamein','hostnamein','dbnamein','terminateconnections'); (version 0.1.4)
-- Used to block a particular user, terminating his/her connections if necessary and leave the account around to be unblocked if necessary. This is a useful feature for when a user needs temporary rights.

3) show_full_user_entries('username'); (version 0.2.0)
-- Checks the roles assigned to a particular user and on which database, table and from which host those privileges can be used

4) show_users_with_privilege('privilege'); (version 0.2.0)
-- Shows a list of users who have been granted a particular privilege
    show_users_with_privilege('privilege','databasename','tablename') (version 0.1.2);
-- Shows a list of users who have been granted a particular privilege on a particular table in a particular database.

5) show_privileges_in_roles('rolename'); (version 0.2.0)
-- Shows a list of privileges belonging to a particular role

6) show_roles(); (version 0.2.0)
-- Run the above in order to check which roles are available

7) show_user_entries('username'); (version 0.2.0)
-- Checks the roles assigned to a particular user and on which database and from which host those privileges can be used

8) show_user_list(); (version 0.2.0)
-- Run the above in order to obtain a list of user@host present in the system

9) show_user_privileges('username','hostname','databasename','rolename'); (version 0.2.0)
-- Lets the administrator check the privileges a user has on that database or place 'all' instead of 'rolename' in order to have a look at all the privileges on that particular combination.

10) clone_user('sourceusernanme','sourcehostname','destusername','desthostname','destemailaddress'); (version 0.1.2)
-- If you have a particular user in a team already set up and you just want to create other users likewise, why not just clone them? The new user will of course have a different password which is supplied to the creator upon creation.

11) create_update_role('way','rolename','privilege'); (version 0.1.2) (version 0.1.4 added 'way')
-- Run the above in order to create/update roles at will. Note that updates in role privileges will reflect on users having the updated role on the system. Way is either "add" or "remove", which are self-explanatory.

12) grant_privileges('username','hostname','databasename','tablename','tabletype','rolename','emailaddress'); (version 0.1.1)
-- Used to create a user with any particular combination/privileges. The tablename should be left empty if database / global level privileges are to be assigned. Note that rolename can not be substituted with all in this case. The limitations on length of each field are:
FIELD           MAX LENGTH
username      - 16
hostname      - 60
databasename  - 64
tablename     - 64
tabletype     - 16
rolename      - 60
emailaddress  - 50

Failure to abide to the limitations will cause truncation of any of the above parameters.

table type / tablename can be:
tabletype           -   tablename            -   description
all                 -                        -   all database         -   db.*                         -   used generally like `grant privilege on db.* to 'user'@'hostname';`
alltables           -                        -   all tables           -   db.tb1 db.tb2 db.tb3 etc     -   for all tables separately (used when there is a need to grant on all and revoke on a few tables)
singletable         -   tablename            -   single table         -   tb1                          -   for individual tables `grant privilege on db.tb1 to 'user'@'hostname';`
regexp              -   regular expression   -   regexp               -   tb1 2tb but not table3       -   this uses regexp ***
storedprocedure     -   procedure name       -   single procedurure   -   pr1                          -   for individual procedures
*** note that for regexp usage, if tables need to have a common prefix the best way would be to add a ^ in front of the prefix i.e. ^prefix

13) grant_privileges_reverse_reconciliation('username','hostname','databasename','tablename','tabletype','rolename','emailaddress'); (version 0.1.1)
-- Used in conjunction with `reverse_reconciliation` to reconcile MySQL grants with Securich tables.

14) help('storedprocedurenamein'); (version 0.1.4)
-- Displays the help about each individual stored procedure and how to use it

15) my_privileges('dbname'); (version 0.1.2)
-- This script is to be executed by any user (if grant has been permitted by the dba to run it) thus letting any user know what privileges he / she has. It is not totally recommended but might be helpful in development, qa and uat environments. The user can either type in a dbname he likes or '*' to get a full detailed list of privileges he/she got on individual tables, stored procedures / databases.

16) reconciliation('value'); (version 0.1.1)
-- This list ignores root privileges as well as the privilege 'usage'. It caters both for database privileges as well as for global privileges and supplies the difference between the the securich package privileges and those actually in the mysql system. Using parameter 'list' provides the differences explaining where a particular grant is found thus implying where it is not found (MySQL meaning it is found in MySQL database and not in securich database and vice versa). The parameter 'sync' can be used to re-synchronize the two systems thus obtaining a consistent state.

17) remove_reserved_username('usernamein'); (version 0.1.4)
-- Does the opposite of add_reserved_username, removes a username from the reserved list

18) rename_user('oldusername','newusername','newemailaddress');
-- Renames an old user to the new username leaving all privileges intact and changing only the password and the email address.

19) reverse_reconciliation();
-- Used in conjunction with `grant_privileges_reverse_reconciliation` to reconcile MySQL grants with Securich tables.

20) revoke_privileges('username','hostname','databasename','tablename','tabletype','rolename','terminateconnections');
-- Revokes a privilege for a particular combination of username / hostname / databasename / tablename / role. The terminateconnectionsy is there to kill all threads for a particular user if set to Y which is revoked. Should you not want to cut off the user, just substitute it with n and the user won't be able to connect next time round but current connections remain intact. - tabletype should either be table (for a table) and storedprocedure (for a stored proc).

21) set_password('username','hostname','oldpassword','newpassword'); (version 0.1.1) (version 0.1.4 added `oldpassword`)
-- Changes password for any user (if current user is root), otherwise changes own password if current user is not root. can change the password up to 11times in 1 day and stores the last 5 passwords which were not changed for at least 24hrs. Does not permit the new password to be the same as any of the old passwords. Resets update count if more than 24hrs passed from last first update of the day. Password must be longer than 10 characters, contain at least one number, one letter and one special character (minimum complexity requirement). In order for a user to change one's old password, the user needs to supply the old password apart from the new one as well.

22) unblock_user ( 'usernamein','hostnamein','dbnamein' )
-- Unblocks any user specified if it had blocked privileges / roles

23) update_databases_tables_storedprocedures_list();
-- Updates the tables and databases tables (sec_tables, sec_databases, sec_storecprocedures and their relationship table sec_db_tb and sec_db_sp) with the full list of tables / databases / storedprocedures.

24) password_check();
-- This is password_check, a script used to check for password discrepancies between securich and mysql.

Note that the `mysql` database is purposely not included in the `sec_databases` table as it is a VERY SENSITIVE database and no one should have direct privileges to that database apart from root and other sensitive accounts (preferibly kept to a minimum)


passwordrotate.sh
-- Cronned script which checks for users having passwords older than 30 days, alerting the users to change the password. This script only runs for users type user not users type applications (further user types can be added in the future).
