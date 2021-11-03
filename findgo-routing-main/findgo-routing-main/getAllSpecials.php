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
	include 'jwt.php';

	$dateTimeNow = gmdate('Y-m-d H:i:s', time());
	$nullDateTime = "000-00-00 00:00:00";

	// Update all "finished" Specials to inactive / 1
	$result = $db->query("
		UPDATE special SET status=1
		WHERE (status=2 OR status=9) AND validUntil<'$dateTimeNow'
	");
	//if (!$result) {
		//http_response_code(500);
		//echo '{"Message":"Database update special error: '.mysqli_error($db).'"}';
		//return;
	//}


	// Check token is valid
	$userUuid = verifyToken();
	if (!$userUuid) { return; }

	// TODO CHECK USER IS SUPER ADMIN

	// Get all stores
	$result = $db->query("
		SELECT
			specialUuid,
			special.storeUuid,
			store.name AS storeName,
			store.imageUrl AS storeImageUrl,
			c.name AS storeCategory,
			store.phoneNumber AS storePhoneNumber,
			store.website AS storeWebsite,
			special.name,
			special.price,
			special.description,
			special.imageUrl,
			special.validFrom,
			special.validUntil,
			special.activatedAt,
			special.type,
			special.status,
			special.impressions,
			special.clicks,
			special.phoneClicks,
			special.savedClicks,
			special.shareClicks,
			special.websiteClicks
		FROM special
		INNER JOIN store
		ON special.storeUuid = store.storeUuid
		INNER JOIN category AS c
		ON store.categoryID = c.ID
		WHERE store.status=1 AND special.status>0
	");
	if (!$result) {
		http_response_code(500);
		echo '{"Message":"Database select special error: '.mysqli_error($db).'"}';
		return;
	}

	$specialList = Array();
	while( $row = $result->fetch_assoc() ) {
		array_push($specialList, $row);
	}


	// Return json user object
	http_response_code(200);
	echo json_encode($specialList);
?>
