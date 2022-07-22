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

if ($_SERVER["REQUEST_METHOD"] != "POST") {
	http_response_code(405);
	echo '{"Message":"Wrong HTTP method"}';
	return;
}

include 'dbConnect.php';
include 'jwt.php';

$data = json_decode(file_get_contents('php://input'), true);
$email = $data['email'];
$password = $data['password'];
$type = $data["type"]; // admin / general
$firebaseToken = $data['firebaseToken'];


$dbTableNameUser = "user";
if ($type == "admin") $dbTableNameUser = "userAdmin";

// get user from datatbase
$result = $db->query("SELECT * FROM $dbTableNameUser WHERE email='$email' AND status=1");
if ($result->num_rows == 0) {
	http_response_code(401);
	//echo mysqli_error($db);
	echo '{"Message":"Incorrect login information"}';
	return;
}

// Create user from database
$user = $result->fetch_assoc();

// Check password
if (!password_verify($password, $user["password"])) {
	http_response_code(401);
	echo '{"Message":"Incorrect login information"}';
	return;
}

// Check verified
if ($type == "admin" && !$user["verified"]) {
	http_response_code(401);
	echo '{"Message":"User not verified, please check you email for verification link"}';
	return;
}

// Remove variables
$user["ID"] = "";
$user["password"] = "";
unset($user["ID"]);
unset($user["password"]);


// // Get all store roles for user
// $userUuid = $user["userUuid"];
// $resultRoles = $db->query("
// 	SELECT storeUuid, role
// 	FROM userAdmin
// 	WHERE userUuid='$userUuid' AND status>0
// ");
// if (!$result) {
// 	http_response_code(500);
// 	echo '{"Message":"Database select store role user error: '.mysqli_error($db).'"}';
// 	return;
// }
// while( $row = $resultRoles->fetch_assoc() ) {
// 	$storeRoleArr[$row["storeUuid"]] = $row["role"];
// }
// // Add storeRoleMap to user
// $user["storeRoleMap"] = $storeRoleArr;


// Create jwt from clientUuid & add as header
$token = createToken($user["userUuid"]);
$refreshToken = $user["refreshToken"];
if ($refreshToken == "") {
	$refreshToken = createRefreshToken($user["userUuid"]);

	// add refreshToken & fb token to db
	$result = $db->query("
			UPDATE $dbTableNameUser
			SET
					refreshToken='$refreshToken',
					firebaseToken='$firebaseToken'
			WHERE email='$email'
		");
} else {
	// Update firebase token
	$result = $db->query("
			UPDATE $dbTableNameUser
			SET firebaseToken='$firebaseToken'
			WHERE email='$email'
		");
}


$user["firebaseToken"] = $firebaseToken;
$user["refreshToken"] = $refreshToken;

header("jwt: " . $token);
header("refresh-token: " . $refreshToken);
//setcookie("token", $token, 20000);
//$user["token"] = $token;
echo json_encode($user);
