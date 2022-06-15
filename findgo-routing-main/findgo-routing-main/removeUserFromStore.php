<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, DELETE, PUT, PATCH, OPTIONS');
header('Access-Control-Allow-Headers: *');
header('Access-Control-Expose-Headers: *');
header("Content-Type: application/json");

if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
	header('Access-Control-Allow-Origin: *');
	header('Access-Control-Allow-Headers: *');
	header("HTTP/1.1 200 OK");
	return;
} else if ($_SERVER["REQUEST_METHOD"] != "POST") {
	http_response_code(405);
	echo '{"Message":"Wrong HTTP method"}';
	return;
}

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
include 'dbConnect.php';
include 'jwt.php';

// Check token is valid
$userUuid = verifyToken();
if (!$userUuid) {
	return;
}

$data = json_decode(file_get_contents('php://input'), true);
$storeUuid = $data["storeUuid"];
$storeUserUuid = $data["userUuid"];

// Check if user is not Super Admin
$result = $db->query("
			SELECT role
			FROM userAdmin
			WHERE userUuid='$userUuid' AND status>0
			LIMIT 1
		");
$userIsSuperAdmin = $result->num_rows == 1;

// Check if user is Store Admin
$result = $db->query("
			SELECT userUuid
			FROM storeUserLink
			WHERE userUuid='$userUuid' AND storeUuid='$storeUuid'
			LIMIT 1
		");
$userIsAdmin = $result->num_rows == 1;

if ($userIsSuperAdmin || $userIsAdmin) {
	$result = $db->query("
			DELETE FROM storeUserLink
			WHERE userUuid='$userUuid' AND storeUuid='$storeUuid'
		");
} else {
	http_response_code(401);
	echo json_encode('"Message", "Access Denied"');
	return;
}

// Return json user object
http_response_code(200);
echo json_encode('"Message", "Success"');
