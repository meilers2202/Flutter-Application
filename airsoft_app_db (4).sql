-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 25. Sep 2025 um 15:02
-- Server-Version: 10.4.32-MariaDB
-- PHP-Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `airsoft_app_db`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `checkstate`
--

CREATE TABLE `checkstate` (
  `id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `color_hint` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `checkstate`
--

INSERT INTO `checkstate` (`id`, `status_name`, `color_hint`) VALUES
(0, 'In Prüfung', 'Grau'),
(1, 'Genehmigt', 'Grün'),
(2, 'In Klärung', 'Gelb'),
(3, 'Abgelehnt', 'Rot');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `fieldowner`
--

CREATE TABLE `fieldowner` (
  `user_id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `fieldowner`
--

INSERT INTO `fieldowner` (`user_id`, `name`) VALUES
(1, 'Marvin Eilers');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `fields`
--

CREATE TABLE `fields` (
  `id` int(11) NOT NULL,
  `fieldname` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `rules` text DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `housenumber` varchar(50) DEFAULT NULL,
  `postalcode` varchar(20) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `field_owner_id` int(11) UNSIGNED NOT NULL,
  `checkstate` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `fields`
--

INSERT INTO `fields` (`id`, `fieldname`, `description`, `rules`, `street`, `housenumber`, `postalcode`, `city`, `company`, `field_owner_id`, `checkstate`) VALUES
(5, 'Feldname', 'Beschreibung', 'Regeln', 'Straße', 'Hausnummer', 'PLZ', 'Stadt', 'Firma', 1, 1),
(6, 'Airsoft GMBBH', 'Ein ausgeglichener Airsoftplatz zum spielen', '1. Keine Toten', 'Tannenstraße', '15', '09112', 'Chemnitz', 'SFZ Förderzentrum gGmbH', 1, 3),
(11, 'Testfeld Name', 'Ein großes, abwechslungsreiches Testgelände für Airsoft.', '1. 1,5 Joule Limit. 2. Keine Blind-Shots. 3. Schutzbrille Pflicht.', 'Tannenstraße', '15', '09112', 'Chemnitz', 'SFZ Förderzentrum gGmbH', 1, 1),
(12, 'testfeld', 'groß', 'kein draufgehen', 'Tannenstraße', '15', '09112', 'Chemnitz', 'SFZ', 1, 0);

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `groups`
--

INSERT INTO `groups` (`id`, `name`) VALUES
(1, 'Racoons'),
(2, 'fe');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `roles`
--

CREATE TABLE `roles` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `roles`
--

INSERT INTO `roles` (`id`, `name`) VALUES
(2, 'Teamleader'),
(1, 'user');

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `users`
--

CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `group_id` int(11) UNSIGNED DEFAULT NULL,
  `role` varchar(50) NOT NULL,
  `teamrole` int(11) UNSIGNED DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `policy_accepted` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Daten für Tabelle `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `city`, `group_id`, `role`, `teamrole`, `created_at`, `policy_accepted`) VALUES
(1, 'Marvin Eilers', '$2y$10$2fAKtOMZulZ/w71t3CSlPO/0GNEqQKx4CdPm9r41wyRRcCcoNoCfm', 'larvineilers222@gmail.com', 'Chemnitz', 1, 'admin', 2, '2025-09-23 15:56:45', 0),
(9, 'fe', '$2y$10$kvMUTR.fvIenBdx.Flf5iuPgvnZ/QG2.bKz4a9ADZS5HBLHgNOtIC', 'fe', '0', 1, 'user', 1, '2025-09-25 12:03:03', 1),
(10, 'ge', '$2y$10$JyUqNmdNNTgbP2fnaix5WOKiOESO539uAfyMFm6GTXI0iWmJnynPu', 'ge', 'ge', 1, 'user', 1, '2025-09-25 12:05:34', 1);

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `checkstate`
--
ALTER TABLE `checkstate`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `fieldowner`
--
ALTER TABLE `fieldowner`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indizes für die Tabelle `fields`
--
ALTER TABLE `fields`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fieldname` (`fieldname`),
  ADD KEY `field_owner_id` (`field_owner_id`);

--
-- Indizes für die Tabelle `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`);

--
-- Indizes für die Tabelle `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indizes für die Tabelle `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `fieldowner`
--
ALTER TABLE `fieldowner`
  MODIFY `user_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT für Tabelle `fields`
--
ALTER TABLE `fields`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT für Tabelle `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT für Tabelle `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints der exportierten Tabellen
--

--
-- Constraints der Tabelle `fields`
--
ALTER TABLE `fields`
  ADD CONSTRAINT `fields_ibfk_1` FOREIGN KEY (`field_owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
