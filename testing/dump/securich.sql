-- MySQL dump 10.13  Distrib 5.1.37, for apple-darwin9.5.0 (i386)
--
-- Host: localhost    Database: securich
-- ------------------------------------------------------
-- Server version	5.1.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aud_grant_revoke`
--

DROP TABLE IF EXISTS `aud_grant_revoke`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aud_grant_revoke` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(16) NOT NULL,
  `HOSTNAME` varchar(60) NOT NULL,
  `COMMAND` text NOT NULL,
  `TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aud_grant_revoke`
--

LOCK TABLES `aud_grant_revoke` WRITE;
/*!40000 ALTER TABLE `aud_grant_revoke` DISABLE KEYS */;
INSERT INTO `aud_grant_revoke` VALUES (1,'root','localhost','revoke UPDATE on securich.sec_users from \'trilla\'@\'localhost\'','2009-11-17 17:30:18'),(2,'root','localhost','delete from inf_grantee_privileges where GRANTEE regexp \"^\'msandbox\'\"','2009-11-17 17:30:30'),(3,'root','localhost','grant SELECT on securich.sec_users to \"trilla\"@\"localhost\"','2009-11-17 17:30:30'),(4,'root','localhost','grant INSERT on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:30'),(5,'root','localhost','grant UPDATE on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:30'),(6,'root','localhost','grant UPDATE on employees.titles to \"john\"@\"127.0.0.1\"','2009-11-17 17:30:30'),(7,'root','localhost','revoke UPDATE on employees.salaries from \'john\'@\'127.0.0.1\'','2009-11-17 17:30:31'),(8,'root','localhost','grant UPDATE on world.CountryLanguage to \"tom\"@\"10.0.0.2\"','2009-11-17 17:30:31'),(9,'root','localhost','grant DELETE on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:31'),(10,'root','localhost','grant UPDATE on world.CountryLanguage to \'judas\'@\'10.0.0.2\'','2009-11-17 17:30:31'),(11,'root','localhost','delete from inf_grantee_privileges where GRANTEE regexp \"^\'msandbox\'\"','2009-11-17 17:30:31'),(12,'root','localhost','grant DELETE on world.* to \"peter\"@\"localhost\"','2009-11-17 17:30:31'),(13,'root','localhost','grant EXECUTE on procedure securich.my_privileges to \"peter\"@\"localhost\";','2009-11-17 17:30:31'),(14,'root','localhost','revoke UPDATE on world.* from \'peter\'@\'localhost\'','2009-11-17 17:30:31');
/*!40000 ALTER TABLE `aud_grant_revoke` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aud_password`
--

DROP TABLE IF EXISTS `aud_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aud_password` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(16) NOT NULL,
  `HOSTNAME` varchar(60) NOT NULL,
  `MPASS` char(41) NOT NULL,
  `SPASS` char(41) NOT NULL,
  `TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aud_password`
--

LOCK TABLES `aud_password` WRITE;
/*!40000 ALTER TABLE `aud_password` DISABLE KEYS */;
/*!40000 ALTER TABLE `aud_password` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `aud_roles`
--

DROP TABLE IF EXISTS `aud_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aud_roles` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(16) NOT NULL,
  `HOSTNAME` varchar(60) NOT NULL,
  `COMMAND` text NOT NULL,
  `TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `aud_roles`
--

LOCK TABLES `aud_roles` WRITE;
/*!40000 ALTER TABLE `aud_roles` DISABLE KEYS */;
INSERT INTO `aud_roles` VALUES (1,'root','localhost','delete from inf_grantee_privileges where GRANTEE regexp \"^\'msandbox\'\"','2009-11-17 17:30:30'),(2,'root','localhost','grant INSERT on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:30'),(3,'root','localhost','grant UPDATE on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:30'),(4,'root','localhost','grant DELETE on securich.sec_users to \'trilla\'@\'localhost\'','2009-11-17 17:30:31'),(5,'root','localhost','delete from inf_grantee_privileges where GRANTEE regexp \"^\'msandbox\'\"','2009-11-17 17:30:31');
/*!40000 ALTER TABLE `aud_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_columns`
--

DROP TABLE IF EXISTS `sec_columns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_columns` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `COLUMNNAME` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_columns`
--

LOCK TABLES `sec_columns` WRITE;
/*!40000 ALTER TABLE `sec_columns` DISABLE KEYS */;
/*!40000 ALTER TABLE `sec_columns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_config`
--

DROP TABLE IF EXISTS `sec_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_config` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PROPERTY` varchar(255) DEFAULT NULL,
  `VALUE` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_config`
--

LOCK TABLES `sec_config` WRITE;
/*!40000 ALTER TABLE `sec_config` DISABLE KEYS */;
INSERT INTO `sec_config` VALUES (1,'reverse_reconciliation_in_progress',0),(2,'password_length',10);
/*!40000 ALTER TABLE `sec_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_databases`
--

DROP TABLE IF EXISTS `sec_databases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_databases` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATABASENAME` varchar(64) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_databases`
--

LOCK TABLES `sec_databases` WRITE;
/*!40000 ALTER TABLE `sec_databases` DISABLE KEYS */;
INSERT INTO `sec_databases` VALUES (1,''),(2,'employees'),(3,'sakila'),(4,'securich'),(5,'test'),(6,'tungsten'),(7,'world');
/*!40000 ALTER TABLE `sec_databases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_db_sp`
--

DROP TABLE IF EXISTS `sec_db_sp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_db_sp` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DB_ID` int(10) unsigned NOT NULL,
  `SP_ID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`,`DB_ID`,`SP_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_db_sp`
--

LOCK TABLES `sec_db_sp` WRITE;
/*!40000 ALTER TABLE `sec_db_sp` DISABLE KEYS */;
INSERT INTO `sec_db_sp` VALUES (1,3,2),(2,3,3),(3,3,4),(4,3,5),(5,3,6),(6,3,7),(7,4,8),(8,4,9),(9,4,10),(10,4,11),(11,4,12),(12,4,13),(13,4,14),(14,4,15),(15,4,16),(16,4,17),(17,4,18),(18,4,19),(19,4,20),(20,4,21),(21,4,22),(22,4,23),(23,4,24),(24,4,25),(25,4,26),(26,4,27),(27,4,28),(28,4,29),(29,4,30),(30,4,31);
/*!40000 ALTER TABLE `sec_db_sp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_db_tb`
--

DROP TABLE IF EXISTS `sec_db_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_db_tb` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DB_ID` int(10) unsigned NOT NULL,
  `TB_ID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`,`DB_ID`,`TB_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_db_tb`
--

LOCK TABLES `sec_db_tb` WRITE;
/*!40000 ALTER TABLE `sec_db_tb` DISABLE KEYS */;
INSERT INTO `sec_db_tb` VALUES (1,2,2),(2,2,3),(3,2,4),(4,2,5),(5,2,6),(6,2,7),(7,3,8),(8,3,9),(9,3,10),(10,3,11),(11,3,12),(12,3,13),(13,3,14),(14,3,15),(15,3,16),(16,3,17),(17,3,18),(18,3,19),(19,3,20),(20,3,21),(21,3,22),(22,3,23),(23,3,24),(24,3,25),(25,3,26),(26,3,27),(27,3,28),(28,3,29),(29,3,30),(30,4,31),(31,4,32),(32,4,33),(33,4,34),(34,4,35),(35,4,36),(36,4,37),(37,4,38),(38,4,39),(39,4,40),(40,4,41),(41,4,42),(42,4,43),(43,4,44),(44,4,45),(45,4,46),(46,4,47),(47,4,48),(48,4,49),(49,4,50),(50,4,51),(51,4,52),(52,4,53),(53,4,54),(54,4,55),(55,5,56),(56,5,57),(57,7,12),(58,7,13),(59,7,58),(64,1,1),(65,2,1),(66,3,1),(67,4,1),(68,5,1),(69,6,1),(70,7,1),(71,1,1),(72,2,1),(73,3,1),(74,4,1),(75,5,1),(76,6,1),(77,7,1);
/*!40000 ALTER TABLE `sec_db_tb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_help`
--

DROP TABLE IF EXISTS `sec_help`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_help` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `STOREDPROCEDURE` varchar(255) NOT NULL,
  `DESCRIPTION` longtext,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_help`
--

LOCK TABLES `sec_help` WRITE;
/*!40000 ALTER TABLE `sec_help` DISABLE KEYS */;
INSERT INTO `sec_help` VALUES (1,'','\r\n   Securich is there to help you administer and secure your data easier and in a more friendly manner.\r\n\r\n   Cheers,\r\n   Darren\r\n'),(2,'add_reserved_username','add_reserved_username(\'usernamein\'); (version 0.1.4)\r\n-- Used to add a username to the reserved list of usernames'),(3,'block_user','block_user(\'usernamein\',\'hostnamein\',\'dbnamein\',\'terminateconnections\'); (version 0.1.4)\r\n-- Used to block a particular user, terminating his/her connections if necessary and leave the account around to be unblocked if necessary. This is a useful feature for when a user needs temporary rights.'),(4,'show_full_user_entries','show_full_user_entries(\'username\'); (version 0.1.1)\r\n-- Checks the roles assigned to a particular user and on which database, table and from which host those privileges can be used'),(5,'show_users_with_privilege','show_users_with_privilege(\'privilege\'); (version 0.1.1)\r\n-- Shows a list of users who have been granted a particular privilege\r\n    show_users_with_privilege(\'privilege\',\'databasename\',\'tablename\') (version 0.1.2);\r\n-- Shows a list of users who have been granted a particular privilege on a particular table in a particular database.'),(6,'show_privileges_in_roles','show_privileges_in_roles(\'rolename\'); (version 0.1.1)\r\n-- Shows a list of privileges belonging to a particular role'),(7,'show_roles','show_roles(); (version 0.1.1)\r\n-- Run the above in order to check which roles are available'),(8,'show_user_entries','show_user_entries(\'username\'); (version 0.1.1)\r\n-- Checks the roles assigned to a particular user and on which database and from which host those privileges can be used'),(9,'show_user_list','show_user_list(); (version 0.1.1)\r\n-- Run the above in order to obtain a list of user@host present in the system'),(10,'show_user_privileges','show_user_privileges(\'username\',\'hostname\',\'databasename\',\'rolename\'); (version 0.1.1)\r\n-- Lets the administrator check the privileges a user has on that database or place \'all\' instead of \'rolename\' in order to have a look at all the privileges on that particular combination.'),(11,'clone_user','clone_user(\'sourceusernanme\',\'sourcehostname\',\'destusername\',\'desthostname\',\'destemailaddress\'); (version 0.1.2)\r\n-- If you have a particular user in a team already set up and you just want to create other users likewise, why not just clone them? The new user will of course have a different password which is supplied to the creator upon creation.'),(12,'create_update_role','create_update_role(\'way\',\'rolename\',\'privilege\'); (version 0.1.2) (version 0.1.4 added \'way\') \r\n-- Run the above in order to create/update roles at will. Note that updates in role privileges will reflect on users having the updated role on the system. The \'way\' can either be \"add\" or \"remove\" which are self-explanatory'),(13,'grant_privileges','grant_privileges(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'emailaddress\'); (version 0.1.1)\r\n-- Used to create a user with any particular combination/privileges. The tablename should be left empty if database / global level privileges are to be assigned. Note that rolename can not be substituted with all in this case. The limitations on length of each field are:\r\nFIELD           MAX LENGTH\r\nusername      - 16\r\nhostname      - 60\r\ndatabasename  - 64\r\ntablename     - 64\r\ntabletype     - 16\r\nrolename      - 60\r\nemailaddress  - 50\r\n\r\nFailure to abide to the limitations will cause truncation of any of the above parameters.\r\n\r\ntable type / tablename can be:\r\ntabletype           -   tablename            -   description\r\nall                 -                        -   all database         -   db.*                         -   used generally like `grant privilege on db.* to \'user\'@\'hostname\';`\r\nalltables           -                        -   all tables           -   db.tb1 db.tb2 db.tb3 etc     -   for all tables separately (used when there is a need to grant on all and revoke on a few tables)\r\nsingletable         -   tablename            -   single table         -   tb1                          -   for individual tables `grant privilege on db.tb1 to \'user\'@\'hostname\';`\r\nregexp              -   regular expression   -   regexp               -   tb1 2tb but not table3       -   this uses regexp ***\r\nstoredprocedure     -   procedure name       -   single procedurure   -   pr1                          -   for individual procedures\r\n*** note that for regexp usage, if tables need to have a common prefix the best way would be to add a ^ in front of the prefix i.e. ^prefix'),(14,'help','help(\'storedprocedurenamein\'); (version 0.1.4)\r\n-- Displays the help about each individual stored procedure and how to use it'),(15,'my_privileges','my_privileges(\'dbname\'); (version 0.1.2)\r\n-- This script is to be executed by any user (if grant has been permitted by the dba to run it) thus letting any user know what privileges he / she has. It is not totally recommended but might be helpful in development, qa and uat environments. The user can either type in a dbname he likes or \'*\' to get a full detailed list of privileges he/she got on individual tables, stored procedures / databases.'),(16,'reconciliation','reconciliation(\'value\'); (version 0.1.1)\r\n-- This list ignores root privileges as well as the privilege \'usage\'. It caters both for database privileges as well as for global privileges and supplies the difference between the the securich package privileges and those actually in the mysql system. Using parameter \'list\' provides the differences explaining where a particular grant is found thus implying where it is not found (MySQL meaning it is found in MySQL database and not in securich database and vice versa). The parameter \'sync\' can be used to re-synchronize the two systems thus obtaining a consistent state.'),(17,'remove_reserved_username','remove_reserved_username(\'usernamein\'); (version 0.1.4)\r\n-- Does the opposite of add_reserved_username, removes a username from the reserved list'),(18,'rename_user','rename_user(\'oldusername\',\'newusername\',\'newemailaddress\');\r\n-- Renames an old user to the new username leaving all privileges intact and changing only the password and the email address.'),(19,'revoke_privileges','revoke_privileges(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'terminateconnections\');\r\n-- Revokes a privilege for a particular combination of username / hostname / databasename / tablename / role. The terminateconnectionsy is there to kill all threads for a particular user if set to Y which is revoked. Should you not want to cut off the user, just substitute it with n and the user won\'t be able to connect next time round but current connections remain intact. - tabletype should either be table (for a table) and storedprocedure (for a stored proc).'),(21,'unblock_user ','unblock_user ( \'usernamein\',\'hostnamein\',\'dbnamein\' )\r\n-- Unblocks any user specified if it had blocked privileges / roles'),(22,'update_databases_tables_storedprocedures_list','update_databases_tables_storedprocedures_list();\r\n-- Updates the tables and databases tables (sec_tables, sec_databases, sec_storecprocedures and their relationship table sec_db_tb and sec_db_sp) with the full list of tables / databases / storedprocedures.'),(23,'grant_privileges_reverse_reconciliation','grant_privileges_reverse_reconciliation(\'username\',\'hostname\',\'databasename\',\'tablename\',\'tabletype\',\'rolename\',\'emailaddress\'); (version 0.2.0)\r\nUsed in conjunction with `reverse_reconciliation` to reconcile MySQL grants with Securich tables.'),(24,'reverse_reconciliation','reverse_reconciliation(); (version 0.2.0)\r\nUsed in conjunction with `grant_privileges_reverse_reconciliation` to reconcile MySQL grants with Securich tables.');
/*!40000 ALTER TABLE `sec_help` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_hosts`
--

DROP TABLE IF EXISTS `sec_hosts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_hosts` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `HOSTNAME` varchar(64) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_hosts`
--

LOCK TABLES `sec_hosts` WRITE;
/*!40000 ALTER TABLE `sec_hosts` DISABLE KEYS */;
INSERT INTO `sec_hosts` VALUES (1,'localhost'),(2,'127.0.0.1'),(3,'10.0.0.2');
/*!40000 ALTER TABLE `sec_hosts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_privileges`
--

DROP TABLE IF EXISTS `sec_privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_privileges` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PRIVILEGE` varchar(50) NOT NULL,
  `TYPE` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_privileges`
--

LOCK TABLES `sec_privileges` WRITE;
/*!40000 ALTER TABLE `sec_privileges` DISABLE KEYS */;
INSERT INTO `sec_privileges` VALUES (1,'SELECT',-1),(2,'INSERT',-1),(3,'UPDATE',-1),(4,'DELETE',0),(5,'ALTER',0),(6,'CREATE',0),(7,'DROP',0),(8,'INDEX',0),(9,'REFERENCES',-1),(10,'CREATE TEMPORARY TABLES',2),(11,'LOCK TABLES',2),(12,'TRIGGER',2),(13,'CREATE VIEW',2),(14,'SHOW VIEW',2),(15,'ALTER ROUTINE',1),(16,'CREATE ROUTINE',2),(17,'EXECUTE',1),(18,'EVENT',2),(19,'CREATE USER',3),(20,'PROCESS',3),(21,'RELOAD',3),(22,'REPLICATION CLIENT',3),(23,'REPLICATION SLAVE',3),(24,'SHOW DATABASES',3),(25,'SHUTDOWN',3),(26,'SUPER',3),(27,'FILE',3);
/*!40000 ALTER TABLE `sec_privileges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_reserved_usernames`
--

DROP TABLE IF EXISTS `sec_reserved_usernames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_reserved_usernames` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(50) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_reserved_usernames`
--

LOCK TABLES `sec_reserved_usernames` WRITE;
/*!40000 ALTER TABLE `sec_reserved_usernames` DISABLE KEYS */;
INSERT INTO `sec_reserved_usernames` VALUES (1,'root'),(2,''),(3,'msandbox');
/*!40000 ALTER TABLE `sec_reserved_usernames` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_ro_pr`
--

DROP TABLE IF EXISTS `sec_ro_pr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_ro_pr` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `RO_ID` int(10) unsigned NOT NULL,
  `PR_ID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`,`RO_ID`,`PR_ID`),
  KEY `fk_sec_ro_pr_sec_roles` (`RO_ID`),
  KEY `fk_sec_ro_pr_sec_privileges` (`PR_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_ro_pr`
--

LOCK TABLES `sec_ro_pr` WRITE;
/*!40000 ALTER TABLE `sec_ro_pr` DISABLE KEYS */;
INSERT INTO `sec_ro_pr` VALUES (1,1,1),(3,2,2),(4,2,3),(5,2,4),(6,3,1),(7,3,2),(8,3,3),(9,3,4),(10,4,17);
/*!40000 ALTER TABLE `sec_ro_pr` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_roles`
--

DROP TABLE IF EXISTS `sec_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_roles` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ROLE` varchar(50) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_roles`
--

LOCK TABLES `sec_roles` WRITE;
/*!40000 ALTER TABLE `sec_roles` DISABLE KEYS */;
INSERT INTO `sec_roles` VALUES (1,'read'),(2,'write'),(3,'role1'),(4,'role2');
/*!40000 ALTER TABLE `sec_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_storedprocedures`
--

DROP TABLE IF EXISTS `sec_storedprocedures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_storedprocedures` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `STOREDPROCEDURENAME` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_storedprocedures`
--

LOCK TABLES `sec_storedprocedures` WRITE;
/*!40000 ALTER TABLE `sec_storedprocedures` DISABLE KEYS */;
INSERT INTO `sec_storedprocedures` VALUES (1,''),(2,'film_in_stock'),(3,'film_not_in_stock'),(4,'get_customer_balance'),(5,'inventory_held_by_customer'),(6,'inventory_in_stock'),(7,'rewards_report'),(8,'update_databases_tables_storedprocedures_list'),(9,'add_reserved_username'),(10,'block_user'),(11,'clone_user'),(12,'create_update_role'),(13,'grant_privileges'),(14,'grant_privileges_reverse_reconciliation'),(15,'help'),(16,'my_privileges'),(17,'password_check'),(18,'reconciliation'),(19,'remove_reserved_username'),(20,'rename_user'),(21,'reverse_reconciliation'),(22,'revoke_privileges'),(23,'set_password'),(24,'show_full_user_entries'),(25,'show_privileges_in_roles'),(26,'show_roles'),(27,'show_users_with_privilege'),(28,'show_user_entries'),(29,'show_user_list'),(30,'show_user_privileges'),(31,'unblock_user');
/*!40000 ALTER TABLE `sec_storedprocedures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_tables`
--

DROP TABLE IF EXISTS `sec_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_tables` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TABLENAME` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_tables`
--

LOCK TABLES `sec_tables` WRITE;
/*!40000 ALTER TABLE `sec_tables` DISABLE KEYS */;
INSERT INTO `sec_tables` VALUES (1,''),(2,'departments'),(3,'dept_emp'),(4,'dept_manager'),(5,'employees'),(6,'salaries'),(7,'titles'),(8,'actor'),(9,'actor_info'),(10,'address'),(11,'category'),(12,'city'),(13,'country'),(14,'customer'),(15,'customer_list'),(16,'film'),(17,'film_actor'),(18,'film_category'),(19,'film_list'),(20,'film_text'),(21,'inventory'),(22,'language'),(23,'nicer_but_slower_film_list'),(24,'payment'),(25,'rental'),(26,'sales_by_film_category'),(27,'sales_by_store'),(28,'staff'),(29,'staff_list'),(30,'store'),(31,'aud_grant_revoke'),(32,'aud_password'),(33,'aud_roles'),(34,'sec_columns'),(35,'sec_config'),(36,'sec_databases'),(37,'sec_db_sp'),(38,'sec_db_tb'),(39,'sec_help'),(40,'sec_hosts'),(41,'sec_privileges'),(42,'sec_reserved_usernames'),(43,'sec_ro_pr'),(44,'sec_roles'),(45,'sec_storedprocedures'),(46,'sec_tables'),(47,'sec_tb_cl'),(48,'sec_us_ho'),(49,'sec_us_ho_db_sp'),(50,'sec_us_ho_db_sp_ro'),(51,'sec_us_ho_db_tb'),(52,'sec_us_ho_db_tb_ro'),(53,'sec_us_ho_profile'),(54,'sec_users'),(55,'sec_version'),(56,'t1'),(57,'t2'),(58,'CountryLanguage');
/*!40000 ALTER TABLE `sec_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_tb_cl`
--

DROP TABLE IF EXISTS `sec_tb_cl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_tb_cl` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `TB_ID` int(10) unsigned NOT NULL,
  `CL_ID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`,`TB_ID`,`CL_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_tb_cl`
--

LOCK TABLES `sec_tb_cl` WRITE;
/*!40000 ALTER TABLE `sec_tb_cl` DISABLE KEYS */;
/*!40000 ALTER TABLE `sec_tb_cl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho`
--

DROP TABLE IF EXISTS `sec_us_ho`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_ID` int(10) unsigned NOT NULL,
  `HO_ID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`ID`,`HO_ID`,`US_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho`
--

LOCK TABLES `sec_us_ho` WRITE;
/*!40000 ALTER TABLE `sec_us_ho` DISABLE KEYS */;
INSERT INTO `sec_us_ho` VALUES (1,1,1),(2,2,2),(3,3,3),(4,4,3),(5,5,1);
/*!40000 ALTER TABLE `sec_us_ho` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho_db_sp`
--

DROP TABLE IF EXISTS `sec_us_ho_db_sp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho_db_sp` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_ID` int(10) unsigned NOT NULL,
  `HO_ID` int(10) unsigned NOT NULL,
  `DB_ID` int(10) unsigned NOT NULL DEFAULT '1',
  `SP_ID` int(10) unsigned NOT NULL DEFAULT '1',
  `STATE` char(1) DEFAULT 'I',
  PRIMARY KEY (`ID`,`US_ID`,`HO_ID`,`DB_ID`,`SP_ID`),
  KEY `fk_sec_us_ho_db_sec_users` (`US_ID`),
  KEY `fk_sec_us_ho_db_sec_hosts` (`HO_ID`),
  KEY `fk_sec_us_ho_db_sec_databases` (`DB_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho_db_sp`
--

LOCK TABLES `sec_us_ho_db_sp` WRITE;
/*!40000 ALTER TABLE `sec_us_ho_db_sp` DISABLE KEYS */;
INSERT INTO `sec_us_ho_db_sp` VALUES (1,5,1,4,16,'A');
/*!40000 ALTER TABLE `sec_us_ho_db_sp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho_db_sp_ro`
--

DROP TABLE IF EXISTS `sec_us_ho_db_sp_ro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho_db_sp_ro` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_HO_DB_SP_ID` int(10) unsigned NOT NULL,
  `RO_ID` int(10) unsigned NOT NULL,
  `STATE` char(1) DEFAULT 'A',
  PRIMARY KEY (`ID`,`US_HO_DB_SP_ID`,`RO_ID`),
  KEY `fk_sec_us_ho_db_ro_sec_us_ho_db` (`US_HO_DB_SP_ID`),
  KEY `fk_sec_us_ho_db_ro_sec_roles` (`RO_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho_db_sp_ro`
--

LOCK TABLES `sec_us_ho_db_sp_ro` WRITE;
/*!40000 ALTER TABLE `sec_us_ho_db_sp_ro` DISABLE KEYS */;
INSERT INTO `sec_us_ho_db_sp_ro` VALUES (1,1,4,'A');
/*!40000 ALTER TABLE `sec_us_ho_db_sp_ro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho_db_tb`
--

DROP TABLE IF EXISTS `sec_us_ho_db_tb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho_db_tb` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_ID` int(10) unsigned NOT NULL,
  `HO_ID` int(10) unsigned NOT NULL,
  `DB_ID` int(10) unsigned NOT NULL DEFAULT '1',
  `TB_ID` int(10) unsigned NOT NULL DEFAULT '1',
  `STATE` char(1) DEFAULT 'I',
  PRIMARY KEY (`ID`,`US_ID`,`HO_ID`,`DB_ID`,`TB_ID`),
  KEY `fk_sec_us_ho_db_sec_users` (`US_ID`),
  KEY `fk_sec_us_ho_db_sec_hosts` (`HO_ID`),
  KEY `fk_sec_us_ho_db_sec_databases` (`DB_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho_db_tb`
--

LOCK TABLES `sec_us_ho_db_tb` WRITE;
/*!40000 ALTER TABLE `sec_us_ho_db_tb` DISABLE KEYS */;
INSERT INTO `sec_us_ho_db_tb` VALUES (1,1,1,4,54,'A'),(2,2,2,2,2,'A'),(3,2,2,2,3,'A'),(4,2,2,2,4,'A'),(5,2,2,2,5,'A'),(6,2,2,2,6,'R'),(7,2,2,2,7,'A'),(8,3,3,7,13,'A'),(9,3,3,7,58,'A'),(10,4,3,7,13,'A'),(11,4,3,7,58,'A'),(13,5,1,7,1,'R');
/*!40000 ALTER TABLE `sec_us_ho_db_tb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho_db_tb_ro`
--

DROP TABLE IF EXISTS `sec_us_ho_db_tb_ro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho_db_tb_ro` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_HO_DB_TB_ID` int(10) unsigned NOT NULL,
  `RO_ID` int(10) unsigned NOT NULL,
  `STATE` char(1) DEFAULT 'A',
  PRIMARY KEY (`ID`,`US_HO_DB_TB_ID`,`RO_ID`),
  KEY `fk_sec_us_ho_db_ro_sec_us_ho_db` (`US_HO_DB_TB_ID`),
  KEY `fk_sec_us_ho_db_ro_sec_roles` (`RO_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho_db_tb_ro`
--

LOCK TABLES `sec_us_ho_db_tb_ro` WRITE;
/*!40000 ALTER TABLE `sec_us_ho_db_tb_ro` DISABLE KEYS */;
INSERT INTO `sec_us_ho_db_tb_ro` VALUES (1,1,3,'A'),(2,2,3,'A'),(3,3,3,'A'),(4,4,3,'A'),(5,5,3,'A'),(7,7,3,'A'),(8,8,3,'A'),(9,9,3,'A'),(10,10,3,'A'),(11,11,3,'A');
/*!40000 ALTER TABLE `sec_us_ho_db_tb_ro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_us_ho_profile`
--

DROP TABLE IF EXISTS `sec_us_ho_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_us_ho_profile` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `US_HO_ID` int(10) unsigned NOT NULL,
  `PW0` char(41) DEFAULT NULL,
  `PW1` char(41) DEFAULT NULL,
  `PW2` char(41) DEFAULT NULL,
  `PW3` char(41) DEFAULT NULL,
  `PW4` char(41) DEFAULT NULL,
  `CREATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATE_TIMESTAMP` timestamp NULL DEFAULT NULL,
  `UPDATE_COUNT` int(11) DEFAULT '1',
  `TYPE` varchar(50) DEFAULT 'USER',
  PRIMARY KEY (`ID`,`US_HO_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_us_ho_profile`
--

LOCK TABLES `sec_us_ho_profile` WRITE;
/*!40000 ALTER TABLE `sec_us_ho_profile` DISABLE KEYS */;
INSERT INTO `sec_us_ho_profile` VALUES (1,1,'*39D8F4E3A98D054FAE28028FC9F436DCB45BBEA6',NULL,NULL,NULL,NULL,'2009-11-17 17:30:30','2009-11-17 17:30:30',1,'USER'),(2,2,'*0A0D21049BFFA681B95AF36DD37DF4065E14A156',NULL,NULL,NULL,NULL,'2009-11-17 17:30:30','2009-11-17 17:30:30',1,'USER'),(3,3,'*AD94218E3F192D109B7CB4425307D0BCAD755313',NULL,NULL,NULL,NULL,'2009-11-17 17:30:31','2009-11-17 17:30:31',1,'USER'),(4,4,'*8631782BE1CC7484BC9A07AA7254924C7F469CF8',NULL,NULL,NULL,NULL,'2009-11-17 17:30:31','2009-11-17 17:30:31',1,'USER'),(5,5,'*BFD4191384826AD232849F6141772466DEF348A9',NULL,NULL,NULL,NULL,'2009-11-17 17:30:31','2009-11-17 17:30:31',1,'USER');
/*!40000 ALTER TABLE `sec_us_ho_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_users`
--

DROP TABLE IF EXISTS `sec_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_users` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(16) NOT NULL,
  `EMAIL_ADDRESS` varchar(64) DEFAULT '',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_users`
--

LOCK TABLES `sec_users` WRITE;
/*!40000 ALTER TABLE `sec_users` DISABLE KEYS */;
INSERT INTO `sec_users` VALUES (1,'trilla','user@company.com'),(2,'john','john@domain.com'),(3,'tom','tom@domain.com'),(4,'judas','judas@domain.com'),(5,'peter','peter@domain.com');
/*!40000 ALTER TABLE `sec_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sec_version`
--

DROP TABLE IF EXISTS `sec_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sec_version` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `VERSION` varchar(10) NOT NULL,
  `UPDATED_TIMESTAMP` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sec_version`
--

LOCK TABLES `sec_version` WRITE;
/*!40000 ALTER TABLE `sec_version` DISABLE KEYS */;
INSERT INTO `sec_version` VALUES (1,'0.2.0','2009-11-17 17:30:18');
/*!40000 ALTER TABLE `sec_version` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2009-11-17 17:33:05
