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

	include 'dbConnect.php';

	if($_SERVER["REQUEST_METHOD"] != "POST") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	$data = json_decode(file_get_contents('php://input'), true);
	$password = $data['password'];
	$code = $data["code"];
	$type = $data['type'];
	$platform = $data['platform'];

	$dbTableNameUser = "user";
	if ($type == "admin") $dbTableNameUser = "userAdmin";

	// check if token exists
	$result = $db->query("SELECT * FROM passwordResetToken WHERE code='$code'");
	if ($result->num_rows == 0) {
		http_response_code(409);
		//echo mysqli_error($db);
		echo '{"Message":"Incorrect Access Code"}';
		return;
	}
	$token = $result->fetch_assoc();
	$email = $token["email"];

	// Check if date valid
	//date_default_timezone_set('Africa/Johannesburg');
	$activeTill = strtotime($token["activeTill"]);
  $dtNow = strtotime(date('Y-m-d H:i:s'));


	$valid = false;
  if ($activeTill >= $dtNow) {
		$valid = true;

		// Hash password
		$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

		// Update Password
		$result = $db->query("
			UPDATE $dbTableNameUser
			SET password='$hashedPassword'
			WHERE email='$email'
		");
		// Check update success
		if (!$result) {
			http_response_code(500);
			echo '{"Message": "db update password: '. mysqli_error($db).'"}';
			return;
		}

		// Delete reset token token
		$result = $db->query("DELETE FROM passwordResetToken WHERE code='$code'");
		if (!$result) {
			http_response_code(500);
			//echo mysqli_error($db);
			echo '{"Message":"Error Delete"}';
			return;
		}

		// Remove refreshToken
		$result = $db->query("
			UPDATE $dbTableNameUser
			SET refreshToken=''
			WHERE email='$email'
		");

		if (!$result) {
			http_response_code(500);
			//echo mysqli_error($db);
			echo '{"Message":"Error Delete Access Token"}';
			return;
		}

		http_response_code(200);
		echo '{"Message":"Success"}';
	} else {
		http_response_code(401);
		echo '{"Message":"Invalid"}';
	}
?>
