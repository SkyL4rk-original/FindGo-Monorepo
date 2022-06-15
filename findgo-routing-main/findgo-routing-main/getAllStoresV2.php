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
} else if ($_SERVER["REQUEST_METHOD"] != "GET") {
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

// Check if user is Super Admin
$result = $db->query("
		SELECT role
		FROM userAdmin
		WHERE userUuid='$userUuid' AND status>0
		LIMIT 1
	");
if ($result->num_rows == 0) {
	http_response_code(500);
	echo '{"Message":"Database select store error: ' . mysqli_error($db) . '"}';
	return;
}
$user = $result->fetch_assoc();
$storeList = array();
if ($user["role"] == "superAdmin") {
	// Get all stores
	$sResult = $db->query("
			SELECT
				storeUuid,
				store.name,
				store.description,
				store.categoryID AS categoryId,
				store.phoneNumber,
				store.website,
				store.status,
				store.lat,
				store.lng,
				store.streetAddress,
				c.name AS category,
				location.name AS location,
				location.id AS locationId,
				imageUrl
			FROM store
			INNER JOIN category AS c
			ON store.categoryID = c.ID
			LEFT JOIN location
			ON store.locationID = location.id
			WHERE store.status>0
		");
	while ($row = $sResult->fetch_assoc()) {
		array_push($storeList, $row);
	}
} else {
	// Get all user stores
	$sResult = $db->query("
			SELECT
				store.storeUuid,
				store.name,
				store.description,
				store.categoryID AS categoryId,
				store.phoneNumber,
				store.website,
				store.status,
				store.lat,
				store.lng,
				store.streetAddress,
				c.name AS category,
				location.name AS location,
				location.id AS locationId,
				imageUrl
			FROM storeUserLink sul
			INNER JOIN store
			ON store.storeUuid = sul.storeUuid
			INNER JOIN category AS c
			ON store.categoryID = c.ID
			LEFT JOIN location
			ON store.locationID = location.id
			WHERE sul.userUuid='$userUuid' AND store.status>0
		");
	while ($row = $sResult->fetch_assoc()) {
		array_push($storeList, $row);
	}
}



// Return json user object
http_response_code(200);
echo json_encode($storeList);
