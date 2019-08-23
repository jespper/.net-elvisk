drop database IF EXISTS eud5;
create database eud5 character set utf8;
use eud5;

#DROP TABLE IF EXISTS `elevtype`;
#DROP TABLE IF EXISTS `ordning`;

#Ordning er uddannelsen fra eud-adm. Fx. datauddannelser version 10
#indeholdenede datatekniker med infra/prog og IT-supporter indeholdende
#alle elevtyper
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

#Elevtype er em del af en ordning fx. "EUD og UNGDOM"
CREATE TABLE `elevtype` (
  `elevtype_id` smallint(5) unsigned NOT null AUTO_INCREMENT,
  `ordning_id` smallint(5) unsigned NOT NULL,
  `samling` varchar(255) NOT NULL,
  PRIMARY KEY (`elevtype_id`),
  CONSTRAINT `fk_ordning_id` FOREIGN KEY (`ordning_id`) REFERENCES `ordning` (`ordning_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
   


#Elevtyperaw er en midlertidig tabel anvendt mellem trin1 og trin2
#Indeholder alle linier fra originale PDF fra eud-adm om elevtypen.
#Bearbejdes i trin2 og er herefter overflødig.
CREATE TABLE `elevtyperaw` (
  `line_id` int unsigned NOT null AUTO_INCREMENT,
  `line` varchar(512) NOT NULL,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`line_id`),
  CONSTRAINT `fk_e_elevtype_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#Speciale indeholder en del af elevtype fx. IT-Supporter fra data ordning.
CREATE TABLE `speciale` (
  `speciale_id` int unsigned NOT null AUTO_INCREMENT,
  `speciale` varchar(512) NOT NULL,
#  `Faelles_fag` boolean not null default 0,
  `elevtype_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`speciale_id`),
  CONSTRAINT `fk_s_elevtype_id` FOREIGN KEY (`elevtype_id`) REFERENCES `elevtype` (`elevtype_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#Fag indeholder det grundlæggende fra et specifikt fag fra et speciale. Det samme
#fag kan forekommi i flere specialer, elevtyper og ordninger. Fx. Netværk I skal
#alle specialer (datatekniker infra/prog) og IT-Supporter have på data ordningen,
#men den eksisterer og i elektronik og andre.
CREATE TABLE `fag` (
  `fag_id` int unsigned NOT null AUTO_INCREMENT,
  `fagnr` smallint(5) unsigned NOT NULL,
  `tilknyt` varchar(128) NOT NULL,
  `opr_varighed` varchar(512) NOT NULL,
  `fagnavn` varchar(512) NOT NULL,
  PRIMARY KEY (`fag_id`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#En faginstans er en konkret instans af et fag. Det samme fag kan have flere niveauer
#fx. rutineret, avanceret og ekspert. Herudover kan det i fler tilfælde være bundet
#i et speciale men valgfri i et andet. (Varighed kan variere med forkortelse) 
CREATE TABLE `faginstans` (
  `faginstans_id` int unsigned NOT null AUTO_INCREMENT,
  `niveau` varchar(128) NOT NULL,
  `fagkat` varchar(128) NOT NULL,
  `fagtype` varchar(512) NOT NULL,
  `opr_varighed` varchar(128) NOT NULL,
  `afkortning` varchar(512) NOT NULL,
  `varighed` varchar(512) NOT NULL,
  `fag_id` int unsigned NOT null,
#  `speciale_id` int unsigned NOT NULL,
  PRIMARY KEY (`faginstans_id`),
  CONSTRAINT `fk_fag_id` FOREIGN KEY (`fag_id`) REFERENCES `fag` (`fag_id`)
#  CONSTRAINT `fk_speciale_id` FOREIGN KEY (`speciale_id`) REFERENCES `speciale` (`speciale_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#Resultatform varierer fra faginstanser fx. 12-skala bestået/ikke bestået. Kan være flere 
#resultatformer i samme faginstans.
CREATE TABLE `resultatform` (
  `resultatform_id` int unsigned NOT null AUTO_INCREMENT,
  `resultatform` varchar(256) NOT NULL,
  `faginstans_id` int unsigned NOT null,
  PRIMARY KEY (`resultatform_id`),
  CONSTRAINT `fk_r_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#pind indeholder målpinde fra en faginstans. Kan variere i forhold til fx. niveau avanceret/ekspert.
CREATE TABLE `pind` (
  `pind_id` int unsigned NOT null AUTO_INCREMENT,
  `pindnr` smallint(5) unsigned NOT NULL,
  `pind` varchar(256) NOT NULL,
  `dato` varchar(256) NOT NULL,
  PRIMARY KEY (`pind_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

# kombiner faginstanser og specialer. Gør det nemmere at lava wiki-sider
CREATE TABLE `kombiner_fag_spc` (
  `kombiner_fag_spc_id` int unsigned NOT null AUTO_INCREMENT,
  `speciale_id` int unsigned NOT NULL,
  `faginstans_id` int unsigned NOT NULL,
  PRIMARY KEY (`kombiner_fag_spc_id`),
  CONSTRAINT `fk_k_speciale_id` FOREIGN KEY (`speciale_id`) REFERENCES `speciale` (`speciale_id`),
  CONSTRAINT `fk_k_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
# kombiner pinde og faginstanser. Gør det nemmere at lava wiki-sider (undervise fag sammen)
CREATE TABLE `kombiner_fag_pin` (
  `kombiner_fag_pin_id` int unsigned NOT null AUTO_INCREMENT,
  `pind_id` int unsigned NOT NULL,
  `faginstans_id` int unsigned NOT NULL,
  PRIMARY KEY (`kombiner_fag_pin_id`),
  CONSTRAINT `fk_p_pind_id` FOREIGN KEY (`pind_id`) REFERENCES `pind` (`pind_id`),
  CONSTRAINT `fk_p_faginstans_id` FOREIGN KEY (`faginstans_id`) REFERENCES `faginstans` (`faginstans_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
