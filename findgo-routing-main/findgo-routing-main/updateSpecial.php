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
	$imageUrl = $data["imageUrl"];
	$image = $data["image"];
	$name = $data["name"];
	$description = $data["description"];
	$price = $data["price"];
	$validFrom = $data["validFrom"];
	$validUntil = $data["validUntil"];
	$activatedAt = $data["activatedAt"];
	$type = $data["type"];

	if ($image != null) {
		try {
			// Delete old image from server
			if ($imageUrl != "") {
				$urlParams = preg_split("#/#", $imageUrl);
				$filename = $urlParams[4]."/".$urlParams[5];
				// Delete file
				if (file_exists($filename)) unlink($filename);
			}

			$randomInt = random_int(100000, 999999);
			$filename = "images/".$specialUuid."-".$randomInt.".png";
			$realImage = base64_decode($image);
			file_put_contents($filename, $realImage);
		} catch (Exception $e) {
			http_response_code(500);
			echo '{"Message": "image put file: '.$e->getMessage().'"}';
			return;
		}
		//$imageUrl = 'https://skylarktraining.co.za/specials/php/'.$filename;
		$imageUrl = 'https://findgo.co.za/php/'.$filename;
	}

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

	// Update special in db
	$stmt = $db->prepare("
		UPDATE special
		SET
			imageUrl=?,
			name=?,
			description=?,
			price=?,
			validFrom=?,
			validUntil=?,
			activatedAt=?,
			type=?
		WHERE specialUuid=?
		LIMIT 1
	");

	$stmt->bind_param("sssisssss", $imageUrl, $name, $description, $price,
	 	$validFrom, $validUntil, $activatedAt, $type, $specialUuid);
	$stmt->execute();

	// Check update success
	//if ($stmt === false) {
	if ($stmt->affected_rows !== 1) {
		http_response_code(500);
		echo '{"Message": "db update special: '. mysqli_error($db).'"}';
		return;
	}

	http_response_code(200);
	echo '{"imageUrl" : "'.$imageUrl.'"}';
?>
