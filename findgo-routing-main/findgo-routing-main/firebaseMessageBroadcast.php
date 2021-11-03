<?php
	/*
		set vars to send fireabase
		this gets triggered after the saving of the intention
		user will get firebase to log in and download message from server
		or test firebase 'other settings in the data tag'
	*/

	header("Access-Control-Allow-Origin: *");
	include 'dbConnect.php';

	$data = json_decode(file_get_contents('php://input'), true);
	$message = $data['message'];


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
	$blackList = Array("user@apple.com", "user@android.com", "user@huawei.com", "wellness@marilynbeuster.online");
	$firebaseTokenList = Array();
	while( $firebaseTokenItem = $result->fetch_assoc() ) {
		$email = $firebaseTokenItem["email"];
		if (!in_array($email, $blackList)) array_push($firebaseTokenList, $firebaseTokenItem);
	}


	$title =  "FindGo";
	$body = $message;

	$authKey = "AAAAtL01hrQ:APA91bFI9r2aNZFTz1qhZl1DMmTDndgPEJsRemdQlQXg6bh6FVOdZwkdP7g_Iz37NNJ9fp_4YlMyj6y5ga8g_CTJrqZLqXSSq8a6QST7HawbO_1eFD1NNSCXgf01nMXTTW-XR7lW-jvY";

	// Send message to each token
	foreach ($firebaseTokenList as $firebaseTokenItem) {
		$firebaseToken = $firebaseTokenItem["firebaseToken"];
		//$email = $firebaseTokenItem["email"];
		//echo "Sending to: ".$email."\r\n".$firebaseToken."\r\n";

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
		// echo $response."\r\n\r\n";
	}

	//print_r($firebaseTokenList);
// 	echo "Message ".$body."\r\n";
// 	echo "Firebase message job complete";
?>
