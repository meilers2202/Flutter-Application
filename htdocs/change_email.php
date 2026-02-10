<?php
// Endpoint to change a user's email address. Requires username, current_password, new_email
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'db_service.php';

$username = $_POST['username'] ?? null;
$current_password = $_POST['current_password'] ?? null;
$new_email = $_POST['new_email'] ?? null;

if (!$username || !$current_password || !$new_email) {
    echo json_encode(['success' => false, 'message' => 'Benötigte Felder fehlen.']);
    exit;
}

// Basic email validation
if (!filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Ungültige E-Mail-Adresse.']);
    exit;
}

// Fetch user
$stmt = $pdo->prepare('SELECT id, password FROM users WHERE username = :username');
$stmt->execute(['username' => $username]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode(['success' => false, 'message' => 'Benutzer nicht gefunden.']);
    exit;
}

if (!password_verify($current_password, $user['password'])) {
    echo json_encode(['success' => false, 'message' => 'Aktuelles Passwort ist falsch.']);
    exit;
}

// Update email
$update = $pdo->prepare('UPDATE users SET email = :email WHERE id = :id');
$ok = $update->execute(['email' => $new_email, 'id' => $user['id']]);

if ($ok) {
    echo json_encode(['success' => true, 'message' => 'E-Mail aktualisiert.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Aktualisieren der E-Mail.']);
}
