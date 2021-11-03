<?php
	/*
		set vars to send fireabase
		this gets triggered after the saving of the intention
		user will get firebase to log in and download message from server
		or test firebase 'other settings in the data tag'
	*/

	header("Access-Control-Allow-Origin: *");
	include 'dbConnect.php';


	//$data = json_decode(file_get_contents('php://input'), true);
	//$firebaseToken = $data['firebaseToken'];
	//$specialUuid = $data["specialUuid"];
	//cw4E6WJWKlo:APA91bHhk8FKSdnw83Kd2nxed6Zydm-c8u1lR3owZrjwRimLdvGG_ZRlp8fuvTY7e19w1zxfzO7BuQ3z2ioDUeY4CDP9d2SSzWCBF2vHYSxGiUfsY5EkEia9Eubo5EtV6O60vgfvKgiX

	$dateTimeNow = gmdate('Y-m-d H:i:s', time());
	$nullDateTime = "000-00-00 00:00:00";

	// Get all stores where status = active-but-notify-not-sent
	$result = $db->query("
		SELECT specialUuid, type, validFrom FROM special
		WHERE status=9 AND validUntil>'$dateTimeNow'
	");
	if (!$result) {
		http_response_code(500);
		echo '{"Message":"Database select special error: '.mysqli_error($db).'"}';
		return;
	}

	// Create array from specials
	$specialList = Array();
	while( $special = $result->fetch_assoc() ) {
		array_push($specialList, $special);
	}
	//echo "number of specials found: ".count($specialList)."\r\n";

	// Remove All Featured Specials not today
	$filteredSpecialList = Array();
	$gmDate = gmdate('Y-m-d', time());
	foreach ($specialList as $special) {
		if ($special["type"] != "3") { array_push($filteredSpecialList, $special); }
		else {
			// If is feature special then make sure date from is today
			$featureDay = date('Y-m-d', strtotime($special["validFrom"]));
			//echo $featureDay." == ".$gmDate."\r\n";
			if($featureDay == $gmDate) array_push($filteredSpecialList, $special);
		}
	}

	// Check number Specials > 0
	$numberOfNewSpecials = count($filteredSpecialList);
	if ($numberOfNewSpecials < 1) {
		echo "No filterd specials found";
		return;
	}

	// Get all firebase tokens from user to send notification to
	$result = $db->query("
		SELECT firebaseToken, email FROM user
		WHERE status=1 AND CHAR_LENGTH(firebaseToken)>10
		GROUP BY(firebaseToken)
		ORDER BY email
	");
	if (!$result) {
		http_response_code(500);
		echo '{"Message":"Database select user error: '.mysqli_error($db).'"}';
		return;
	}

	// Create array from firebase tokens
	$blackList = Array("user@apple.com", "user@android.com", "wellness@marilynbeuster.online");
	$firebaseTokenList = Array();
	while( $firebaseTokenItem = $result->fetch_assoc() ) {
		$email = $firebaseTokenItem["email"];
		if (!in_array($email, $blackList)) array_push($firebaseTokenList, $firebaseTokenItem);
	}

	// Check number of tokens > 0
	//if (count($firebaseTokenList) < 1) {
		//echo "No firebase tokens found";
		//return;
	//}

	// Set all non featured specials to status 2 == active and notifiaction sent
	$result = $db->query("
		UPDATE special SET status=2
		WHERE status=9 AND type!=3
	");
	if (!$result) {
		http_response_code(500);
		// echo '{"Message":"Database update special error: '.mysqli_error($db).'"}';
		return;
	}

	// Set only featured specials for today status 2 == active and notification sent
	foreach ($filteredSpecialList as $special) {
		if ($special["type"] == "3") {
			$specialUuid = $special["specialUuid"];
			//echo "Updating featured special: ".$specialUuid."\r\n";

			$result = $db->query("
				UPDATE special SET status=2
				WHERE specialUuid='$specialUuid'
			");
			if (!$result) {
				http_response_code(500);
				echo '{"Message":"Database update special error: '.mysqli_error($db).'"}';
				return;
			}
		}
	}


	$title =  "FindGo";
	$body =   "New Specials Posted";
	if ($numberOfNewSpecials === 1) $body = "1 New special added today!";
	else $body = $numberOfNewSpecials." New specials added today!";

	$authKey = "AAAAtL01hrQ:APA91bFI9r2aNZFTz1qhZl1DMmTDndgPEJsRemdQlQXg6bh6FVOdZwkdP7g_Iz37NNJ9fp_4YlMyj6y5ga8g_CTJrqZLqXSSq8a6QST7HawbO_1eFD1NNSCXgf01nMXTTW-XR7lW-jvY";

	// Send message to each token
	foreach ($firebaseTokenList as $firebaseTokenItem) {
		$firebaseToken = $firebaseTokenItem["firebaseToken"];
		$email = $firebaseTokenItem["email"];
		echo "Sending to: ".$email."\r\n".$firebaseToken."\r\n";

		$curl = curl_init();
		curl_setopt_array($curl, array(
			CURLOPT_URL => "https://fcm.googleapis.com/fcm/send",
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_ENCODING => "",
			CURLOPT_MAXREDIRS => 10,
			CURLOPT_TIMEOUT => 0,
			CURLOPT_FOLLOWLOCATION => true,
			CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
			CURLOPT_CUSTOMREQUEST => "POST",
			CURLOPT_POSTFIELDS =>"{\r\n    \"to\": \"$firebaseToken\",\r\n    \"notification\": {\r\n        \"title\": \"$title\",\r\n        \"body\": \"$body\",\r\n        \"sound\": \"default\"\r\n    },\r\n    \"priority\": \"high\",\r\n    \"data\": { \"specialUuid\": \"$specialUuid\", \"msgIitle\": \"$title\", \"msgBody\": \"$body\"} \r\n}",

			CURLOPT_HTTPHEADER => array(
				"Authorization: key=".$authKey,
				"Content-Type: application/json"
			),
		));

		$response = curl_exec($curl);
		curl_close($curl);
		echo $response."\r\n\r\n";
	}

	//print_r($firebaseTokenList);
	echo "Message ".$body."\r\n";
	echo "Firebase message job complete";
?>
