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
	//include 'emailAuth.php';

	// Check token is valid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	$data = json_decode(file_get_contents('php://input'), true);
	$email = $data['email'];
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
		echo '{"Message":"Incorrect user information"}';
		return;
	}
	// Create user from database
	$user = $result->fetch_assoc();

	// Check password
	if (!password_verify($password, $user["password"])) {
		http_response_code(401);
		echo '{"Message":"Incorrect user information"}';
		// TODO Send email of attempted password change
		return;
	}

	// Udate user in datatbase
	$result = $db->query("UPDATE $dbTableNameUser SET refreshToken='', firebaseToken='', status=0 WHERE userUuid='$userUuid'");
	if (!$result) {
		http_response_code(500);
		//echo mysqli_error($db);
		echo '{"Message":"update db error"}';
		return;
	}

	// Delete all access tokens
//	$result = $db->query("DELETE FROM activeToken WHERE email='$email'");
//	if (!$result) {
//		http_response_code(500);
//		//echo mysqli_error($db);
//		echo '{"Message":"Error Delete Access Token"}';
//		return;
//	}

	// TODO SEND EMAIL ON DEACTIVATE
	// Send deactivate account confirmation email
//	$username = $firstName.' '.$lastName;
//	if ($type == "bus") {$username = $lastName;}
//	emailDeleteAccount($email, $username);

	// TODO Send email of attempted password change
	http_response_code(204);
	echo '{"Message":"delete account success"}';
?>
