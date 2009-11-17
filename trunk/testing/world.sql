-- MySQL dump 10.9
--
-- Host: localhost    Database: world
-- ------------------------------------------------------
-- Server version	4.1.13-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES latin1 */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `City`
--
DROP SCHEMA IF EXISTS world;
CREATE SCHEMA world;
USE world;

DROP TABLE IF EXISTS `City`;
CREATE TABLE `City` (
  `ID` int(11) NOT NULL auto_increment,
  `Name` char(35) NOT NULL default '',
  `CountryCode` char(3) NOT NULL default '',
  `District` char(20) NOT NULL default '',
  `Population` int(11) NOT NULL default '0',
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `Country`
--

DROP TABLE IF EXISTS `Country`;
CREATE TABLE `Country` (
  `Code` char(3) NOT NULL default '',
  `Name` char(52) NOT NULL default '',
  `Continent` enum('Asia','Europe','North America','Africa','Oceania','Antarctica','South America') NOT NULL default 'Asia',
  `Region` char(26) NOT NULL default '',
  `SurfaceArea` float(10,2) NOT NULL default '0.00',
  `IndepYear` smallint(6) default NULL,
  `Population` int(11) NOT NULL default '0',
  `LifeExpectancy` float(3,1) default NULL,
  `GNP` float(10,2) default NULL,
  `GNPOld` float(10,2) default NULL,
  `LocalName` char(45) NOT NULL default '',
  `GovernmentForm` char(45) NOT NULL default '',
  `HeadOfState` char(60) default NULL,
  `Capital` int(11) default NULL,
  `Code2` char(2) NOT NULL default '',
  PRIMARY KEY  (`Code`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Table structure for table `CountryLanguage`
--

DROP TABLE IF EXISTS `CountryLanguage`;
CREATE TABLE `CountryLanguage` (
  `CountryCode` char(3) NOT NULL default '',
  `Language` char(30) NOT NULL default '',
  `IsOfficial` enum('T','F') NOT NULL default 'F',
  `Percentage` float(4,1) NOT NULL default '0.0',
  PRIMARY KEY  (`CountryCode`,`Language`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

