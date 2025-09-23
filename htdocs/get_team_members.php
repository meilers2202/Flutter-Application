<?php
require_once 'db_config.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Überprüfen, ob die Methode POST ist
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Ungültige Anfragemethode."]);
    exit();
}

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

// Holen Sie den Teamnamen aus dem POST-Request
$teamName = $_POST['teamName'] ?? null;

if ($teamName === null || empty($teamName)) {
    echo json_encode(["success" => false, "message" => "Teamname fehlt."]);
    $conn->close();
    exit();
}

// SQL-Abfrage, um die group_id basierend auf dem Teamnamen zu finden
$stmt = $conn->prepare("SELECT id FROM groups WHERE name = ?");
$stmt->bind_param("s", $teamName);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Team nicht gefunden."]);
    $stmt->close();
    $conn->close();
    exit();
}

$row = $result->fetch_assoc();
$groupId = $row['id'];
$stmt->close();

// Jetzt die Benutzernamen abrufen, die diese group_id haben
$stmt = $conn->prepare("SELECT username FROM users WHERE group_id = ?");
$stmt->bind_param("i", $groupId); // 'i' für Integer
$stmt->execute();
$result = $stmt->get_result();

$members = [];
while($row = $result->fetch_assoc()) {
    $members[] = $row['username'];
}

echo json_encode([
    "success" => true,
    "teamName" => $teamName,
    "members" => $members
]);

$stmt->close();
$conn->close();
?>