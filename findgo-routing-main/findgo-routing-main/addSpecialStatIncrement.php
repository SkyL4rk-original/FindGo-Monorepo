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
	} else if($_SERVER["REQUEST_METHOD"] != "POST") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	include 'dbConnect.php';
	include 'jwt.php';

	// Check token is valid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	$data = json_decode(file_get_contents('php://input'), true);
	$specialUuid = $data["specialUuid"];
	$type = $data["type"];

	// Increment special clicks by 1 in db
	$stmt = $db->prepare("
		UPDATE special
		SET $type=$type + 1
		WHERE specialUuid=?
		LIMIT 1
	");

	$stmt->bind_param("s", $specialUuid);
	$stmt->execute();

	// Check update success
	//if ($stmt === false) {
	if ($stmt->affected_rows !== 1) {
		http_response_code(500);
		echo '{"Message": "db update special increment stat: '.$type.' '. mysqli_error($db).'"}';
		return;
	}

	http_response_code(200);
?>
