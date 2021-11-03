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

	// Get all categories
	$result = $db->query("
		SELECT *
		FROM category
	");
	if ($result->num_rows == 0) {
		http_response_code(500);
		echo '{"Message":"Database select store error: '.mysqli_error($db).'"}';
		return;
	}

	$categoryList = Array();
	while( $row = $result->fetch_assoc() ) {
		array_push($categoryList, $row);
	}

	// Return json user object
	http_response_code(200);
	echo json_encode($categoryList);
?>
