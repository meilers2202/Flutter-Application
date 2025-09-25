<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

// Prüft, ob alle notwendigen Registrierungsdaten vom Client gesendet wurden.
if (isset($_POST['username']) && isset($_POST['password']) && isset($_POST['email']) && isset($_POST['city']) && isset($_POST['group_id'])) { 
    $inputUsername = $_POST['username'];
    $inputPassword = $_POST['password'];
    $inputEmail = $_POST['email'];
    $inputCity = $_POST['city'];
    $inputGroupId = $_POST['group_id'];

    // Prüfen, ob der Benutzername bereits existiert
    $stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
    $stmt->bind_param("s", $inputUsername);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "Benutzername existiert bereits."]);
    } else {
        $hashedPassword = password_hash($inputPassword, PASSWORD_DEFAULT);
        
        $defaultRole = 'user';
        $policyAccepted = 1; // Die Policy gilt als akzeptiert, da die Registrierung nur so möglich ist.
        
        // Konvertierung der group_id in einen Integer, da sie in der Datenbank so gespeichert wird.
        $inputGroupIdInt = intval($inputGroupId);

        // INSERT Statement mit der neuen Spalte policy_accepted
        $stmt = $conn->prepare("INSERT INTO users (username, password, email, city, group_id, role, policy_accepted) VALUES (?, ?, ?, ?, ?, ?, ?)");
        
        // Parameter-Bindung: 7 Parameter
        // s (username), s (password), s (email), s (city), i (group_id), s (defaultRole), i (policyAccepted)
        if (!$stmt->bind_param("ssssisi", $inputUsername, $hashedPassword, $inputEmail, $inputCity, $inputGroupIdInt, $defaultRole, $policyAccepted)) {
            // Fehlerausgabe, falls die Parameterbindung fehlschlägt
            echo json_encode(["success" => false, "message" => "Bindungsfehler: " . $stmt->error]);
            $stmt->close();
            $conn->close();
            exit();
        }

        if ($stmt->execute()) {
            echo json_encode(["success" => true, "message" => "Registrierung erfolgreich!"]);
        } else {
            // Hilfsausgabe: Zeigt den genauen SQL-Fehler an, falls die Ausführung fehlschlägt
            echo json_encode(["success" => false, "message" => "Fehler bei der Registrierung. SQL-Fehler: " . $stmt->error]);
        }
    }

    $stmt->close();
} else {
    echo json_encode(["success" => false, "message" => "Unvollständige Daten. Erwarte: username, password, email, city, group_id."]);
}

$conn->close();
?>