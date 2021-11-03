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

	// Check if already stored
	$stmt = $db->prepare("SELECT userUuid FROM userFollowing WHERE userUuid=? AND storeUuid=?");
	$stmt->bind_param("ss",$userUuid, $storeUuid);
	$stmt->execute();
	$stmt->store_result();
	$foundExisting = $stmt->num_rows() > 0;
	$stmt->close();

	if ($foundExisting) {
		$stmt = $db->prepare("
			UPDATE userFollowing SET status=?
			WHERE userUuid=? AND storeUuid=?
		");
	} else {
			$stmt = $db->prepare("
			INSERT INTO userFollowing (status, userUuid, storeUuid)
			VALUES (?, ?, ?)
		");

	}

	$stmt->bind_param("iss",$status, $userUuid, $storeUuid);
	$stmt->execute();
	$stmt->close();

	// Return json user object
	http_response_code(201);
	echo '{"Message": "Updated Follow"}';
?>
