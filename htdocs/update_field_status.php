<?php
require_once 'db_service.php'; // stellt $pdo bereit
require_once 'fcm_config.php';

function base64UrlEncode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function getServiceAccount(string $path): ?array {
    if (!$path || !file_exists($path)) return null;
    $json = file_get_contents($path);
    $data = json_decode($json, true);
    return is_array($data) ? $data : null;
}

function getAccessToken(array $sa): ?string {
    $now = time();
    $header = ['alg' => 'RS256', 'typ' => 'JWT'];
    $claims = [
        'iss' => $sa['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => 'https://oauth2.googleapis.com/token',
        'iat' => $now,
        'exp' => $now + 3600,
    ];

    $jwtHeader = base64UrlEncode(json_encode($header));
    $jwtClaims = base64UrlEncode(json_encode($claims));
    $unsigned = $jwtHeader . '.' . $jwtClaims;

    $signature = '';
    $privateKey = $sa['private_key'] ?? '';
    if (!$privateKey) return null;

    openssl_sign($unsigned, $signature, $privateKey, 'sha256');
    $jwt = $unsigned . '.' . base64UrlEncode($signature);

    $post = http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt,
    ]);

    $ch = curl_init('https://oauth2.googleapis.com/token');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/x-www-form-urlencoded']);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
    $resp = curl_exec($ch);
    curl_close($ch);

    if (!$resp) return null;
    $data = json_decode($resp, true);
    return $data['access_token'] ?? null;
}

function sendFcmToTopicV1(string $accessToken, string $projectId, string $topic, string $title, string $body, array $data = []): void {
    $payload = json_encode([
        'message' => [
            'topic' => $topic,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'data' => $data,
        ],
    ]);

    $url = 'https://fcm.googleapis.com/v1/projects/' . $projectId . '/messages:send';
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $accessToken,
        'Content-Type: application/json',
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_exec($ch);
    curl_close($ch);
}

function sendFcmToTopicLegacy(string $serverKey, string $topic, string $title, string $body, array $data = []): void {
    $payload = json_encode([
        'to' => '/topics/' . $topic,
        'notification' => [
            'title' => $title,
            'body' => $body,
        ],
        'data' => $data,
    ]);

    $ch = curl_init('https://fcm.googleapis.com/fcm/send');
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: key=' . $serverKey,
        'Content-Type: application/json',
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_exec($ch);
    curl_close($ch);
}

try {
    // 1. Prüfen, ob field_id und new_status übergeben wurden
    $fieldId = $_POST['field_id'] ?? null;
    $newStatus = $_POST['new_status'] ?? null;

    if ($fieldId === null || $newStatus === null) {
        echo json_encode(['success' => false, 'message' => 'Unvollständige Daten. Erwarte field_id und new_status.']);
        exit;
    }

    // 2. Sicheres Casting auf Integer
    $fieldIdInt = (int)$fieldId;
    $newStatusInt = (int)$newStatus;

    // optional: validieren, ob newStatusInt in erlaubtem Bereich liegt (z.B. 0-3)
    $allowed = [0,1,2,3];
    if (!in_array($newStatusInt, $allowed, true)) {
        echo json_encode(['success' => false, 'message' => 'Ungültiger Status-Wert.']);
        exit;
    }

    // 3. Update mit Prepared Statement (PDO)
    $sql = "UPDATE fields SET checkstate = :newStatus WHERE id = :id";
    $stmt = $pdo->prepare($sql);
    $executed = $stmt->execute([
        'newStatus' => $newStatusInt,
        'id' => $fieldIdInt
    ]);

    if ($executed) {
        if ($stmt->rowCount() > 0) {
            if ($newStatusInt === 1) {
                $data = [
                    'type' => 'field_approved',
                    'field_id' => (string)$fieldIdInt,
                ];
                $sa = getServiceAccount($fcmServiceAccountPath ?? '');
                if ($sa && !empty($sa['project_id'])) {
                    $token = getAccessToken($sa);
                    if ($token) {
                        sendFcmToTopicV1($token, $sa['project_id'], 'all_users', 'Neues Spielfeld verfuegbar', 'Ein neues Spielfeld wurde freigegeben.', $data);
                    }
                } elseif (!empty($fcmServerKey)) {
                    sendFcmToTopicLegacy($fcmServerKey, 'all_users', 'Neues Spielfeld verfuegbar', 'Ein neues Spielfeld wurde freigegeben.', $data);
                }
            }
            echo json_encode(['success' => true, 'message' => "Status erfolgreich auf $newStatusInt geändert."]);
        } else {
            echo json_encode(['success' => false, 'message' => "Feld ID $fieldIdInt nicht gefunden oder Status bereits $newStatusInt."]);
        }
    } else {
        $err = $stmt->errorInfo();
        echo json_encode(['success' => false, 'message' => 'Fehler beim Update: ' . ($err[2] ?? 'Unbekannter Fehler')]);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Datenbankfehler: ' . $e->getMessage()]);
}
