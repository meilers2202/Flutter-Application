-- --------------------------------------------------------
-- Host:                         second-humanity.com
-- Server-Version:               10.11.13-MariaDB-0ubuntu0.24.04.1 - Ubuntu 24.04
-- Server-Betriebssystem:        debian-linux-gnu
-- HeidiSQL Version:             12.12.0.7122
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Exportiere Struktur von Tabelle db_airsoftapp.checkstate
CREATE TABLE IF NOT EXISTS `checkstate` (
  `id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `color_hint` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.checkstate: ~4 rows (ungefähr)
INSERT INTO `checkstate` (`id`, `status_name`, `color_hint`) VALUES
	(0, 'In Prüfung', 'Grau'),
	(1, 'Genehmigt', 'Grün'),
	(2, 'In Klärung', 'Gelb'),
	(3, 'Abgelehnt', 'Rot');

-- Exportiere Struktur von Tabelle db_airsoftapp.fieldowner
CREATE TABLE IF NOT EXISTS `fieldowner` (
  `user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.fieldowner: ~1 rows (ungefähr)
INSERT INTO `fieldowner` (`user_id`, `name`) VALUES
	(1, 'Marvin Eilers');

-- Exportiere Struktur von Tabelle db_airsoftapp.fields
CREATE TABLE IF NOT EXISTS `fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldname` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `rules` text DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `housenumber` varchar(50) DEFAULT NULL,
  `postalcode` varchar(20) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `field_owner_id` int(11) unsigned NOT NULL,
  `checkstate` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `fieldname` (`fieldname`),
  KEY `field_owner_id` (`field_owner_id`),
  CONSTRAINT `fields_ibfk_1` FOREIGN KEY (`field_owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.fields: ~0 rows (ungefähr)

-- Exportiere Struktur von Tabelle db_airsoftapp.groups
CREATE TABLE IF NOT EXISTS `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.groups: ~1 rows (ungefähr)
INSERT INTO `groups` (`id`, `name`) VALUES
	(1, 'Racoons');

-- Exportiere Struktur von Tabelle db_airsoftapp.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.roles: ~2 rows (ungefähr)
INSERT INTO `roles` (`id`, `name`) VALUES
	(1, 'user'),
	(2, 'Teamleader');

-- Exportiere Struktur von Tabelle db_airsoftapp.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `group_id` int(11) unsigned DEFAULT NULL,
  `role` varchar(50) NOT NULL,
  `teamrole` int(11) unsigned DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `policy_accepted` tinyint(1) NOT NULL DEFAULT 0,
  `blocked` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Exportiere Daten aus Tabelle db_airsoftapp.users: ~2 rows (ungefähr)
INSERT INTO `users` (`id`, `username`, `password`, `email`, `city`, `group_id`, `role`, `teamrole`, `created_at`, `policy_accepted`, `blocked`) VALUES
	(1, 'Marvin Eilers', '$2y$10$2fAKtOMZulZ/w71t3CSlPO/0GNEqQKx4CdPm9r41wyRRcCcoNoCfm', 'larvineilers222@gmail.com', 'Chemnitz', 1, 'admin', 2, '2025-09-23 15:56:45', 0, 0),
	(18, 'fe', '$2y$10$O1I4XwCOUkaqcx4/GANnIuvwxZZFJ9EA2bTNPzZccvzeBON3NLTwq', 'fe', 'fe', 1, 'user', 1, '2025-10-08 13:43:36', 1, 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
