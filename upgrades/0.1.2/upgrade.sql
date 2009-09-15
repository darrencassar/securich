/* New table sec_version containing securich version records */

CREATE  TABLE IF NOT EXISTS `securich`.`sec_version` (
  `ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `VERSION` VARCHAR(8) NOT NULL ,
  `UPDATED_TIMESTAMP` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`ID`) )
ENGINE = MyISAM
DEFAULT CHARACTER SET = latin1
COLLATE = latin1_swedish_ci;


