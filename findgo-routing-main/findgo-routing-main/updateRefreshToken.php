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

	$data = json_decode(file_get_contents('php://input'), true);
	$refreshToken = $data['refreshToken'];
	$type = $data["type"]; // admin / general

	// Set type database table name for user type
	$dbTableNameUser = "user";
	if ($type == "admin") $dbTableNameUser = "userAdmin";
	
	// Check token not empty
	if ($refreshToken == null || $refreshToken == "") {
		http_response_code(401);
		return;
	}

	// Check refreshToken active in db
	$result = $db->query("SELECT refreshToken, userUuid FROM $dbTableNameUser WHERE refreshToken='$refreshToken'");
	if ($result->num_rows == 0) {
		http_response_code(401);
		//echo mysqli_error($db);
		echo '{"Message":"No Token Found"}';
		return;
	}
	$user = $result->fetch_assoc();

	// Create refresh token from clientUuid & add as header
	$jwt = createToken($user["userUuid"]);
	$token = createRefreshToken($user["userUuid"]);
	// Add refreshToken to database
	$result = $db->query("UPDATE $dbTableNameUser SET refreshToken='$token' WHERE refreshToken='$refreshToken'");
	if (!$result) {
		http_response_code(401);
		//echo mysqli_error($db);
		echo '{"Message":"Token Update Error"}';
		return;
	}

	header("jwt: ".$jwt);
	header("refreshToken: ".$token);
	//setcookie("token", $token, 20000);
	//$user["token"] = $token;

	http_response_code(200);
	echo '{"Message":"success"}';
?>
