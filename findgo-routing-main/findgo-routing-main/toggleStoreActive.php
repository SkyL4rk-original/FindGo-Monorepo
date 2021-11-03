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
	$storeUuid = $data["storeUuid"];
	$status = $data["status"];


	// set status in store db
	// 1 == active,
	// 2 == inactive,


	$result = $db->query("
		UPDATE store
		SET status=$status
		WHERE storeUuid='$storeUuid'
		LIMIT 1
	");

	// Check update success
	if (!$result) {
		http_response_code(500);
		echo '{"Message": "db update store: '. mysqli_error($db).'"}';
		return;
	}


	// Check if just been activated send out notification
//	if ($status === 1 && $activatedAt != "000-00-00 00:00:00") {
//		$dateTimeActivated = strtotime($activatedAt);
//		$dateTimeNow = time();
//		$diff = round(abs($dateTimeActivated - $dateTimeNow) / 60);
//
//		if ($diff > 60*24) {
//			// Send Message
//		}
//	}

	http_response_code(200);
	echo '{"Message" : "Success"}';
?>
