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
	$result = $db->query("SELECT * FROM user WHERE userUuid='$userUuid'");
	if ($result->num_rows == 0) {
		http_response_code(500);
		//echo mysqli_error($db);
		echo '{"Message":"No user found"}';
		return;
	}

	// Get all store roles for user
	$resultRoles = $db->query("
		SELECT storeUuid, role
		FROM storeUserRoleLink
		WHERE userUuid='$userUuid' AND role>0
	");
	if (!$result) {
		http_response_code(500);
		echo '{"Message":"Database select store role user error: '.mysqli_error($db).'"}';
		return;
	}
	while( $row = $resultRoles->fetch_assoc() ) {
		$storeRoleArr[$row["storeUuid"]] = $row["role"];
	}

	// Create user from database
	$user = $result->fetch_assoc();
	// Add storeRoleMap to user
	$user["storeRoleMap"] = $storeRoleArr;

	// Remove ID & password
	$user["ID"] = "";
	$user["password"] = "";
	unset($user["ID"]);
	unset($user["password"]);

	// Create jwt from clientUuid & add as header
	$token = createToken($user["userUuid"]);
	header("jwt: ".$token);
	//setcookie("token", $token, 20000);
	//$user["token"] = $token;

	echo json_encode($user);
