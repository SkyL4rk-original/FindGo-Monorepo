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

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
include 'dbConnect.php';
include 'jwt.php';

// Check token is valid
$userUuid = verifyToken();
if (!$userUuid) {
	return;
}

$data = json_decode(file_get_contents('php://input'), true);
$storeName = $data["name"];
$categoryId = $data["categoryId"];
$locationId = $data["locationId"];
$description = $data["description"];
$image = $data["image"];
$phoneNumber = $data["phoneNumber"];
$website = $data["website"];


$imageUrl = "";
$lat = $data["lat"] != null ? $data["lat"] : null;
$lng = $data["lng"] != null ? $data["lng"] : null;
$streetAddress = $data["streetAddress"] != null ? $data["streetAddress"] : "";

// TODO Check if user is super-user for creation
//	$result = $db->query("SELECT email FROM user WHERE email = '$email'");
//	if ($result->num_rows > 0) {
//		http_response_code(200);
//		echo '{Message":"Email address already used please select another one"}';
//		return;
//	}


$stmt = $db->prepare("
		INSERT INTO store (storeUuid, name, categoryID, locationID, description, phoneNumber, website, imageUrl, lat, lng, streetAddress, status)
		VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 2)
	");
//VALUES (UUID(), ?, ? ,? , ?, ?, ?)
if ($stmt === false) {
	http_response_code(500);
	echo '{"Message": "Database insert store error ' . mysqli_error($db) . '"}';
	return;
}

$stmt->bind_param("siissssdds", $storeName, $categoryId, $locationId, $description, $phoneNumber, $website, $imageUrl, $lat, $lng, $streetAddress);
$stmt->execute();
$stmt->close();

// Get created store id
$lastId = $db->insert_id;

if ($image != null) {
	// Get created store
	$result = $db->query("
			SELECT
				storeUuid
			FROM store
			WHERE store.ID='$lastId'
		");
	if ($result->num_rows == 0) {
		http_response_code(500);
		echo '{"Message": "Database select error: ' . mysqli_error($db) . '"}';
		return;
	}

	// get store from created / found store
	$store = $result->fetch_assoc();
	$storeUuid = $store["storeUuid"];

	$filename = "store-images/" . $storeUuid . ".png";
	try {
		$realImage = base64_decode($image);
		file_put_contents($filename, $realImage);
	} catch (Exception $e) {
		http_response_code(500);
		echo '{"Message": "image put file: ' . $e->getMessage() . '"}';
		return;
	}
	// $imageUrl = 'https://skylarktraining.co.za/findgo/php/'.$filename;
	$imageUrl = 'https://www.findgo.co.za/php/' . $filename;

	// Update created store imageUrl
	$result = $db->query("
			UPDATE store
			SET imageUrl='$imageUrl'
			WHERE ID='$lastId'
		");
	if (!$result) {
		http_response_code(500);
		echo '{"Message": "Database update imageUrl error: ' . mysqli_error($db) . '"}';
		return;
	}
}

// Get created store
$result = $db->query("
		SELECT
			storeUuid,
			imageUrl
		FROM store
		WHERE store.ID='$lastId'
	");
if ($result->num_rows == 0) {
	http_response_code(500);
	echo '{"Message": "Database select error: ' . mysqli_error($db) . '"}';
	return;
}

// get store from created / found store
$store = $result->fetch_assoc();

// Return json user object
http_response_code(201);
echo  json_encode($store);
