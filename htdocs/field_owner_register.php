<?php
require_once 'db_service.php'; // stellt $pdo bereit
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Daten aus Flutter entgegennehmen (JSON oder Form-POST)
$data = json_decode(file_get_contents("php://input"), true);
$username = $data['username'] ?? ($_POST['username'] ?? '');
$password = $data['password'] ?? ($_POST['password'] ?? '');

// 1. Eingaben validieren
if (empty($username) || empty($password)) {
    echo json_encode([
        "success" => false,
        "message" => "Benutzername und Passwort sind erforderlich."
    ]);
    exit;
}

try {
    // 2. Benutzer in 'users' suchen
    $stmt = $pdo->prepare("SELECT id, password FROM users WHERE username = :username");
    $stmt->execute(['username' => $username]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        echo json_encode([
            "success" => false,
            "message" => "Benutzername existiert nicht. Bitte zuerst als Spieler registrieren."
        ]);
        exit;
    }

    $userId = $user['id'];
    $hashedPassword = $user['password'];

    // 3. Passwort prüfen
    if (!password_verify($password, $hashedPassword)) {
        echo json_encode([
            "success" => false,
            "message" => "Falsches Passwort."
        ]);
        exit;
    }

    // 4. Prüfen, ob User bereits Field Owner ist
    $stmt = $pdo->prepare("SELECT user_id FROM fieldowner WHERE user_id = :user_id");
    $stmt->execute(['user_id' => $userId]);

    if ($stmt->fetch()) {
        echo json_encode([
            "success" => false,
            "message" => "Dieser Benutzer existiert bereits als Field Owner."
        ]);
        exit;
    }

    // 5. Benutzer als Field Owner eintragen
    $stmt = $pdo->prepare("INSERT INTO fieldowner (user_id, name) VALUES (:user_id, :name)");
    $stmt->execute([
        'user_id' => $userId,
        'name' => $username
    ]);

    echo json_encode([
        "success" => true,
        "message" => "Erfolgreich als Field Owner registriert. Sie können sich nun anmelden."
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Datenbankfehler: " . $e->getMessage()
    ]);
}
