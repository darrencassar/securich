SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `securich` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci ;
USE `securich`;

-- -----------------------------------------------------
-- Table `securich`.`sec_databases`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_databases` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_databases` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `DATABASENAME` VARCHAR(64) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `securich`.`sec_hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_hosts` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_hosts` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `HOSTNAME` VARCHAR(64) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `securich`.`sec_privileges`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_privileges` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_privileges` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `PRIVILEGE` VARCHAR(50) NOT NULL ,
  `TYPE` INT NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `securich`.`sec_ro_pr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_ro_pr` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_ro_pr` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `RO_ID` INT(10) UNSIGNED NOT NULL ,
  `PR_ID` INT(10) UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `RO_ID`, `PR_ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_ro_pr_sec_roles` ON `sec_ro_pr` (`RO_ID` ASC) ;

CREATE INDEX `fk_sec_ro_pr_sec_privileges` ON `sec_ro_pr` (`PR_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_roles`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_roles` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_roles` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `ROLE` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_tb`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_tb` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_tb` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `US_ID` INT(10) UNSIGNED NOT NULL ,
  `HO_ID` INT(10) UNSIGNED NOT NULL ,
  `DB_ID` INT(10) UNSIGNED NOT NULL DEFAULT 1 ,
  `TB_ID` INT(10) UNSIGNED NOT NULL DEFAULT 1 ,
  `STATE` CHAR(1) NULL DEFAULT 'I' ,
  PRIMARY KEY (`ID`, `US_ID`, `HO_ID`, `DB_ID`, `TB_ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_sec_users` ON `sec_us_ho_db_tb` (`US_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_hosts` ON `sec_us_ho_db_tb` (`HO_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_databases` ON `sec_us_ho_db_tb` (`DB_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_tb_ro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_tb_ro` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_tb_ro` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `US_HO_DB_TB_ID` INT(10) UNSIGNED NOT NULL ,
  `RO_ID` INT(10) UNSIGNED NOT NULL ,
  `STATE` CHAR(1) NULL DEFAULT 'A' ,
  PRIMARY KEY (`ID`, `US_HO_DB_TB_ID`, `RO_ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_us_ho_db` ON `sec_us_ho_db_tb_ro` (`US_HO_DB_TB_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_roles` ON `sec_us_ho_db_tb_ro` (`RO_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_users` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_users` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(16) NOT NULL ,
  `EMAIL_ADDRESS` VARCHAR(64) NULL DEFAULT '' ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_profile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_profile` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_profile` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `US_HO_ID` INT UNSIGNED NOT NULL ,
  `PW0` CHAR(41) NULL ,
  `PW1` CHAR(41) NULL ,
  `PW2` CHAR(41) NULL ,
  `PW3` CHAR(41) NULL ,
  `PW4` CHAR(41) NULL ,
  `CREATE_TIMESTAMP` TIMESTAMP NULL ,
  `UPDATE_TIMESTAMP` TIMESTAMP NULL ,
  `UPDATE_COUNT` INT NULL DEFAULT 1 ,
  `TYPE` VARCHAR(50) NULL DEFAULT 'USER' ,
  PRIMARY KEY (`ID`, `US_HO_ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `US_ID` INT UNSIGNED NOT NULL ,
  `HO_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `HO_ID`, `US_ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_tables`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_tables` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_tables` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `TABLENAME` VARCHAR(64) NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_db_tb`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_db_tb` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_db_tb` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `DB_ID` INT UNSIGNED NOT NULL ,
  `TB_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `DB_ID`, `TB_ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_columns`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_columns` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_columns` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `COLUMNNAME` VARCHAR(64) NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_tb_cl`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_tb_cl` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_tb_cl` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `TB_ID` INT UNSIGNED NOT NULL ,
  `CL_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `TB_ID`, `CL_ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_sp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_sp` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_sp` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `US_ID` INT(10) UNSIGNED NOT NULL ,
  `HO_ID` INT(10) UNSIGNED NOT NULL ,
  `DB_ID` INT(10) UNSIGNED NOT NULL DEFAULT 1 ,
  `SP_ID` INT(10) UNSIGNED NOT NULL DEFAULT 1 ,
  `STATE` CHAR(1) NULL DEFAULT 'I' ,
  PRIMARY KEY (`ID`, `US_ID`, `HO_ID`, `DB_ID`, `SP_ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_sec_users` ON `sec_us_ho_db_sp` (`US_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_hosts` ON `sec_us_ho_db_sp` (`HO_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_sec_databases` ON `sec_us_ho_db_sp` (`DB_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_us_ho_db_sp_ro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_us_ho_db_sp_ro` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_us_ho_db_sp_ro` (
  `ID` INT(10) UNSIGNED NULL AUTO_INCREMENT ,
  `US_HO_DB_SP_ID` INT(10) UNSIGNED NOT NULL ,
  `RO_ID` INT(10) UNSIGNED NOT NULL ,
  `STATE` CHAR(1) NULL DEFAULT 'A' ,
  PRIMARY KEY (`ID`, `US_HO_DB_SP_ID`, `RO_ID`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_us_ho_db` ON `sec_us_ho_db_sp_ro` (`US_HO_DB_SP_ID` ASC) ;

CREATE INDEX `fk_sec_us_ho_db_ro_sec_roles` ON `sec_us_ho_db_sp_ro` (`RO_ID` ASC) ;


-- -----------------------------------------------------
-- Table `securich`.`sec_storedprocedures`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_storedprocedures` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_storedprocedures` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `STOREDPROCEDURENAME` VARCHAR(64) NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_db_sp`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_db_sp` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_db_sp` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `DB_ID` INT UNSIGNED NOT NULL ,
  `SP_ID` INT UNSIGNED NOT NULL ,
  PRIMARY KEY (`ID`, `DB_ID`, `SP_ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_version`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_version` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_version` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `VERSION` VARCHAR(10) NOT NULL ,
  `UPDATED_TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_reserved_usernames`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_reserved_usernames` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_reserved_usernames` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `USERNAME` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `securich`.`sec_help`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_help` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_help` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `STOREDPROCEDURE` VARCHAR(255) NOT NULL ,
  `DESCRIPTION` LONGTEXT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `securich`.`aud_password`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`aud_password` ;

CREATE  TABLE IF NOT EXISTS `securich`.`aud_password` (
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
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
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
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
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
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
  `ID` INT UNSIGNED NULL AUTO_INCREMENT ,
  `PROPERTY` VARCHAR(255) NULL ,
  `VALUE` INT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `securich`.`sec_dictionary`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `securich`.`sec_dictionary` ;

CREATE  TABLE IF NOT EXISTS `securich`.`sec_dictionary` (
  `PASSWD` VARCHAR(255) )
ENGINE = MyISAM;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
