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
} else if ($_SERVER["REQUEST_METHOD"] != "GET") {
	http_response_code(405);
	echo '{"Message":"Wrong HTTP method"}';
	return;
}

include 'dbConnect.php';
include 'jwt.php';

// Check token is valid
$userUuid = verifyToken();
if (!$userUuid) {
	return;
}

$storeUuid = $_GET["store"];

$result = $db->query("
			SELECT
				u.userUuid,
				email,
				firstName,
				lastName
			FROM storeUserLink sul
			INNER JOIN userAdmin AS u
			ON u.userUuid = sul.userUuid
			WHERE sul.storeUuid='$storeUuid' AND u.status>0
		");
$userList = array();
while ($row = $result->fetch_assoc()) {
	array_push($userList, $row);
}

// Return json user object
http_response_code(200);
echo json_encode($userList);
