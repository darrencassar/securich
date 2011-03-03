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

use securich;
call create_update_role('add','role1','select');
call create_update_role('add','role1','insert');
call create_update_role('add','role1','update');
call show_roles();
call show_privileges_in_role('role1');
call grant_privileges('john' , 'machine.domain.com' , 'employees' , '' , 'alltables' , 'role1' , 'john@domain.com');
call revoke_privileges('john' , 'machine.domain.com' , 'employees' , 'salaries' , 'table' , 'role1' , 'N');
call grant_privileges('paul' , '10.0.0.2' , 'world' , '^Country' , 'regexp' , 'role1' , 'paul@domain.com');
call grant_privileges('peter' , 'localhost' , 'test' , '' , 'all' , 'role1' , 'peter@domain.com');
call show_full_user_entries('paul');
call create_update_role('add','role1','delete');
call show_full_user_entries('paul');
call set_password('paul' , '10.0.0.2' , 'e658901749cc15a1f2', 'password123');
call clone_user('paul' , '10.0.0.2' , 'judas' , '10.0.0.2' , 'judas@domain.com');
call show_full_user_entries('judas');
call show_user_privileges('judas' , '10.0.0.2' , 'world' , 'role1');
call rename_user('judas' , 'james' , 'james@domain.com');
call create_update_role('add','role2','execute');
call grant_privileges('peter' , 'localhost' , 'securich' , 'my_privileges' , 'storedprocedure' , 'role2' , 'peter@domain.com');
Connect to mysql using thirduser peter in another session:
show databases; use securich; show tables; call my_privileges('test'); show processlist;
call revoke_privileges('peter' , 'localhost' , 'test' , '' , '' , 'role1' , 'Y');
As user peter again from 2nd open instance run:
show processlist;



#typical output for grant privileges
Password for user -- judas -- contactable at -- judas@domain.com -- is -- a56df6ed415d0 --

