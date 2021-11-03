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

	$storeUuid = $_GET['store'];
	if (!$storeUuid) {
		http_response_code(500);
		echo '{"Message":"No store selected"}';
		return;
	}

	// Check token is vaid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	// get user from datatbase
	$result = $db->query("
		SELECT
			srl.userUuid,
			srl.role,
			email,
			firstName,
			lastName
		FROM storeUserRoleLink AS srl
		INNER JOIN user
		ON srl.userUuid = user.userUuid
		WHERE storeUuid='$storeUuid' AND user.status=1 AND srl.role > 0
	");
	if (!$result) {
		http_response_code(500);
		//echo mysqli_error($db);
		echo '{"Message":"Database select users error: '.mysqli_error($db).'"}';
		return;
	}

	// Create users list from rows
	$usersList = Array();
	while( $row = $result->fetch_assoc() ) {
		array_push($usersList, $row);
	}

	http_response_code(200);
	echo json_encode($usersList);
?>
