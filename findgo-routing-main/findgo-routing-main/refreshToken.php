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


	if($_SERVER["REQUEST_METHOD"] != "POST") {
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

	// Check token is valid
	$userUuid = verifyRefreshToken($refreshToken);

	// Check refreshToken active in db
	$result = $db->query("SELECT refreshToken FROM $dbTableNameUser WHERE refreshToken='$refreshToken'");
	if ($result->num_rows == 0) {
		http_response_code(401);
		echo '{"Message":"No token stored"}';
		//echo mysqli_error($db);
		//echo '{"Message":"No Token"}';
		return;
	}

	// Create jwt from clientUuid & add as header
	$token = createToken($userUuid);
	header("jwt: ".$token);
	//setcookie("token", $token, 20000);
	//$user["token"] = $token;

	http_response_code(200);
	echo '{"Message":"success"}';
?>
