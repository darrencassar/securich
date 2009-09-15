USE securich;
CALL create_update_role('add','role1','select');
CALL create_update_role('add','role1','insert');
CALL create_update_role('add','role1','update');
CALL check_roles();
CALL check_role_privileges('role1');

CREATE DATABASE world;
USE world;
CREATE TABLE country (a INT);
CREATE TABLE country_population (a INT);
CREATE TABLE city (a INT);
CREATE TABLE continent (a INT);
CREATE TABLE gdp (a INT);

CREATE DATABASE employees;
USE employees;
CREATE TABLE trade (a INT);
CREATE TABLE salary (a INT);
CREATE TABLE vacancies (a INT);
CREATE TABLE salary_increase (a INT);

USE securich;
CALL grant_privileges('john3' , 'machine.domain.com' , 'testing' , '' , 'all' , 'role1' , 'john@domain.com');
CALL check_full_user_entries('john3');
CALL revoke_privileges('john3' , 'machine.domain.com' , 'testing' , '' , 'table' , 'role1' , 'N');
CALL check_full_user_entries('paul');
CALL grant_privileges('paul' , '10.0.0.2' , 'world' , '^country' , 'regexp' , 'role1' , 'paul@domain.com');
CALL grant_privileges('peter' , 'localhost' , 'test' , '' , 'all' , 'role1' , 'peter@domain.com');
CALL check_full_user_entries('paul');
CALL create_update_role('add','role1','delete');
CALL check_full_user_entries('paul');
CALL set_password('paul' , '10.0.0.2' ,'', 'password123');
CALL clone_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');
CALL check_full_user_entries('judas');
CALL check_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');
CALL rename_user('judas' , 'james' , 'james@domain.com');
CALL create_update_role('add','role2','execute');
CALL grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');



#typical output for grant privileges
Password for user -- judas -- contactable at -- judas@domain.com -- is -- a56df6ed415d0 --