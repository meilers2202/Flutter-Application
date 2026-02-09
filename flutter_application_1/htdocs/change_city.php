<?php
// Endpoint to change a user's city/location. Requires username and new_city
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'db_service.php';


$username = $_POST['username'] ?? null;
$new_city = $_POST['new_city'] ?? null;

if (!$username || !$new_city) {
    echo json_encode(['success' => false, 'message' => 'Benötigte Felder fehlen.']);
    exit;
}

// Basic sanitization
$new_city = trim($new_city);
if (strlen($new_city) < 1) {
    echo json_encode(['success' => false, 'message' => 'Ungültiger Standort.']);
    exit;
}

// Fetch user id
$stmt = $pdo->prepare('SELECT id FROM users WHERE username = :username');
$stmt->execute(['username' => $username]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode(['success' => false, 'message' => 'Benutzer nicht gefunden.']);
    exit;
}

// Update city without password check
$update = $pdo->prepare('UPDATE users SET city = :city WHERE id = :id');
$ok = $update->execute(['city' => $new_city, 'id' => $user['id']]);

if ($ok) {
    echo json_encode(['success' => true, 'message' => 'Standort aktualisiert.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Aktualisieren des Standorts.']);
}
