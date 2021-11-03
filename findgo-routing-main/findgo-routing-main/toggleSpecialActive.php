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
	$status = $data["status"];
	$activatedAt = $data["activatedAt"];


	// set status in special db
	// 1 == inactive,
	// 9 == active but notification not sent,
	// 2 == active & notifcation sent,
//	$stmt = $db->prepare("
//		UPDATE special
//		SET status=?, activatedAt=?
//		WHERE specialUuid=?
//		LIMIT 1
//	");
//	$stmt->bind_param("iss", $status, $activatedAt, $specialUuid);
//	$stmt->execute();
//	// Check update success
//	//if ($stmt === false) {
//	if ($stmt->affected_rows !== 1) {
//		http_response_code(500);
//		echo '{"Message": "db update special: '. mysqli_error($db).'"}';
//		return;
//	}


	$result = $db->query("
		UPDATE special
		SET status=$status, activatedAt='$activatedAt'
		WHERE specialUuid='$specialUuid'
		LIMIT 1
	");

	// Check update success
	if (!$result) {
		http_response_code(500);
		echo '{"Message": "db update special: '. mysqli_error($db).'"}';
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
