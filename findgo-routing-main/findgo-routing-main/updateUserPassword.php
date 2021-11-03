<?php
	header('Access-Control-Allow-Origin: *');
	header('Access-Control-Allow-Methods: POST, GET, DELETE, PUT, PATCH, OPTIONS');
	header('Access-Control-Allow-Headers: *');
	header('Access-Control-Expose-Headers: *');
	header('Content-Type: application/json');

	if ($_SERVER["REQUEST_METHOD"] == "OPTIONS") {
		header('Access-Control-Allow-Origin: *');
		header('Access-Control-Allow-Headers: *');
		header("HTTP/1.1 200 OK");
		return;
	}

	if($_SERVER["REQUEST_METHOD"] != "PATCH") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	include 'dbConnect.php';
	include 'jwt.php';

	// Check token is valid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	$data = json_decode(file_get_contents('php://input'), true);
	$newPassword = $data['newPassword'];
	$password = $data['password'];
	$type = $data["type"]; // admin / general

	// Set type database table name for user type
	$dbTableNameUser = "user";
	if ($type == "admin") $dbTableNameUser = "userAdmin";


	// Get user password from datatbase
	$result = $db->query("SELECT password FROM $dbTableNameUser WHERE userUuid='$userUuid'");
	if ($result->num_rows == 0) {
		http_response_code(401);
		//echo mysqli_error($db);
		echo '{"Message":"No user found"}';
		return;
	}
	// Create user from database
	$user = $result->fetch_assoc();

	// Check password
	if (!password_verify($password, $user["password"])) {
		http_response_code(401);
		echo '{"Message":"Incorrect Password"}';
		// TODO Send email of attempted password change
		return;
	}

	// Hash password
	$newHashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);

	// Udate user in datatbase
	$result = $db->query("UPDATE $dbTableNameUser SET password='$newHashedPassword' WHERE userUuid='$userUuid'");
	if (!$result) {
		http_response_code(500);
		//echo mysqli_error($db);
		echo '{"Message":"update db error"}';
		return;
	}

	// TODO Send email of attempted password change
	echo '{"Message":"Update password success"}';
?>
