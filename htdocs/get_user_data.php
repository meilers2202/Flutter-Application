<?php
// Fehleranzeige zum Debuggen
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');

// Nutze db_service.php (wie in deinem zweiten Beispiel)
require_once 'db_service.php'; 

// 1. DATEN-IMPORT (Hybrid-Lösung)
// Versuche zuerst JSON aus dem Body zu lesen
$json_data = json_decode(file_get_contents('php://input'), true);

// Nimm den Usernamen entweder aus dem JSON ODER aus dem normalen $_POST
$username = $json_data['username'] ?? $_POST['username'] ?? null;

if (!$username) {
    echo json_encode(['success' => false, 'message' => 'Benutzername fehlt.']);
    exit();
}

try {
    // 2. SQL-ABFRAGE (mit JOINs für das Team)
    $sql = "SELECT 
                u.username, 
                u.email, 
                u.city, 
                u.created_at, 
                g.name AS team 
            FROM users u
            LEFT JOIN groups g ON u.group_id = g.id 
            WHERE u.username = :username";

    $stmt = $pdo->prepare($sql);
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user) {
        // Datum schön formatieren
        $memberSince = date("d.m.Y", strtotime($user['created_at']));
        
        echo json_encode([
            'success' => true, 
            'user' => [
                'username' => $user['username'],
                'email' => $user['email'],
                'city' => $user['city'],
                'team' => $user['team'] ?? 'Kein Team',
                'memberSince' => $memberSince
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Benutzer nicht gefunden.']);
    }

} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Datenbankfehler: ' . $e->getMessage()]);
}
?>