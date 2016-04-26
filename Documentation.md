- add\_reserved\_username('usernamein');
> Used to add a username to the reserved list of usernames

- block\_user('usernamein','hostnamein','dbnamein','terminateconnections');
> Used to block a particular user, terminating his/her connections if necessary and leave the account around to be unblocked if necessary. This is a useful feature for when a user needs temporary rights.

- clone\_user('sourceusernanme','sourcehostname','destusername','desthostname','destemailaddress');
> If you have a particular user in a team already set up and you just want to create other users likewise, why not just clone them? The new user will of course have a different password which is supplied to the creator upon creation.

- create\_update\_role('way','rolename','privilege');
> Run the above in order to create/update roles at will. Note that updates in role privileges will reflect on users having the updated role on the system. Way is either "add" or "remove", which are self-explanatory.

- drop\_role(rolename);
> Used to drop a role (as long as it is not in use).

- drop\_user('username','hostname');
> Drop user completely

- grant\_privileges\_reverse\_reconciliation('username','hostname','databasename','tablename','tabletype','rolename','emailaddress');
> Used in conjunction with `mysql_reconciliation` to reconcile MySQL grants with Securich tables.

- grant\_privileges('username','hostname','databasename','tablename','tabletype','rolename','emailaddress');
> Used to create a user with any particular combination/privileges. The tablename should be left empty if database / global level privileges are to be assigned. Note that rolename can not be substituted with all in this case. The limitations on length of each field are:
```
	FIELD           MAX LENGTH
	username           16
	hostname           60
	databasename       64
	tablename          64
	tabletype          16
	rolename           60
	emailaddress       50
```
> Failure to abide to the limitations will cause truncation of any of the above parameters.

> table type / tablename can be:
```
    tablename            -   tabletype        
                         -   all              -   db.*                         -   used generally like `grant privilege on db.- to 'user'@'hostname';`
                         -   alltables        -   db.tb1 db.tb2 db.tb3 etc     -   for all tables separately
    tablename            -   singletable      -   tb1                          -   for individual tables `grant privilege on db.tb1 to 'user'@'hostname';`
    regular expression   -   regexp           -   tb1 2tb but not table3       -   this uses regexp ---
    procedure name       -   storedprocedure  -   pr1                          -   for individual procedures
```
> > --- note that for regexp usage, if tables need to have a common prefix the best way would be to add a `^` in front of the prefix i.e. `^`prefix


> Granting privileges on a table which does not exist yet will automatically grant a create on that table so the user can create it automatically.

- help('storedprocedurenamein');
> Displays the help about each individual stored procedure and how to use it

- my\_privileges('dbname');
> This script is to be executed by any user (if grant has been permitted by the dba to run it) thus letting any user know what privileges he / she has. It is not totally recommended but might be helpful in development, qa and uat environments. The user can either type in a dbname he likes or '`*`' to get a full detailed list of privileges he/she got on individual tables, stored procedures / databases.

- mysql\_reconciliation();
> Used in conjunction with `grant_privileges_reverse_reconciliation` to reconcile MySQL grants with Securich tables.

- password\_check();
> This is password\_check, a procedure used to check for password discrepancies between securich and mysql.

- reconciliation('value');
> This list ignores reserved\_usernames privileges as well as the privilege 'usage'. It caters both for database privileges as well as for global privileges and supplies the difference between the the securich package privileges and those actually in the mysql system. Using parameter 'list' provides the differences explaining where a particular grant is found thus implying where it is not found (MySQL meaning it is found in MySQL database and not in securich database and vice versa). The parameter 'sync' can be used to re-synchronize the two systems thus obtaining a consistent state.

- remove\_reserved\_username('usernamein');
> Does the opposite of add\_reserved\_username, removes a username from the reserved list

- rename\_user\_at\_host('username','hostname','newusername','newhostname');
> Rename username@hostname to newusername@newhostname. It takes care of all the necessary changes and makes sure the old username@hostname grants are revoked completely.

- rename\_user('oldusername','newusername','newemailaddress');
> Renames an old user to the new username leaving all privileges intact and changing only the password and the email address.

- revoke\_privileges('username','hostname','databasename','tablename','tabletype','rolename','terminateconnections');
> Revokes a privilege for a particular combination of username / hostname / databasename / tablename / role. The terminateconnectionsy is there to kill all threads for a particular user if set to Y which is revoked. Should you not want to cut off the user, just substitute it with n and the user won't be able to connect next time round but current connections remain intact. - tabletype should either be `table` (for a table), `storedprocedure` (for a stored proc) or `all` for the whole database.

