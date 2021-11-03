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
	} else if($_SERVER["REQUEST_METHOD"] != "GET") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	include 'dbConnect.php';
	include 'jwt.php';

	$type = $_GET['type'];
	// Set type database table name for user type
	$dbTableNameUser = "user";
	if ($type == "admin") $dbTableNameUser = "userAdmin";

	// Check token is vaid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	if ($type != "admin") {
		$firebaseToken = trim($_SERVER['HTTP_FB_TOKEN']);
		if ($firebaseToken != "") {
			$result = $db->query("UPDATE $dbTableNameUser SET firebaseToken='$firebaseToken' WHERE userUuid = '$userUuid'");
		}
	}

	// get user from datatbase
	$result = $db->query("SELECT * FROM $dbTableNameUser WHERE userUuid = '$userUuid'");
	if ($result->num_rows == 0) {
		http_response_code(500);
		//echo mysqli_error($db);
		echo '{"Message":"No user found"}';
		return;
	}

	// Create user from database
	$user = $result->fetch_assoc();

	// Remove ID & password
	$user["ID"] = "";
	$user["password"] = "";
	$user["refreshToken"] = "";
	unset($user["ID"]);
	unset($user["password"]);
	unset($user["refreshToken"]);

	// Create jwt from clientUuid & add as header
	$token = createToken($user["userUuid"]);
	header("jwt: ".$token);
	//setcookie("token", $token, 20000);
	//$user["token"] = $token;

	echo json_encode($user);
?>
