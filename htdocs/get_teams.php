<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

$sql = "SELECT id, name FROM groups ORDER BY name ASC";
$result = $conn->query($sql);

$teams = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $teams[] = [
            'id' => $row['id'],
            'name' => $row['name']
        ];
    }
    echo json_encode(["success" => true, "teams" => $teams]);
} else {
    echo json_encode(["success" => true, "teams" => []]);
}

$conn->close();
?>