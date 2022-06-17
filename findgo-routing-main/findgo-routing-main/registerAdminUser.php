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

$data = json_decode(file_get_contents('php://input'), true);

$email = $data['email'];
$password = $data['password'];
$storeUuid = $data['storeUuid'];
$firstName = $data['firstName'];
$lastName = $data['lastName'];
$firebaseToken = $data['firebaseToken'];
// superAdmin, storeAdmin
$role = $data['role'];

$refreshToken = "";
$false = 0;

// Check if user already created
$userHasDeletedAccount = false;
$result = $db->query("SELECT email, status FROM userAdmin WHERE email='$email' LIMIT 1");
if ($result->num_rows > 0) {

	$user = $result->fetch_assoc();
	if ($user["status"] == "1") {
		http_response_code(200);
		echo '{Message":"Email address already used please select another one"}';
		return;
	} else {
		$userHasDeletedAccount = true;
	}
}

// Get time now in UTC
$dateTimeNow = gmdate('Y-m-d H:i:s', time());
// Hash password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Check if update "deleted" account or create new
if ($userHasDeletedAccount) {
	// Update old account
	$stmt = $db->prepare("
				UPDATE userAdmin
				SET
					password=?,
					firstName=?,
				  lastName=?,
					storeUuid=?,
				  role=?,
				  firebaseToken=?,
					refreshToken=?,
				  createdAt=?,
					updatedAt=?,
					status=?,
					verified=?
				WHERE email='$email' LIMIT 1
			");
	if ($stmt === false) {
		http_response_code(500);
		echo '{"Message": "Database prepare insert admin error ' . mysqli_error($db) . '"}';
		return;
	}
	$st = $stmt->bind_param(
		"sssssssssss",
		$hashedPassword,
		$firstName,
		$lastName,
		$storeUuid,
		$role,
		$firebaseToken,
		$refreshToken,
		$dateTimeNow,
		$dateTimeNow,
		$false,
		$false
	);
	if ($st === false) {
		http_response_code(500);
		echo '{"Message": "Database bind update admin error ' . htmlspecialchars($stmt->error) . '"}';
		return;
	}
	$st = $stmt->execute();
	if ($st === false) {
		http_response_code(500);
		echo '{"Message": "Database execute update admin error ' . htmlspecialchars($stmt->error) . '"}';
		return;
	}
	$stmt->close();
} else {
	// Insert userAdmin into database
	$stmt = $db->prepare("
				INSERT INTO userAdmin (userUuid, email, password, firstName, lastName, storeUuid, role, firebaseToken, refreshToken, createdAt, updatedAt, verified)
				VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
			");
	if ($stmt === false) {
		http_response_code(500);
		echo '{"Message": "Database prepare insert admin error ' . mysqli_error($db) . '"}';
		return;
	}

	$st = $stmt->bind_param(
		"sssssssssss",
		$email,
		$hashedPassword,
		$firstName,
		$lastName,
		$storeUuid,
		$role,
		$firebaseToken,
		$refreshToken,
		$dateTimeNow,
		$dateTimeNow,
		$false
	);
	if ($st === false) {
		http_response_code(500);
		echo '{"Message": "Database bind insert admin error ' . htmlspecialchars($stmt->error) . '"}';
		return;
	}
	$st = $stmt->execute();
	if ($st === false) {
		http_response_code(500);
		echo '{"Message": "Database execute insert admin error ' . htmlspecialchars($stmt->error) . '"}';
		return;
	}

	$stmt->close();
}

// Get created user
$result = $db->query("SELECT * FROM userAdmin WHERE `email` = '$email'");
if ($result->num_rows == 0) {
	http_response_code(500);
	echo '"Message":"Database select error: ' . mysqli_error($db) . '"}';
	return;
}

// get user from created / found user
$user = $result->fetch_assoc();
$userUuid = $user["userUuid"];

// Add verification code
$resultV = $db->query("
	INSERT INTO userVerifyLink (userUuid, code, createdAt)
	VALUES ('$userUuid', UUID(), '$dateTimeNow')
");
if (!$resultV) {
	http_response_code(500);
	echo '{"Message": "Database insert admin verification error ' . mysqli_error($db) . '"}';
	return;
}

// Get verification code
$resultV = $db->query("SELECT code FROM userVerifyLink WHERE userUuid='$userUuid' LIMIT 1");
if ($resultV->num_rows == 0) {
	http_response_code(500);
	echo '"Message":"Database select code error: ' . mysqli_error($db) . '"}';
	return;
}

$verification =  $resultV->fetch_assoc();
$code = $verification["code"];


// Remove ID & password
$user["ID"] = "";
$user["password"] = "";
$user["refreshToken"] = "";
unset($user["ID"]);
unset($user["password"]);
unset($user["refreshToken"]);

http_response_code(201);
echo json_encode($user);

//SEND EMAIL
$htmlContent = '
		<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
	<head>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta name="x-apple-disable-message-reformatting">
			<title>FindGo</title>

			<link href="https://fonts.googleapis.com/css?family=Nunito+Sans:200,300,400,600,700" rel="stylesheet">

			<style>
			</style>

	</head>

	<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #222222; font-family:Nunito Sans;">
		<center style="width: 100%; background-color: #f1f1f1;">

			<div style="max-width: 600px; margin: 0 auto;" class="email-container">
				<table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin: auto;">
					<tr>
						<td style="padding: 1em 2.5em;">
							<table role="presentation" border="0" cellpadding="1" cellspacing="0" width="100%">
								<tr>
									<td width="40%" style="text-align: center;">
										<h2 ><a style="color:black; text-decoration:none" href="#">Find.Go.Enjoy</a></h2>
									</td>
									<td width="60%" style="text-align: right;">
										<ul >
											<li style="display:inline;float:right;"><a href="https://apps.apple.com/us/app/findgo/id1574321570">
													<img alt="app store button" src="https://www.findgo.co.za/admin/assets/images/apple_store.png" height="30">
											</a></li>
											<li style="display:inline;float:right;"><a href="https://play.google.com/store/apps/details?id=app.specials.findgo">
													<img alt="play store button" src="https://www.findgo.co.za/admin/assets/images/google_store.png" height="30">
											</a></li>
											<li style="display:inline;float:right;"><a href="https://appgallery.huawei.com/#/app/C104564149">
													<img alt="huawei store button" src="https://www.findgo.co.za/admin/assets/images/huawei_store.png" height="30">
											</a></li>
										</ul>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td valign="middle" class="hero bg_white">
							<table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
								<tr>
									<td valign="middle" width="50%">
										<table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
											<tr>
												<td>
													<img alt="findgo logo" src="https://findgo.co.za/images/icon.png" alt="" style="width: 100%; max-width: 600px; height: auto; margin: auto; display: block;">
												</td>
											</tr>
										</table>
									</td>
									<td valign="middle" width="50%" class="primary">
										<table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
											<tr>
												<td class="text" style="text-align: center; padding: 20px 30px;">
													<h2 style="color: black;">Welcome to FindGo Admin</h2>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td >
							<table role="presentation" cellspacing="0" cellpadding="20" border="0" width="100%">
								<tr>
									<td>
										<div style="text-align: center; padding: 0 30px;">
											<p>Please click the button below to verify your admin account.</p>
												<br>
											<!-- <button onclick= class="button"> -->
												<a style="background:black;color:white;padding:20px;font-size:40px;text-decoration:none;" href="https://findgo.co.za/admin/#/verify/' . $code . '">
														Verify Me
												</a>
									</td>
								</tr>
								<tr>
									<td valign="middle" class="counter">
										<table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
											<tr>
												<td valign="middle" style="padding: 3em 0; background-color: black;">

													<p style="color: white; text-align: center;">You got this email as intended by the sender,<br>and is not part of a mailing list.</p>

												</td>
											</tr>
										</table>
									</td>
							</tr>
				</table>
			</div>
		</center>
	</body>
</html>	';


// Send Register Email
$to = $email;
//$to = 'davidtgericke@gmail.com';
$from = 'support@findgo.co.za';

$fromName = 'FindGo Support';
$subject = "FindGo Admin  Sign Up";

// Set content-type header for sending HTML email
$headers = "MIME-Version: 1.0" . "\r\n";
$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";

// Additional headers
$headers .= 'From: ' . $fromName . '<' . $from . '>' . "\r\n";
//$headers .= 'Cc: '. $from . "\r\n";
//$headers .= 'Bcc: mike@skylarkdigital.co.za' . "\r\n";

// Send email
if (mail($to, $subject, $htmlContent, $headers)) {
	// echo 'Email has sent successfully.';
	//			echo '{"error":"false","Message":"Thank you, your gift has been emailed" }';
} else {
	// echo 'Email sending failed.';
	//		 echo '{"error":"true","Message":"Thank you, user was sent, but an error occured. Please look out for your email. '. mysqli_error($db).' }';
}
