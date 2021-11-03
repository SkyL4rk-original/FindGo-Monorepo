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

	// Check token is valid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	// Get all store uuids
	$result = $db->query("
		SELECT storeUuid FROM userNotify
		WHERE userUuid='$userUuid' AND status=1
	");
	if (!$result) {
		http_response_code(500);
		echo '{"Message":"Database select special error: '.mysqli_error($db).'"}';
		return;
	}

	$storeUuidList = Array();
	while( $row = $result->fetch_assoc() ) {
		$storeUuid = $row["storeUuid"];
		array_push($storeUuidList, $storeUuid);
	}

	// Return json user object
	http_response_code(200);
	echo json_encode($storeUuidList);
?>
