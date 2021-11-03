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

	// TODO Check user auth ability

	$data = json_decode(file_get_contents('php://input'), true);
	$storeUuid = $data["storeUuid"];
	$imageUrl = $data["imageUrl"];

	// Delete image from server
	if ($imageUrl != "") {
		try {
				$urlParams = preg_split("#/#", $imageUrl);
				$filename = $urlParams[4]."/".$urlParams[5];
				// Delete file
				if (file_exists($filename)) unlink($filename);
		} catch (Exception $e) {
			http_response_code(500);
			echo '{"Message": "image delete file: '.$e->getMessage().'"}';
			return;
		}
	}


	// Get time now in UTC
	$timestamp = gmdate('Y-m-d H:i:s', time());
	//$timestamp = date("Y-m-d H:i:s");

	// set status in store db to FALSE / 0
	$result = $db->query("
		UPDATE store
		SET
			status=0,
			imageUrl='',
			dateDeleted='$timestamp'
		WHERE storeUuid='$storeUuid'
		LIMIT 1
	");

	// Check delete success
	if (!$result) {
		http_response_code(500);
		echo '{"Message": "db delete store: '. mysqli_error($db).'"}';
		return;
	}

	http_response_code(204);
	echo json_encode("delete store success");
?>
