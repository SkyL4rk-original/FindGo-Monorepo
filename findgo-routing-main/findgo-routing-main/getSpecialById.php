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
	} else if($_SERVER["REQUEST_METHOD"] != "GET") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	include 'dbConnect.php';
	$specialUuid = $_GET['uuid'];

	//echo $specialUuid;

	$dateTimeNow = gmdate('Y-m-d H:i:s', time());
	$nullDateTime = "000-00-00 00:00:00";

	// Get all stores
	$result = $db->query("
		SELECT
			specialUuid,
			special.storeUuid,
			store.name AS storeName,
			store.imageUrl AS storeImageUrl,
			store.phoneNumber AS storePhoneNumber,
			store.website AS storeWebsite,
			c.name AS storeCategory,
			special.name,
			special.price,
			special.description,
			special.imageUrl,
			special.validFrom,
			special.validUntil,
			special.activatedAt,
			special.type,
			special.status
		FROM special
		INNER JOIN store
		ON special.storeUuid = store.storeUuid
		INNER JOIN category AS c
		ON store.categoryID = c.ID
		WHERE
			store.status=1 AND (special.status=2 OR special.status=9)
			AND validUntil>'$dateTimeNow'
			AND specialUuid='$specialUuid'
		LIMIT 1
	");
		//WHERE store.status=1 AND (special.status=2 OR special.status=9)
		//	AND validUntil>'$dateTimeNow')
		//	AND specialUuid='$specialUuid'
	echo $result->num_rows == 0;
	if (!$result || $result->num_rows == 0) {
		http_response_code(500);
		echo '{"Message":"Database select special error: '.mysqli_error($db).'"}';
		return;
	}

	$special = $result->fetch_assoc();
	// Return json user object
	http_response_code(200);
	echo json_encode($special);
?>
