<?php
	header("Access-Control-Allow-Origin: *");
	include 'dbConnect.php';
	/*
		set vars to send fireabase
		this gets triggered after the saving of the intention
		user will get firebase to log in and download message from server
		or test firebase 'other settings in the data tag'
	*/


	$data = json_decode(file_get_contents('php://input'), true);
	$firebaseToken = $data['firebaseToken'];
	$specialMessage = $data["message"];
	$specialUuid = "null";

	//cw4E6WJWKlo:APA91bHhk8FKSdnw83Kd2nxed6Zydm-c8u1lR3owZrjwRimLdvGG_ZRlp8fuvTY7e19w1zxfzO7BuQ3z2ioDUeY4CDP9d2SSzWCBF2vHYSxGiUfsY5EkEia9Eubo5EtV6O60vgfvKgiX


	$title =  "FindGo Direct Message";
	$body =   $specialMessage;

	$authKey = "AAAAtL01hrQ:APA91bFI9r2aNZFTz1qhZl1DMmTDndgPEJsRemdQlQXg6bh6FVOdZwkdP7g_Iz37NNJ9fp_4YlMyj6y5ga8g_CTJrqZLqXSSq8a6QST7HawbO_1eFD1NNSCXgf01nMXTTW-XR7lW-jvY";

	// Send message to each token
	// foreach ($firebaseTokenList as $firebaseToken) {
		echo "Sending to: ".$firebaseToken."\r\n";

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

		echo $response;

	// }

	// echo "Success";
?>
