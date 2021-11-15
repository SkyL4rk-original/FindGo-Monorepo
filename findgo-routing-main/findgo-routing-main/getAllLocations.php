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
//	include 'jwt.php';

	// Check token is valid
//	$userUuid = verifyToken();
//	if (!$userUuid) { return; }

	// TODO CHECK USER IS SUPER ADMIN

	// Get all stores
	$result = $db->query("
		SELECT
			*
		FROM location
		WHERE status>0
	");
	if ($result->num_rows == 0) {
		http_response_code(500);
		echo '{"Message":"Database select location error: '.mysqli_error($db).'"}';
		return;
	}

	$locationList = Array();
	while( $row = $result->fetch_assoc() ) {
		array_push($locationList, $row);
	}

	// Return json user object
	http_response_code(200);
	echo json_encode($locationList);
?>
