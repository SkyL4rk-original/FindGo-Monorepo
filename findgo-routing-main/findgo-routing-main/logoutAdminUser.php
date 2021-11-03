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

	$email = $data['email'];
	$refreshToken = $data['refreshToken'];

	// Delete refreshToken from accessTokens
	$result = $db->query("
		UPDATE userAdmin
		SET refreshToken=''
		WHERE email='$email'
	");
	if (!$result) {
		http_response_code(401);
		//echo mysqli_error($db);
		echo '{"Message":"No Token Found"}';
		return;
	}

	http_response_code(200);
	echo '{"Message":"Logout Success"}';
?>
