drop database eud2;
create database eud2 character set utf8;
use eud2;

DROP TABLE IF EXISTS `elevtype`;
DROP TABLE IF EXISTS `ordning`;

CREATE TABLE `ordning` (
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
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `elevtype` (
  `elevtype_id` smallint(5) unsigned NOT null AUTO_INCREMENT,
  `ordning_id` smallint(5) unsigned NOT NULL,
  `samling` varchar(255) NOT NULL,
  PRIMARY KEY (`elevtype_id`),
  CONSTRAINT `fk_elevtype_id` FOREIGN KEY (`ordning_id`) REFERENCES `ordning` (`ordning_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
   



CREATE TABLE `elevtyperaw` (
  `line_id` int unsigned NOT null AUTO_INCREMENT,
  `line` varchar(512) NOT NULL,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`line_id`),
  CONSTRAINT `fk_elevtyperaw_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `speciale` (
  `speciale_id` int unsigned NOT null AUTO_INCREMENT,
  `speciale` varchar(512) NOT NULL,
#  `Faelles_fag` boolean not null default 0,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`speciale_id`),
  CONSTRAINT `fk_speciale_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fag` (
  `fag_id` int unsigned NOT null AUTO_INCREMENT,
  `fagnr` smallint(5) unsigned NOT NULL,
  `fagnavn` varchar(512) NOT NULL,
  `tilknyt` varchar(128) NOT NULL,
  `opr_varighed` varchar(128) NOT NULL,
  PRIMARY KEY (`fag_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `faginstans` (
  `faginstans_id` int unsigned NOT null AUTO_INCREMENT,
  `niveau` varchar(128) NOT NULL,
  `fagkat` varchar(128) NOT NULL,
  `fagtype` varchar(512) NOT NULL,
  `fag_id` int unsigned NOT null,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`faginstans_id`),
  CONSTRAINT `fk_fag_id` FOREIGN KEY (`fag_id`) REFERENCES `fag` (`fag_id`),
  CONSTRAINT `fk2_speciale_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `resultatform` (
  `resultatform_id` int unsigned NOT null AUTO_INCREMENT,
  `resultatform` varchar(256) NOT NULL,
  `faginstans_id` int unsigned NOT null,
  PRIMARY KEY (`resultatform_id`),
  CONSTRAINT `fk_resultatform_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
