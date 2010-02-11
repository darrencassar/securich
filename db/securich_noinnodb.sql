SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `securich` DEFAULT CHARACTER SET latin1 ;
USE `securich`;

-- -----------------------------------------------------
-- Table `securich`.`sec_databases`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_databases` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_databases` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `DATABASENAME` VARCHAR(64) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `DBNAME_IDX` ON `securich`.`sec_databases` (`DATABASENAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_hosts` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_hosts` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `HOSTNAME` VARCHAR(64) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `HNAME_IDX` ON `securich`.`sec_hosts` (`HOSTNAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_privileges`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_privileges` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_privileges` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `PRIVILEGE` VARCHAR(50) NOT NULL ,
  `TYPE` INT NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `PRIVILEGE_IDX` ON `securich`.`sec_privileges` (`PRIVILEGE` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_ro_pr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_ro_pr` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_ro_pr` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `RO_ID` INT UNSIGNED NOT NULL ,
  `PR_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `RO_ID`, `PR_ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_ro_pr_sec_roles` ON `securich`.`sec_ro_pr` (`RO_ID` ASC) ;

CREATE INDEX `fk_sec_ro_pr_sec_privileges` ON `securich`.`sec_ro_pr` (`PR_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_roles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_roles` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_roles` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `ROLE` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `ROLE_IDX` ON `securich`.`sec_roles` (`ROLE` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_tb`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_tb` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_tb` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `US_ID` INT UNSIGNED NOT NULL ,
  `HO_ID` INT UNSIGNED NOT NULL ,
  `DB_ID` INT UNSIGNED NOT NULL DEFAULT 1 ,
  `TB_ID` INT UNSIGNED NOT NULL DEFAULT 1 ,
  `STATE` CHAR(1) NULL DEFAULT 'I' ,
  PRIMARY KEY (`ID`, `US_ID`, `HO_ID`, `DB_ID`, `TB_ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_sec_users` ON `securich`.`sec_us_ho_db_tb` (`US_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_hosts` ON `securich`.`sec_us_ho_db_tb` (`HO_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_databases` ON `securich`.`sec_us_ho_db_tb` (`DB_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_tb_ro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_tb_ro` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_tb_ro` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `US_HO_DB_TB_ID` INT UNSIGNED NOT NULL ,
  `RO_ID` INT UNSIGNED NOT NULL ,
  `STATE` CHAR(1) NULL DEFAULT 'A' ,
  PRIMARY KEY (`ID`, `US_HO_DB_TB_ID`, `RO_ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_us_ho_db` ON `securich`.`sec_us_ho_db_tb_ro` (`US_HO_DB_TB_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_roles` ON `securich`.`sec_us_ho_db_tb_ro` (`RO_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_users` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_users` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(16) NOT NULL ,
  `EMAIL_ADDRESS` VARCHAR(64) NULL DEFAULT '' ,
  `PASS_EXPIRABLE` CHAR(1) NOT NULL DEFAULT 'N' ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `UNAME_IDX` ON `securich`.`sec_users` (`USERNAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_profile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_profile` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_profile` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `US_HO_ID` INT UNSIGNED NOT NULL ,
  `PW0` CHAR(41) NULL DEFAULT NULL ,
  `PW1` CHAR(41) NULL DEFAULT NULL ,
  `PW2` CHAR(41) NULL DEFAULT NULL ,
  `PW3` CHAR(41) NULL DEFAULT NULL ,
  `PW4` CHAR(41) NULL DEFAULT NULL ,
  `CREATE_TIMESTAMP` TIMESTAMP NULL DEFAULT NULL ,
  `UPDATE_TIMESTAMP` TIMESTAMP NULL DEFAULT NULL ,
  `UPDATE_COUNT` INT NULL DEFAULT 1 ,
  `TYPE` VARCHAR(50) NULL DEFAULT 'USER' ,
  PRIMARY KEY (`ID`, `US_HO_ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `US_ID` INT UNSIGNED NOT NULL ,
  `HO_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `HO_ID`, `US_ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_tables`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_tables` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_tables` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `TABLENAME` VARCHAR(64) NULL DEFAULT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;

CREATE INDEX `TBNAME` ON `securich`.`sec_tables` (`TABLENAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_db_tb`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_db_tb` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_db_tb` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `DB_ID` INT UNSIGNED NOT NULL ,
  `TB_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `DB_ID`, `TB_ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_columns`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_columns` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_columns` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `COLUMNNAME` VARCHAR(64) NULL DEFAULT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;

CREATE INDEX `CNAME_IDX` ON `securich`.`sec_columns` (`COLUMNNAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_tb_cl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_tb_cl` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_tb_cl` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `TB_ID` INT UNSIGNED NOT NULL ,
  `CL_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `TB_ID`, `CL_ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_sp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_sp` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_sp` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `US_ID` INT UNSIGNED NOT NULL ,
  `HO_ID` INT UNSIGNED NOT NULL ,
  `DB_ID` INT UNSIGNED NOT NULL DEFAULT 1 ,
  `SP_ID` INT UNSIGNED NOT NULL DEFAULT 1 ,
  `STATE` CHAR(1) NULL DEFAULT 'I' ,
  PRIMARY KEY (`ID`, `US_ID`, `HO_ID`, `DB_ID`, `SP_ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_sec_users` ON `securich`.`sec_us_ho_db_sp` (`US_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_hosts` ON `securich`.`sec_us_ho_db_sp` (`HO_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_databases` ON `securich`.`sec_us_ho_db_sp` (`DB_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_sp_ro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_sp_ro` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_sp_ro` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `US_HO_DB_SP_ID` INT UNSIGNED NOT NULL ,
  `RO_ID` INT UNSIGNED NOT NULL ,
  `STATE` CHAR(1) NULL DEFAULT 'A' ,
  PRIMARY KEY (`ID`, `US_HO_DB_SP_ID`, `RO_ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_us_ho_db` ON `securich`.`sec_us_ho_db_sp_ro` (`US_HO_DB_SP_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_roles` ON `securich`.`sec_us_ho_db_sp_ro` (`RO_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_storedprocedures`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_storedprocedures` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_storedprocedures` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `STOREDPROCEDURENAME` VARCHAR(64) NULL DEFAULT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;

CREATE INDEX `SPNAME_IDX` ON `securich`.`sec_storedprocedures` (`STOREDPROCEDURENAME` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_db_sp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_db_sp` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_db_sp` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `DB_ID` INT UNSIGNED NOT NULL ,
  `SP_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `DB_ID`, `SP_ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_version`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_version` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_version` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `VERSION` VARCHAR(10) NOT NULL ,
  `UPDATED_TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_reserved_usernames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_reserved_usernames` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_reserved_usernames` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_help`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_help` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_help` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `STOREDPROCEDURE` VARCHAR(64) NOT NULL ,
  `DESCRIPTION` LONGTEXT NULL DEFAULT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`aud_password`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`aud_password` ;

CREATE  TABLE IF NOT EXISTS `securich`.`aud_password` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(16) NOT NULL ,
  `HOSTNAME` VARCHAR(60) NOT NULL ,
  `MPASS` CHAR(41) NOT NULL ,
  `SPASS` CHAR(41) NOT NULL ,
  `TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`aud_grant_revoke`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`aud_grant_revoke` ;

CREATE  TABLE IF NOT EXISTS `securich`.`aud_grant_revoke` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(16) NOT NULL ,
  `HOSTNAME` VARCHAR(60) NOT NULL ,
  `COMMAND` TEXT NOT NULL ,
  `TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`aud_roles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`aud_roles` ;

CREATE  TABLE IF NOT EXISTS `securich`.`aud_roles` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(16) NOT NULL ,
  `HOSTNAME` VARCHAR(60) NOT NULL ,
  `COMMAND` TEXT NOT NULL ,
  `TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_config`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_config` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_config` (
  `ID` INT UNSIGNED NULL DEFAULT NULL AUTO_INCREMENT ,
  `PROPERTY` VARCHAR(255) NULL DEFAULT NULL ,
  `VALUE` INT NULL DEFAULT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`sec_dictionary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_dictionary` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_dictionary` (
  `WORD` VARCHAR(60) NULL DEFAULT NULL )
ENGINE = MyISAM;

CREATE INDEX `WORD_IDX` ON `securich`.`sec_dictionary` (`WORD` ASC) ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