- set\_my\_password(oldpasswordin, newpasswordin);
> Used by users to set their own password.

- set\_password\_expirable('username','setting');
> Set a user to have an expirable password (for devs and human users) or not (for application, replication or other non human users).

- set\_password('username','hostname','oldpassword','newpassword');
> Changes password for any user (if current user is root), otherwise changes own password if current user is not root. can change the password up to 11times in 1 day and stores the last 5 passwords which were not changed for at least 24hrs. Does not permit the new password to be the same as any of the old passwords. Resets update count if more than 24hrs passed from last first update of the day. Password must be longer than '10 characters (configurable amount through sec\_config.password\_length)'. Complexity requirements are set on sec\_config:

> password\_length\_check
> password\_dictionary\_check
> password\_lowercase\_check
> password\_uppercase\_check
> password\_number\_check
> password\_special\_character\_check
> password\_username\_check
> Root user doesn't need to abide to the above password restrictions when creating a new user since the latter will have to change the password and set one of his own.

> In order for a user to change one's old password, the user needs to supply the old password apart from the new one as well.

- show\_full\_user\_entries('username');
> Checks the roles assigned to a particular user and on which database, table and from which host those privileges can be used

- show\_privileges\_in\_role('rolename');
> Shows a list of privileges belonging to a particular role

- show\_privileges();
> Shows a list of privileges and their level of access

- show\_reserved\_usernames();
> Used to list the usernames currently set as reserved.

- show\_roles();
> Run the above in order to check which roles are available

- show\_user\_entries('username');
> Checks the roles assigned to a particular user and on which database and from which host those privileges can be used

- show\_user\_list();
> Run the above in order to obtain a list of user@host present in the system

- show\_user\_privileges('username','hostname','databasename','rolename');
> Lets the administrator check the privileges a user has on that database or place 'all' instead of 'rolename' in order to have a look at all the privileges on that particular combination.

- show\_users\_with\_privilege('privilege','databasename','tablename');
> Shows a list of users who have been granted a particular privilege on a particular table in a particular database.

- unblock\_user ( 'usernamein','hostnamein','dbnamein' );
> Unblocks any user specified if it had blocked privileges / roles

- update\_databases\_tables\_storedprocedures\_list();
> Updates the tables and databases tables (sec\_tables, sec\_databases, sec\_storecprocedures and their relationship table sec\_db\_tb and sec\_db\_sp) with the full list of tables / databases / storedprocedures.


sec\_config:
```
   +----------------------------------------------+-------+
   | PROPERTY                                     | VALUE |
   +----------------------------------------------+-------+
   | mysql_to_securich_reconciliation_in_progress | 0     | - used by the system
   | password_length                              | 10    | - set by user for password complexity checks
   | password_length_check                        | 1     | - set by user for password complexity checks
   | password_dictionary_check                    | 1     | - set by user for password complexity checks
   | password_lowercase_check                     | 1     | - set by user for password complexity checks
   | password_uppercase_check                     | 1     | - set by user for password complexity checks
   | password_number_check                        | 1     | - set by user for password complexity checks
   | password_special_character_check             | 1     | - set by user for password complexity checks
   | password_username_check                      | 1     | - set by user for password complexity checks
   | sec_mode                                     | 0     | - security mode is 0 (lenient) or 9 (strict)
   | priv_mode                                    | safe  | - privilege mode is safe in order to not loose any privileges when syncing
   | admin_user                                   | root  | - admin user set by system
   +----------------------------------------------+-------+
```

sec\_mode 0 permits granting of privileges on any object / database, 9 prohibits granting of privileges on mysql database.
priv\_mode safe is used to sync securich to mysql and vice versa without loosing any privileges. If safe is changed then calling reconciliation('sync') would just sync mysql with securich loosing any privs granted via MySQL.


Note that the `mysql` database is a VERY SENSITIVE database and no one should have direct privileges to that database apart from root and any user used to install securich and other sensitive accounts (preferibly kept to a minimum)
Having said that securich is by default more flexible and securing it requires the followign command making securich more strict towards mistakes, oversights or carelessness:
update sec\_config set conf\_value='9' where property='sec\_mode';


passwordrotate.sh
-- Cronned script which checks for users having passwords older than 30 days, alerting the users to change the password. This script only runs for users type user not users type applications (further user types can be added in the future).