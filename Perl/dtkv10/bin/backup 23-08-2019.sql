-- --------------------------------------------------------
-- Vært:                         192.168.116.20
-- Server-version:               5.7.27-0ubuntu0.16.04.1 - (Ubuntu)
-- ServerOS:                     Linux
-- HeidiSQL Version:             10.1.0.5464
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for eud5
CREATE DATABASE IF NOT EXISTS `eud5` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `eud5`;

-- Dumping structure for tabel eud5.elevtype
CREATE TABLE IF NOT EXISTS `elevtype` (
  `elevtype_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `ordning_id` smallint(5) unsigned NOT NULL,
  `samling` varchar(255) NOT NULL,
  PRIMARY KEY (`elevtype_id`),
  KEY `fk_ordning_id` (`ordning_id`),
  CONSTRAINT `fk_ordning_id` FOREIGN KEY (`ordning_id`) REFERENCES `ordning` (`ordning_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.elevtyperaw
CREATE TABLE IF NOT EXISTS `elevtyperaw` (
  `line_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line` text NOT NULL,
  `ordning_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`line_id`),
  KEY `fk_e_elevtype_id` (`ordning_id`),
  CONSTRAINT `fk_e_elevtype_id` FOREIGN KEY (`ordning_id`) REFERENCES `ordning` (`ordning_id`)
) ENGINE=InnoDB AUTO_INCREMENT=82377 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.fag
CREATE TABLE IF NOT EXISTS `fag` (
  `fag_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fagnr` smallint(5) unsigned NOT NULL,
  `tilknyt` varchar(128) NOT NULL,
  `opr_varighed` varchar(512) NOT NULL,
  `fagnavn` varchar(512) NOT NULL,
  PRIMARY KEY (`fag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=166281 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.faginstans
CREATE TABLE IF NOT EXISTS `faginstans` (
  `faginstans_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `niveau` varchar(128) NOT NULL,
  `fagkat` varchar(128) NOT NULL,
  `fagtype` varchar(512) NOT NULL,
  `opr_varighed` varchar(128) NOT NULL,
  `afkortning` varchar(512) NOT NULL,
  `varighed` varchar(512) NOT NULL,
  `fag_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`faginstans_id`),
  KEY `fk_fag_id` (`fag_id`),
  CONSTRAINT `fk_fag_id` FOREIGN KEY (`fag_id`) REFERENCES `fag` (`fag_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13080 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.kombiner_fag_pin
CREATE TABLE IF NOT EXISTS `kombiner_fag_pin` (
  `kombiner_fag_pin_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pind_id` int(10) unsigned NOT NULL,
  `faginstans_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`kombiner_fag_pin_id`),
  KEY `fk_p_pind_id` (`pind_id`),
  KEY `fk_p_faginstans_id` (`faginstans_id`),
  CONSTRAINT `fk_p_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`),
  CONSTRAINT `fk_p_pind_id` FOREIGN KEY (`pind_id`) REFERENCES `pind` (`pind_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26973 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.kombiner_fag_spc
CREATE TABLE IF NOT EXISTS `kombiner_fag_spc` (
  `kombiner_fag_spc_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `speciale_id` int(10) unsigned NOT NULL,
  `faginstans_id` int(10) unsigned NOT NULL,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`kombiner_fag_spc_id`),
  KEY `fk_k_speciale_id` (`speciale_id`),
  KEY `fk_k_faginstans_id` (`faginstans_id`),
  KEY `fk_k_elevtype_id` (`elevtype_id`),
  CONSTRAINT `fk_k_elevtype_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`),
  CONSTRAINT `fk_k_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`),
  CONSTRAINT `fk_k_speciale_id` FOREIGN KEY (`speciale_id`) REFERENCES `speciale` (`speciale_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16692 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.ordning
CREATE TABLE IF NOT EXISTS `ordning` (
  `ordning_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `bekendt` varchar(255) DEFAULT NULL,
  `version` varchar(20) DEFAULT NULL,
  `dato` date DEFAULT NULL,
  `revision_dato` date DEFAULT NULL,
  `udskrevet` date DEFAULT NULL,
  `udvalg` varchar(255) DEFAULT NULL,
  `ordning_nr` smallint(5) unsigned DEFAULT NULL,
  `antal_sider` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`ordning_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.pind
CREATE TABLE IF NOT EXISTS `pind` (
  `pind_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pindnr` smallint(5) unsigned NOT NULL,
  `pind` text NOT NULL,
  `dato` varchar(256) NOT NULL,
  PRIMARY KEY (`pind_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21307 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.resultatform
CREATE TABLE IF NOT EXISTS `resultatform` (
  `resultatform_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `resultatform` varchar(256) NOT NULL,
  `faginstans_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`resultatform_id`),
  KEY `fk_r_faginstans_id` (`faginstans_id`),
  CONSTRAINT `fk_r_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5254 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
-- Dumping structure for tabel eud5.speciale
CREATE TABLE IF NOT EXISTS `speciale` (
  `speciale_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `speciale` varchar(512) NOT NULL,
  PRIMARY KEY (`speciale_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1222 DEFAULT CHARSET=utf8;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
