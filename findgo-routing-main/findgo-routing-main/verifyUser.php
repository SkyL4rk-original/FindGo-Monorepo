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

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
include 'dbConnect.php';
include 'jwt.php';

$code = $_GET["code"];

// Check if user is Store Admin
$result = $db->query("
		SELECT userUuid
		FROM userVerifyLink
		WHERE code='$code'
		LIMIT 1
	");
if ($result->num_rows == 0) {
	http_response_code(401);
	//echo mysqli_error($db);
	echo '{"Message":"Wrong information or user has already used this link."}';
	return;
}

// Create user from database
$userTemp = $result->fetch_assoc();
$userUuid = $userTemp["userUuid"];

// get user from datatbase
$result = $db->query("SELECT * FROM userAdmin WHERE userUuid='$userUuid'");
if ($result->num_rows == 0) {
	http_response_code(401);
	//echo mysqli_error($db);
	echo '{"Message":"Incorrect user information"}';
	return;
}

// Create user from database
$user = $result->fetch_assoc();

// Create jwt from clientUuid & add as header
$token = createToken($user["userUuid"]);
$refreshToken = createRefreshToken($user["userUuid"]);
// add refreshToken to db
$result = $db->query("
		UPDATE userAdmin
		SET
			refreshToken='$refreshToken',
			verified=1
		WHERE userUuid='$userUuid'
	");

$result = $db->query("
		DELETE FROM userVerifyLink
		WHERE userUuid='$userUuid'
	");

// Remove variables
$user["ID"] = "";
$user["password"] = "";
$user["refreshToken"] = "";
unset($user["ID"]);
unset($user["password"]);
unset($user["refreshToken"]);

// Return json user object
http_response_code(200);
header("jwt: " . $token);
header("refresh-token: " . $refreshtoken);
echo json_encode($user);
