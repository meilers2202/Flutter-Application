<?php
require_once 'db_service.php'; // stellt $pdo bereit


try {
    // Prüfen, ob alle notwendigen Daten vorhanden sind
    if (
        isset($_POST['username']) &&
        isset($_POST['password']) &&
        isset($_POST['email']) &&
        isset($_POST['city']) &&
        isset($_POST['group_id'])
    ) {
        $username = $_POST['username'];
        $password = $_POST['password'];
        $email = $_POST['email'];
        $city = $_POST['city'];
        $groupId = intval($_POST['group_id']);

        // Prüfen, ob der Benutzername bereits existiert
        $stmt = $pdo->prepare("SELECT id FROM users WHERE username = :username");
        $stmt->execute(['username' => $username]);

        if ($stmt->fetch()) {
            echo json_encode([
                "success" => false,
                "message" => "Benutzername existiert bereits."
            ]);
            exit();
        }

        // Passwort hashen
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        $role = 'user';
        $policyAccepted = 1;

        // Benutzer einfügen
        $stmt = $pdo->prepare("
            INSERT INTO users (username, password, email, city, group_id, role, policy_accepted)
            VALUES (:username, :password, :email, :city, :group_id, :role, :policy_accepted)
        ");

        $success = $stmt->execute([
            'username' => $username,
            'password' => $hashedPassword,
            'email' => $email,
            'city' => $city,
            'group_id' => $groupId,
            'role' => $role,
            'policy_accepted' => $policyAccepted
        ]);

        if ($success) {
            echo json_encode([
                "success" => true,
                "message" => "Registrierung erfolgreich!"
            ]);
        } else {
            echo json_encode([
                "success" => false,
                "message" => "Fehler bei der Registrierung. Bitte versuche es erneut."
            ]);
        }

    } else {
        echo json_encode([
            "success" => false,
            "message" => "Unvollständige Daten. Erwarte: username, password, email, city, group_id."
        ]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "message" => "Datenbankfehler: " . $e->getMessage()
    ]);
}
