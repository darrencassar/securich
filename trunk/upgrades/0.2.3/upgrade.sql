SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `securich`.`sec_databases` 
ADD INDEX `DBNAME_IDX` (`DATABASENAME` ASC) ;

ALTER TABLE `securich`.`sec_hosts` 
ADD INDEX `HNAME_IDX` (`HOSTNAME` ASC) ;

ALTER TABLE `securich`.`sec_privileges` 
ADD INDEX `PRIVILEGE_IDX` (`PRIVILEGE` ASC) ;

ALTER TABLE `securich`.`sec_roles` 
ADD INDEX `ROLE_IDX` (`ROLE` ASC) ;

ALTER TABLE `securich`.`sec_users` ADD COLUMN `PASS_EXPIRABLE` CHAR(1) NOT NULL DEFAULT 'N'  AFTER `EMAIL_ADDRESS` 
, ADD INDEX `UNAME_IDX` (`USERNAME` ASC) ;

ALTER TABLE `securich`.`sec_tables` 
ADD INDEX `TBNAME` (`TABLENAME` ASC) ;

ALTER TABLE `securich`.`sec_columns` 
ADD INDEX `CNAME_IDX` (`COLUMNNAME` ASC) ;

ALTER TABLE `securich`.`sec_storedprocedures` 
ADD INDEX `SPNAME_IDX` (`STOREDPROCEDURENAME` ASC) ;

ALTER TABLE `securich`.`sec_help` CHANGE COLUMN `STOREDPROCEDURE` `STOREDPROCEDURE` VARCHAR(64) NOT NULL  ;

ALTER TABLE `securich`.`sec_dictionary` CHANGE COLUMN `WORD` `WORD` VARCHAR(60) NULL DEFAULT NULL  
, ADD INDEX `WORD_IDX` (`WORD` ASC) ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (29,'set_password_expirable','set_password_expirable(\'username\',\'setting\');\r\n-- Set a user to have an expirable password (for devs and human users) or not (for application, replication or other non human users).');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (30,'drop_user','drop_user(\'username\',\'hostname\');\r\n-- Drop user completely');
INSERT  INTO `securich`.`sec_help`(`ID`,`STOREDPROCEDURE`,`DESCRIPTION`) VALUES (31,'rename_user_at_host','rename_user_at_host(\'username\',\'hostname\',\'newusername\',\'newhostname\');\r\n-- Rename username@hostname to newusername@newhostname. It takes care of all the necessary changes and makes sure the old username@hostname grants are revoked completely.');
