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
	$name = $data["name"];
	$price = $data["price"];
	$validFrom = $data["validFrom"];
	$validUntil = $data["validUntil"];
	$description = $data["description"];
	$image = $data["image"];
	$imageUrl = $data["imageUrl"];
	$video = $data["video"];
	$videoUrl = $data["videoUrl"];
	$type = $data["type"];
	$status = $data["status"];
	$activatedAt = $data["activatedAt"];

	$imgUrl = "";
	$impressions = 0;
	$clicks = 0;
	$websiteClicks = 0;
//    "specialUuid": uuid,
//    "storeUuid": storeUuid,
//    "name": name,
//    "price": price,
//    "validFrom": validFrom.toIso8601String(),
//    "validUntil": validUntil?.toIso8601String(),
//    "description": description,
//    "imageUrl": imageUrl,
//    "image": image != null ? base64Encode(image!) : null,
//    "videoUrl": videoUrl,
//    "video": video != null ? base64Encode(video!) : null,
//    "type": _typeToInt(type),
//    "status": _statusToInt(status),

	// TODO Check if user is super-user for creation

	// Insert special into database
	//$result = $db->query("
		//INSERT INTO special (
			//specialUuid,
			//storeUuid,
			//name,
			//price,
			//validFrom,
			//validUntil,
			//description,
			//type,
			//status
		//)
		//VALUES (
			//UUID(),
			//'$storeUuid',
			//'$name',
			//'$price',
			//'$validFrom',
			//'$validUntil',
			//'$description',
			//'$type',
			//'$status'
		//)
	//");
	//if(!$result) {
		//http_response_code(500);
		//echo '{"Message": Database insert special error '.mysqli_error($db).'"}';
		//return;
	//}

	$activatedAt = "0000-00-00 00:00:00";
	// Insert special into database
	$stmt = $db->prepare("
		INSERT INTO special (
			specialUuid,
			storeUuid,
			name,
			price,
			validFrom,
			validUntil,
			activatedAt,
			description,
			imageUrl,
			type,
			status,
			impressions,
			clicks,
			websiteClicks
		)
		VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	");
	$stmt->bind_param("ssissssssiiii",
		$storeUuid,
		$name,
		$price,
		$validFrom,
		$validUntil,
		$activatedAt,
		$description,
		$imgUrl,
		$type,
		$status,
		$impressions,
		$clicks,
		$websiteClicks
	);
	$stmt->execute();
	if($stmt === false) {
		http_response_code(500);
		echo '{"Message": Database insert special error '.mysqli_error($db).'"}';
		return;
	}
	$stmt->close();


	// Get created special id
	$lastId = $db->insert_id;

	// Add image
	if ($imageUrl != "" || $image != null) {
		// Get created special
		$result = $db->query("
			SELECT specialUuid
			FROM special
			WHERE ID='$lastId'
		");
		if ($result->num_rows == 0) {
			http_response_code(500);
			echo '{"Message":"Database select Id error: '.mysqli_error($db).'"}';
			return;
		}

		// get special from created / found special
		$special = $result->fetch_assoc();
		$specialUuid = $special["specialUuid"];
		$filename = "images/".$specialUuid.".png";

		// Check if copy added
		if ($imageUrl != "") {
			try {
				// Get path to original file
				$urlParams = preg_split("#/#", $imageUrl);
				$oldFilename = $urlParams[4]."/".$urlParams[5];

				// Copy image file to db
				if (file_exists($oldFilename)) {
					copy($oldFilename, $filename);
					// Check copy worked
				} else {
					// Remove special from db
					$db->query("DELETE FROM special WHERE ID='$lastId'");
					http_response_code(490);
					echo '{"Message": "Image duplicate error"}';
					return;
				}

			} catch (Exception $e) {
				// Remove special from db
				$db->query("DELETE FROM special WHERE ID='$lastId'");
				http_response_code(500);
				echo '{"Message": "image copy file: '.$e->getMessage().'"}';
				return;
			}
		} else { // $image != null
			try {
				// Add image file to db
				$realImage = base64_decode($image);
				file_put_contents($filename, $realImage);
			} catch (Exception $e) {
				// Remove special from db
				$db->query("DELETE FROM special WHERE ID='$lastId'");
				http_response_code(500);
				echo '{"Message": "image put file: '.$e->getMessage().'"}';
				return;
			}
		}

		// Check file was copied correctly
		if (!file_exists($filename)) {
				// Remove special from db
				$db->query("DELETE FROM special WHERE ID='$lastId'");

				http_response_code(490);
				echo '{"Message": "Store image in database error"}';
				return;
		}

		//$imageUrl = 'https://skylarktraining.co.za/specials/php/'.$filename;
		$imageUrl = 'https://findgo.co.za/php/'.$filename;

		// Update created special imageUrl
		$result = $db->query("
			UPDATE special
			SET imageUrl='$imageUrl'
			WHERE ID='$lastId'
		");
		if (!$result) {
			http_response_code(500);
			echo '{"Message":"Database add imageUrl error: '.mysqli_error($db).'"}';
			return;
		}

	}



	// Get created special
	$result = $db->query("
		SELECT
			specialUuid,
			imageUrl
		FROM special
		WHERE ID='$lastId'
	");
	if ($result->num_rows == 0) {
		http_response_code(500);
		echo '{"Message":"Database select uuid & imageUrl error: '.mysqli_error($db).'"}';
		return;
	}

	// get special from created / found special
	$special = $result->fetch_assoc();

	// Return json user object
	http_response_code(201);
	echo  json_encode($special);
?>
