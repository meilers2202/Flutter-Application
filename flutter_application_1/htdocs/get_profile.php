<?php
// Zum Debuggen (sollte im Produktivbetrieb deaktiviert sein)
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Pfad zu Ihrer Datenbankverbindung (muss existieren)
require_once 'db_service.php'; 

// **WICHTIG:** Dies ist Ihre Flutter-Konstante, die wir für die absolute URL verwenden.
$base_url = "https://second-humanity.com/appdata/"; 

// Stellen Sie sicher, dass der Benutzername im POST-Body vorhanden ist
$username_to_fetch = $_POST['username'] ?? null;

if ($username_to_fetch === null) {
    header('Content-Type: application/json');
    echo json_encode(["success" => false, "message" => "Benutzername fehlt."]);
    exit;
}

// SQL-Abfrage inklusive der neuen Spalte users.profile_image_url
$sql = "SELECT 
            users.username, 
            users.email, 
            users.city, 
            users.created_at, 
            users.role as userRole, 
            groups.name AS team, 
            roles.name AS teamrole, 
            ingameroles.name AS ingamerole,
                users.ingamerole_id,
            users.profile_image_url 
        FROM users 
        LEFT JOIN groups ON users.group_id = groups.id 
        LEFT JOIN roles ON users.teamrole = roles.id 
        LEFT JOIN ingameroles ON users.ingamerole_id = ingameroles.id
        WHERE users.username = :username";

$stmt = $pdo->prepare($sql);
$stmt->execute(['username' => $username_to_fetch]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

header('Content-Type: application/json');

if ($user) {
    $memberSince = date("d.m.Y", strtotime($user['created_at']));
    
    $profileImageUrl = null;
    
    // Wenn in der Datenbank ein relativer Pfad gespeichert ist (z.B. IMAGES/USER/1/LOGO.jpg)
    if (!empty($user['profile_image_url'])) {
        // Erstelle die vollständige URL: https://second-humanity.com/appdata/IMAGES/USER/1/LOGO.jpg
        $profileImageUrl = $base_url . $user['profile_image_url']; 
    }

    echo json_encode([
        "success" => true,
        "user" => [
            "username" => $user['username'],
            "email" => $user['email'],
            "city" => $user['city'],
            "team" => $user['team'],
            "memberSince" => $memberSince,
            "teamrole" => $user['teamrole'],
            "role" => $user['userRole'],
            "ingamerole" => $user['ingamerole'],
            "profile_image_url" => $profileImageUrl, // Sende die vollständige URL (oder null)
        ]
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Benutzer nicht gefunden."]);
}
?>