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
	//$imageUrl = 'https://skylarktraining.co.za/findgo/php/' . $filename;
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

// Check if user is not Super Admin
$result = $db->query("
			SELECT role
			FROM userAdmin
			WHERE userUuid='$userUuid' AND status>0
			LIMIT 1
		");
if ($result->num_rows == 1) {
	$user = $result->fetch_assoc();
	if ($user["role"] != "superAdmin") {
		// Add user store link
		$storeUuid = $store["storeUuid"];
		$result = $db->query("
			INSERT INTO storeUserLink (storeUuid, userUuid)
			VALUES ('$storeUuid', '$userUuid')
		");
	}
}

// Return json user object
http_response_code(201);
echo  json_encode($store);


// Fetch user info for email
$result = $db->query("
		SELECT email
		FROM userAdmin
		WHERE userUuid='$userUuid'
		LIMIT 1
	");
if ($result->num_rows != 1) return;
$user = $result->fetch_assoc();
$email = $user["email"];
$dateTimeNow = gmdate('Y-m-d H:i:s', time());

//SEND EMAIL
$htmlContent = '
		<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
	<head>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta name="x-apple-disable-message-reformatting">
			<title>FindGo-New Restaurant</title>


			<style>
			</style>

	</head>

	<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly;">
		<center style="width: 100%;">
				<h3>New Restaurant Created.</h3>
				<p>Name:	' . $storeName . '<p>
				<p>By:	' . $email . '<p>
				<p>date(gmt): ' . $dateTimeNow . '</p>
		</center>
	</body>
</html>
';


// Send Register Email
// $to = 'davidtgericke@gmail.com';
$to = 'support@findgo.co.za';
$from = 'support@findgo.co.za';

$fromName = 'FindGo Support';
$subject = "FindGo New Restaurant";

// Set content-type header for sending HTML email
$headers = "MIME-Version: 1.0" . "\r\n";
$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";

// Additional headers
$headers .= 'From: ' . $fromName . '<' . $from . '>' . "\r\n";
//$headers .= 'Cc: '. $from . "\r\n";
$headers .= 'Bcc: mike@skylarkdigital.co.za' . "\r\n";

// Send email
if (mail($to, $subject, $htmlContent, $headers)) {
	// echo 'Email has sent successfully.';
	//			echo '{"error":"false","Message":"Thank you, your gift has been emailed" }';
} else {
	// echo 'Email sending failed.';
	//		 echo '{"error":"true","Message":"Thank you, user was sent, but an error occured. Please look out for your email. '. mysqli_error($db).' }';
}
