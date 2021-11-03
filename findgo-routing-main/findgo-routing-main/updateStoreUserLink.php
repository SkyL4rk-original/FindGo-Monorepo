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
	$userUuid = $data["userUuid"];
	$role = $data["role"];


	//UPDATE special
	//SET
		//imageUrl='$imageUrl',
		//name='$name',
		//description='$description',
		//price='$price',
		//validFrom='$validFrom',
		//validUntil='$validUntil',
		//type='$type'
	//WHERE specialUuid='$specialUuid'

	$result = $db->query("
		SELECT ID FROM storeUserRoleLink
		WHERE storeUuid='$storeUuid' AND userUuid='$userUuid'
		LIMIT 1
	");

	if ($result->num_rows == 1) {
		// Try Update Link
		$stmt = $db->prepare("
			UPDATE storeUserRoleLink
			SET role=?
			WHERE storeUuid=? AND userUuid=?
			LIMIT 1
		");
		$stmt->bind_param("iss", $role, $storeUuid, $userUuid);
		$stmt->execute();

		// Check update success
		//if ($stmt === false) {
		if ($stmt->affected_rows !== 1) {
			http_response_code(500);
			echo '{"Message": "db update link: '. mysqli_error($db).'"}';
			return;
		}

	} else {
		// Add New Link
		$stmt = $db->prepare("
			INSERT INTO storeUserRoleLink
			(role, storeUuid, userUuid)
			VALUES(?, ?, ?)
		");
		$stmt->bind_param("iss", $role, $storeUuid, $userUuid);
		$stmt->execute();

		//if ($stmt->affected_rows !== 1) {
		if ($stmt === false) {
			http_response_code(500);
			echo '{"Message": "db insert link: '. mysqli_error($db).'"}';
			return;
		}
	}

	http_response_code(200);
?>
