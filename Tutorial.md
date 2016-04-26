# Introduction #

Here is a list of commands available for use with securich (0.1.2). As from 0.1.4 there is a `help` stored procedure which you can use by issuing a `call help();`.

# Details #

Securich Tutorial (for securich version 0.2.1)

## Tutorial ##

  1. Download it,
  1. Install it,
  1. Create a role named "role1" having privileges "select insert update"
  1. Check roles,
  1. Check role privileges,
  1. Create a first user john@machine.domain.com (granting privileges on a whole database employees apart from one table),
  1. Create a second user paul@10.0.0.2 (granting privileges on all tables in world having word Country in them),
  1. Create a third user peter@localhost (granting privileges on the database test),
  1. Check user privileges for (paul),
  1. Update role created above and see changes (add delete to role 1),
  1. Update password (for paul) and see changes,
  1. Clone user paul to judas,
  1. Check user privileges
  1. Check user,
  1. Rename user judas to james,
  1. Revoke privileges from third user disconnecting any existing connections from that user (useful if a security breach is suspected or if you are a security paranoid thus wanting to make sure the person you are blocking out won't have any more access as from that point onwards).

---

### Steps ###

  1. Go to www.securich.com downloads page or code,gogle.com/p/securich and download the install script
  1. Untar the install script and run it using ./securich\_install.sh and it'll install everything automatically
```
[darrencassar@mac /mysql/securich/securich_install 14:43:26]$ ./securich_install.sh 
                                                             
                                                 __          
                                      __        /\ \         
   ____     __    ___   __  __  _ __ /\_\    ___\ \ \___     
  /',__\  /'__ \ /'___\/\ \/\ \/\ '__\/\ \  /'___\ \  _  \   
 /\__,  \/\  __//\ \__/\ \ \_\ \ \ \/ \ \ \/\ \__/\ \ \ \ \  
 \/\____/\ \____\ \____/\ \____/\ \_\  \ \_\ \____/\ \_\ \_\ 
  \/___/  \/____/\/____/ \/___/  \/_/   \/_/\/____/ \/_/\/_/ 
                                                             
 brought to you by Darren Cassar 
 http://www.mysqlpreacher.com 


Anytime you need to cancel installation just press ( Ctrl + C )



Enter version number (default 0.2.1 i.e. latest version): 

Which kind of installation would you like to do?
1. Install from file on disk 
2. Download and install (recommended) 
Enter choice (default 2): 1
Installation starting

Do you wish to:
1. Do a fresh install 
2. Upgrade from a previous version 
Enter choice (default 1): 

Would you like to import current MySQL grants to Securich:
1. Import
2. No start from scratch (This will clear out any non reserved usernames (not 'root','msandbox' etc) grants so please be sure of your answer)
Enter choice (default 1): 2

Enter mysql root Password (default ''): 
Would you like to connect using:
1. TCP/IP
2. Socket file
Enter choice (default 1): 
Enter mysql Hostname/IP (default '127.0.0.1'): 
Enter mysql Port (default '3306'): 3308
Installation complete

```
> Log into mysql mysql -u root -p -h 127.0.0.1 -P 3308
  1. use securich;
  1. call create\_update\_role('add','role1','select');
  1. call create\_update\_role('add','role1','insert');
  1. call create\_update\_role('add','role1','update');
  1. call show\_roles();
  1. call show\_privileges\_in\_roles('role1');
  1. call grant\_privileges('john' , 'machine.domain.com' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com');
  1. call revoke\_privileges('john' , 'machine.domain.com' , 'employees' , 'salaries' , 'table' , 'role1' , 'N');
  1. call grant\_privileges('paul' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'paul@domain.com');
  1. call grant\_privileges('peter' , 'localhost' , 'test' , '' , 'all' , 'role1' , 'peter@domain.com');
  1. call show\_full\_user\_entries('paul');
  1. call create\_update\_role('add','role1','delete');
  1. call show\_full\_user\_entries('paul');
  1. call set\_password('paul' , '10.0.0.2' , '', 'password123');
  1. call clone\_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');
  1. call show\_full\_user\_entries('judas');
  1. call show\_user\_privileges('judas' , '10.0.0.2' , 'world' , 'role1');
  1. call rename\_user('judas' , 'james' , 'james@domain.com');
  1. call create\_update\_role('add','role2','execute');
  1. call grant\_privileges('peter' , 'localhost' , 'securich' , 'my\_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');

Connect to mysql using thirduser peter in another session:
  1. show databases;
  1. use securich;
  1. show tables;
  1. call my\_privileges('test');
  1. show processlist;

  1. call revoke\_privileges('peter' , 'localhost' , 'test' , '' , '' , 'role1' , 'Y');
  1. call revoke\_privileges('peter' , 'localhost' , 'securich' , 'my\_privileges' , 'storedprocedure' , 'role2' , 'Y');

As user peter again from 2nd open instance run:
  1. show processlist;

### Log ###

```
[darrencassar@mac /mysql/securich/securich_install 15:03:54]$ mysql -u root -p -h 127.0.0.1 -P 3308 
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 534
Server version: 5.1.37 MySQL Community Server (GPL)

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use securich; 
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> call create_update_role('add','role1','select'); 
Query OK, 1 row affected, 6 warnings (0.04 sec)

mysql> call create_update_role('add','role1','insert'); 
Query OK, 1 row affected (0.07 sec)

mysql> call create_update_role('add','role1','update');
Query OK, 1 row affected (0.11 sec)

mysql> call show_roles();
+----+-------+
| ID | ROLE  |
+----+-------+
|  1 | read  | 
|  2 | write | 
|  3 | role1 | 
+----+-------+
3 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call show_privileges_in_roles('role1');
+-----------+
| PRIVILEGE |
+-----------+
| INSERT    | 
| SELECT    | 
| UPDATE    | 
+-----------+
3 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call grant_privileges('john' , 'machine.domain.com' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com');
+------------------------------------------------------------------------------------------------+
| USER_PASSWORD                                                                                  |
+------------------------------------------------------------------------------------------------+
| Password for user -- john -- contactable at -- john@domain.com -- is -- 580110942ccccd1ece2 -- | 
+------------------------------------------------------------------------------------------------+
1 row in set (0.18 sec)

Query OK, 0 rows affected (0.18 sec)

mysql> call revoke_privileges('john' , 'machine.domain.com' , 'employees' , 'salaries' , 'table' , 'role1' , 'N');
Query OK, 0 rows affected, 1 warning (0.15 sec)

mysql> call grant_privileges('paul' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'paul@domain.com');
+-------------------------------------------------------------------------------------------------+
| USER_PASSWORD                                                                                   |
+-------------------------------------------------------------------------------------------------+
| Password for user -- paul -- contactable at -- paul@domain.com -- is -- 177c0e20b22c26afdf39 -- | 
+-------------------------------------------------------------------------------------------------+
1 row in set (0.18 sec)

Query OK, 0 rows affected (0.19 sec)

mysql> call grant_privileges('peter' , 'localhost' , 'test' , '' , 'all' , 'role1' , 'peter@domain.com');
+--------------------------------------------------------------------------------------------------+
| USER_PASSWORD                                                                                    |
+--------------------------------------------------------------------------------------------------+
| Password for user -- peter -- contactable at -- peter@domain.com -- is -- 2f791928c4ef44ddd7c -- | 
+--------------------------------------------------------------------------------------------------+
1 row in set (0.13 sec)

Query OK, 0 rows affected (0.13 sec)

mysql> call show_full_user_entries('paul');
+----------+----------+--------------+-----------------+-------+-----------+-------+
| USERNAME | HOSTNAME | DATABASENAME | TABLENAME       | ROLE  | PRIVILEGE | STATE |
+----------+----------+--------------+-----------------+-------+-----------+-------+
| paul     | 10.0.0.2 | world        | country         | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | UPDATE    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | UPDATE    | A     | 
+----------+----------+--------------+-----------------+-------+-----------+-------+
6 rows in set (0.19 sec)

Query OK, 0 rows affected, 4 warnings (0.19 sec)

mysql> call create_update_role('add','role1','delete');
Query OK, 1 row affected (0.08 sec)

mysql> call show_full_user_entries('paul');
+----------+----------+--------------+-----------------+-------+-----------+-------+
| USERNAME | HOSTNAME | DATABASENAME | TABLENAME       | ROLE  | PRIVILEGE | STATE |
+----------+----------+--------------+-----------------+-------+-----------+-------+
| paul     | 10.0.0.2 | world        | country         | role1 | DELETE    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | UPDATE    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | DELETE    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | UPDATE    | A     | 
+----------+----------+--------------+-----------------+-------+-----------+-------+
8 rows in set (0.04 sec)

Query OK, 0 rows affected (0.04 sec)

mysql> call set_password('paul' , '10.0.0.2' , '2f791928c4ef44ddd7c', 'password123');
Query OK, 1 row affected (0.00 sec)

mysql> call clone_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');
+----------------------------------------------------------------------------------------------+
| USER_PASSWORD                                                                                |
+----------------------------------------------------------------------------------------------+
| Password for user -- judas -- contactable at -- judas@domain.com -- is -- eb5186cfa4b1c21 -- | 
+----------------------------------------------------------------------------------------------+
1 row in set (0.05 sec)

Query OK, 1 row affected, 3 warnings (0.14 sec)

mysql> call show_full_user_entries('judas');
+----------+----------+--------------+-----------------+-------+-----------+-------+
| USERNAME | HOSTNAME | DATABASENAME | TABLENAME       | ROLE  | PRIVILEGE | STATE |
+----------+----------+--------------+-----------------+-------+-----------+-------+
| judas    | 10.0.0.2 | world        | country         | role1 | DELETE    | A     | 
| judas    | 10.0.0.2 | world        | country         | role1 | INSERT    | A     | 
| judas    | 10.0.0.2 | world        | country         | role1 | SELECT    | A     | 
| judas    | 10.0.0.2 | world        | country         | role1 | UPDATE    | A     | 
| judas    | 10.0.0.2 | world        | CountryLanguage | role1 | DELETE    | A     | 
| judas    | 10.0.0.2 | world        | CountryLanguage | role1 | INSERT    | A     | 
| judas    | 10.0.0.2 | world        | CountryLanguage | role1 | SELECT    | A     | 
| judas    | 10.0.0.2 | world        | CountryLanguage | role1 | UPDATE    | A     | 
+----------+----------+--------------+-----------------+-------+-----------+-------+
8 rows in set (0.06 sec)

Query OK, 0 rows affected (0.06 sec)

mysql> call show_full_user_entries('paul');
+----------+----------+--------------+-----------------+-------+-----------+-------+
| USERNAME | HOSTNAME | DATABASENAME | TABLENAME       | ROLE  | PRIVILEGE | STATE |
+----------+----------+--------------+-----------------+-------+-----------+-------+
| paul     | 10.0.0.2 | world        | country         | role1 | DELETE    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | country         | role1 | UPDATE    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | DELETE    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | INSERT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | SELECT    | A     | 
| paul     | 10.0.0.2 | world        | CountryLanguage | role1 | UPDATE    | A     | 
+----------+----------+--------------+-----------------+-------+-----------+-------+
8 rows in set (0.06 sec)

Query OK, 0 rows affected (0.06 sec)

mysql> call show_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');
+-----------+
| PRIVILEGE |
+-----------+
| DELETE    | 
| INSERT    | 
| SELECT    | 
| UPDATE    | 
+-----------+
4 rows in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

mysql> call rename_user('judas' , 'james' , 'james@domain.com');
+----------------------------------------------------------------------------------------------+
| USER_PASSWORD                                                                                |
+----------------------------------------------------------------------------------------------+
| Password for user -- james -- contactable at -- james@domain.com -- is -- 333b56f7a5d108a -- | 
+----------------------------------------------------------------------------------------------+
1 row in set (0.10 sec)

Query OK, 0 rows affected (0.10 sec)

mysql> call create_update_role('add','role2','execute');
Query OK, 1 row affected (0.09 sec)

mysql> call grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');
Query OK, 0 rows affected (0.12 sec)

mysql> show processlist;
+-----+-------+-----------------+----------+---------+------+-------+------------------+
| Id  | User  | Host            | db       | Command | Time | State | Info             |
+-----+-------+-----------------+----------+---------+------+-------+------------------+
| 534 | root  | localhost:53347 | securich | Query   |    0 | NULL  | show processlist | 
| 535 | peter | localhost:53363 | NULL     | Sleep   |    7 |       | NULL             | 
+-----+-------+-----------------+----------+---------+------+-------+------------------+
2 rows in set (0.00 sec)

mysql>




.....
.....
.....

Logging in as peter

[darrencassar@mac ~ 15:07:11]$ mysql -u peter -p -h 127.0.0.1 -P 3308
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 535
Server version: 5.1.37 MySQL Community Server (GPL)

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases; 
+--------------------+
| Database           |
+--------------------+
| information_schema | 
| securich           | 
+--------------------+
2 rows in set (0.00 sec)

mysql> use securich; 
Database changed
mysql> show tables; 
Empty set (0.00 sec)

mysql> call my_privileges('test'); 
+-----------+
| PRIVILEGE |
+-----------+
| DELETE    | 
| INSERT    | 
| SELECT    | 
| UPDATE    | 
+-----------+
4 rows in set (0.00 sec)

Query OK, 0 rows affected (0.01 sec)

mysql> show processlist;
+-----+-------+-----------------+----------+---------+------+-------+------------------+
| Id  | User  | Host            | db       | Command | Time | State | Info             |
+-----+-------+-----------------+----------+---------+------+-------+------------------+
| 535 | peter | localhost:53363 | securich | Query   |    0 | NULL  | show processlist | 
+-----+-------+-----------------+----------+---------+------+-------+------------------+
1 row in set (0.00 sec)



.....
.....
.....

in the meantime as root:

mysql> call revoke_privileges('peter' , 'localhost' , 'test' , '' , '' , 'role1' , 'Y');
Query OK, 0 rows affected (0.16 sec)

mysql>

.....
.....
.....

back as peter:

mysql> show processlist;
ERROR 2006 (HY000): MySQL server has gone away
No connection. Trying to reconnect...
ERROR 1045 (28000): Access denied for user 'peter'@'localhost' (using password: YES)
ERROR: 
Can't connect to the server

mysql>

```