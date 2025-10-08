<?php

$host = 'localhost';        // Hostname (meistens 'localhost')
$db   = 'db_airsoftapp'; // Name deiner Datenbank
$user = 'test';    // Datenbank-Benutzername
$pass = 'g3k45#E437_34';        // Datenbank-Passwort
$charset = 'utf8mb4';       // Zeichenkodierung

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

?>