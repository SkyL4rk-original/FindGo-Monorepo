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
} else if ($_SERVER["REQUEST_METHOD"] != "POST") {
	http_response_code(405);
	echo '{"Message":"Wrong HTTP method"}';
	return;
}

include 'dbConnect.php';
include 'jwt.php';

// Check token is valid
$userUuid = verifyToken();
if (!$userUuid) {
	return;
}

$data = json_decode(file_get_contents('php://input'), true);
$storeUuid = $data["storeUuid"];
$imageUrl = $data["imageUrl"];
$image = $data["image"];
$name = $data["name"];
$description = $data["description"];
$categoryId = $data["categoryId"];
$phoneNumber = $data["phoneNumber"];
$website = $data["website"];

$lat = $data["lat"] != null ? $data["lat"] : null;
$lng = $data["lng"] != null ? $data["lng"] : null;
$streetAddress = $data["streetAddress"] != null ? $data["streetAddress"] : "";

if ($image != null) {
	try {
		// Delete old image from server
		if ($imageUrl != "") {
			$urlParams = preg_split("#/#", $imageUrl);
			$oldFilename = $urlParams[count($urlParams) - 2] . "/" . $urlParams[count($urlParams) - 1];
			// Delete file
			if (file_exists($oldFilename)) unlink($oldFilename);
		}

		// Create new filename
		$randomInt = rand(0, 99999);
		$filename = "store-images/" . $storeUuid . "-" . $randomInt . ".png";

		// Add image file to db
		$realImage = base64_decode($image);
		file_put_contents($filename, $realImage);
	} catch (Exception $e) {
		http_response_code(500);
		echo '{"Message": "image put file: ' . $e->getMessage() . '"}';
		return;
	}
	//$imageUrl = 'https://skylarktraining.co.za/specials/php/'.$filename;
	$imageUrl = 'https://findgo.co.za/php/' . $filename;

	// Sanity check image file was created correctly
	if (!file_exists($filename)) {
		http_response_code(500);
		echo '{"Message": "Store image in database error"}';
		return;
	}
}


// set status in store db to FALSE / 0
$stmt = $db->prepare("
		UPDATE store
		SET
			imageUrl=?,
			name=?,
			description=?,
			categoryID=?,
			phoneNumber=?,
			website=?,
			lat=?,
			lng=?,
			streetAddress=?
		WHERE storeUuid=?
		LIMIT 1
	");

$stmt->bind_param("sssissddss", $imageUrl, $name, $description, $categoryId, $phoneNumber, $website, $lat, $lng, $streetAddress, $storeUuid);
$stmt->execute();

// Check update success
//if ($stmt == false) {
if ($stmt->affected_rows !== 1) {
	http_response_code(500);
	echo '{"Message": "db update store: ' . mysqli_error($db) . '"}';
	return;
}

http_response_code(200);
echo '{"imageUrl" : "' . $imageUrl . '"}';
