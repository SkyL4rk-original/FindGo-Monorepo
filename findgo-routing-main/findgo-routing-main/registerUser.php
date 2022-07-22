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
$type = $data["type"]; // admin / general

$refreshToken = "";

// Set type database table name for user type
$dbTableNameUser = "user";
if ($type == "admin") $dbTableNameUser = "userAdmin";

// Check if user already created
$userHasDeletedAccount = false;
$result = $db->query("SELECT email, status FROM $dbTableNameUser WHERE email='$email' LIMIT 1");
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
	if ($dbTableNameUser == "userAdmin") {
		// Update userAdmin into database
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
					updatedAt=?
				WHERE email='$email' LIMIT 1
			");

		$stmt->bind_param(
			"sssssssss",
			$hashedPassword,
			$firstName,
			$lastName,
			$storeUuid,
			$role,
			$firebaseToken,
			$refreshToken,
			$dateTimeNow,
			$dateTimeNow
		);
		$stmt->execute();
		$stmt->close();

		if ($stmt === false) {
			http_response_code(500);
			echo '{"Message": "Database update admin error ' . mysqli_error($db) . '"}';
			return;
		}
	} else {
		// Update user into database
		$stmt = $db->prepare("
				UPDATE user
				SET
					password=?,
					firstName=?,
				  lastName=?,
				  firebaseToken=?,
					refreshToken=?,
				  createdAt=?,
					updatedAt=?
				WHERE email='$email' LIMIT 1
			");

		$stmt->bind_param(
			"sssssss",
			$hashedPassword,
			$firstName,
			$lastName,
			$firebaseToken,
			$refreshToken,
			$dateTimeNow,
			$dateTimeNow
		);
		$stmt->execute();
		$stmt->close();

		if ($stmt === false) {
			http_response_code(500);
			echo '{"Message": "Database update user error ' . mysqli_error($db) . '"}';
			return;
		}
	}
} else {

	if ($dbTableNameUser == "userAdmin") {
		// Insert userAdmin into database

		$stmt = $db->prepare("
				INSERT INTO userAdmin (userUuid, email, password, firstName, lastName, storeUuid, role, firebaseToken, refreshToken, createdAt, updatedAt)
				VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
			");
		if ($stmt === false) {
			http_response_code(500);
			echo '{"Message": "Database insert admin error ' . mysqli_error($db) . '"}';
			return;
		}

		$stmt->bind_param(
			"ssssssssss",
			$email,
			$hashedPassword,
			$firstName,
			$lastName,
			$storeUuid,
			$role,
			$firebaseToken,
			$refreshToken,
			$dateTimeNow,
			$dateTimeNow
		);
		$stmt->execute();
		$stmt->close();


		//$result = $db->query("
		//INSERT INTO userAdmin (userUuid, email, password, firstName, lastName, storeUuid, role, firebaseToken, createdAt, updatedAt)
		//VALUES (
		//UUID(),
		//'$email',
		//'$hashedPassword',
		//'$firstName',
		//'$lastName',
		//'$storeUuid',
		//'$role',
		//'$firebaseToken',
		//'$dateTimeNow',
		//'$dateTimeNow'
		//)
		//");
		//if(!$result) {
		//http_response_code(500);
		//echo '{"Message": Database insert error '.mysqli_error($db).'"}';
		//return;
		//}
	} else {
		// Insert user into database
		$stmt = $db->prepare("
				INSERT INTO user (userUuid, email, password, firstName, lastName, firebaseToken, refreshToken, createdAt, updatedAt)
				VALUES (UUID(), ?, ?, ?, ?, ?, ?, ?, ?)
			");
		if ($stmt === false) {
			http_response_code(500);
			echo '{"Message": "Database insert user error ' . mysqli_error($db) . '"}';
			return;
		}

		$stmt->bind_param(
			"ssssssss",
			$email,
			$hashedPassword,
			$firstName,
			$lastName,
			$firebaseToken,
			$refreshToken,
			$dateTimeNow,
			$dateTimeNow
		);
		$stmt->execute();
		$stmt->close();

		//$result = $db->query("
		//INSERT INTO user (userUuid, email, password, firstName, lastName, firebaseToken, createdAt, updatedAt)
		//VALUES (
		//UUID(),
		//'$email',
		//'$hashedPassword',
		//'$firstName',
		//'$lastName',
		//'$firebaseToken',
		//'$dateTimeNow',
		//'$dateTimeNow'
		//)
		//");
		//if(!$result) {
		//http_response_code(500);
		//echo '{"Message": Database insert error '.mysqli_error($db).'"}';
		//return;
		//}
	}
}



// Get created user
$result = $db->query("SELECT * FROM $dbTableNameUser WHERE `email` = '$email'");
if ($result->num_rows == 0) {
	http_response_code(500);
	echo '"Message":"Database select error: ' . mysqli_error($db) . '"}';
	return;
}

// get user from created / found user
$user = $result->fetch_assoc();

// Remove ID & password
$user["ID"] = "";
$user["password"] = "";
unset($user["ID"]);
unset($user["password"]);

// Create jwt from clientUuid & add as header
$token = createToken($user["userUuid"]);
$refreshToken = createRefreshToken($user["userUuid"]);
//setcookie("token", $token, 20000);
//$user["token"] = $token;

// Get time now in UTC
$dateTimeNow = gmdate('Y-m-d H:i:s', time());

// add refreshToken to db
$result = $db->query("
		UPDATE $dbTableNameUser
		SET refreshToken='$refreshToken'
		WHERE email='$email'
	");
//	if (!$result) {
//		http_response_code(200);
//		//echo mysqli_error($db);
//		echo '{"Message":"Store"}';
//		return;
//	}

header("jwt: " . $token);
header("refresh-token: " . $refreshToken);
http_response_code(201);

// Return json user object
echo  json_encode($user);


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

							html,
							body {
									margin: 0 auto !important;
									padding: 0 !important;
									height: 100% !important;
									width: 100% !important;
									background: #f1f1f1;
							}

							* {
									-ms-text-size-adjust: 100%;
									-webkit-text-size-adjust: 100%;
							}


							div[style*="margin: 16px 0"] {
									margin: 0 !important;
							}


							table,
							td {
									mso-table-lspace: 0pt !important;
									mso-table-rspace: 0pt!important;
							}


							table {
								border-spacing: 0 !important;
									border-collapse: collapse !important;
									table-layout: fixed !important;
									margin: 0 auto !important;
							}


							img {
									-ms-interpolation-mode:bicubic;
							}

							a {
									text-decoration: none;
							}


							*[x-apple-data-detectors],
							.unstyle-auto-detected-links *,
							.aBn {
									border-bottom: 0 !important;
									cursor: default !important;
									color: inherit !important;
									text-decoration: none !important;
									font-size: inherit !important;
									font-family: inherit !important;
									font-weight: inherit !important;
									line-height: inherit !important;
							}


							.a6S {
									display: none !important;
									opacity: 0.01 !important;
							}


							.im {
									color: inherit !important;
							}


							img.g-img + div {
									display: none !important;
							}



							@media only screen and (min-device-width: 320px) and (max-device-width: 374px) {
									u ~ div .email-container {
											min-width: 320px !important;
									}
							}

							@media only screen and (min-device-width: 375px) and (max-device-width: 413px) {
									u ~ div .email-container {
											min-width: 375px !important;
									}
							}

							@media only screen and (min-device-width: 414px) {
									u ~ div .email-container {
											min-width: 414px !important;
									}
							}


									</style>

									<style>

										.primary{
								background: #000000;
							}
							.bg_white{
								background: #ffffff;
							}
							.bg_light{
								background: #fafafa;
							}
							.bg_black{
								background: #000000;
							}
							.bg_dark{
								background: rgba(0,0,0,.8);
							}
							.email-section{
								padding:2.5em;
							}


							.btn{
								padding: 5px 15px;
								display: inline-block;
							}
							.btn.btn-primary{
								border-radius: 5px;
								background: red;
								color: white;
							}
							.btn.btn-white{
								border-radius: 5px;
								background: #ffffff;
								color: red;
							}
							.btn.btn-white-outline{
								border-radius: 5px;
								background: transparent;
								border: 1px solid #fff;
								color: #fff;
							}
							.btn.btn-black{
								border-radius: 5px;
								background: #000;
								color: #fff;
							}

							h1,h2,h3,h4,h5,h6{
								font-family: \'Nunito Sans\', sans-serif;
								color: #000000;
								margin-top: 0;
							}

							body{
								font-family: \'Nunito Sans\', sans-serif;
								font-weight: 400;
								font-size: 15px;
								line-height: 1.8;
								color: rgba(0,0,0,.4);
							}

							a{
								color: #f1c638;
							}

							table{
							}


							.logo h1{
								margin: 0;
							}
							.logo h1 a{
								color: #000000;
								font-size: 20px;
								font-weight: 700;
								font-family: \'Nunito Sans\', sans-serif;
							}

							.navigation{
								padding: 0;
							}
							.navigation li{
								list-style: none;
								display: inline-block;;
								margin-left: 5px;
								font-size: 13px;
								font-weight: 500;
							}
							.navigation li a{
								color: rgba(0,0,0,.4);
							}


							.hero{
								position: relative;
								z-index: 0;
							}
							.hero .overlay{
								position: absolute;
								top: 0;
								left: 0;
								right: 0;
								bottom: 0;
								content: "";
								width: 100%;
								background: #000000;
								z-index: -1;
								opacity: .3;
							}
							.hero .icon{
							}
							.hero .icon a{
								display: block;
								width: 60px;
								margin: 0 auto;
							}
							.hero .text{
								/*color: rgba(0,0,0,.8);*/
								color: rgba(255,255,255,.8);
							}
							.hero .text h2{
								color: #ffffff;
								font-size: 32px;
								margin-bottom: 0;
								font-weight: 200;
								line-height: 1.4;
							}

							.heading-section{
							}
							.heading-section h2{
								color: #000000;
								font-size: 28px;
								margin-top: 0;
								line-height: 1.4;
								font-weight: 400;
							}
							.heading-section .subheading{
								margin-bottom: 20px !important;
								display: inline-block;
								font-size: 13px;
								text-transform: uppercase;
								letter-spacing: 2px;
								color: rgba(0,0,0,.4);
								position: relative;
							}
							.heading-section .subheading::after{
								position: absolute;
								left: 0;
								right: 0;
								bottom: -10px;
								content: "";
								width: 100%;
								height: 2px;
								background: #f1c638;
								margin: 0 auto;
							}

							.heading-section-white{
								color: rgba(255,255,255,.8);
							}
							.heading-section-white h2{
								font-family:
								line-height: 1;
								padding-bottom: 0;
							}
							.heading-section-white h2{
								color: #ffffff;
							}
							.heading-section-white .subheading{
								margin-bottom: 0;
								display: inline-block;
								font-size: 13px;
								text-transform: uppercase;
								letter-spacing: 2px;
								color: rgba(255,255,255,.4);
							}


							.icon{
								text-align: center;
							}
							.icon img{
							}


							.services{
							}
							.text-services{
								padding: 10px 10px 0;
								text-align: center;
							}
							.text-services h3{
								font-size: 18px;
								font-weight: 400;
							}

							.services-list{
								padding: 0;
								margin: 0 0 20px 0;
								width: 100%;
								float: left;
							}

							.services-list img{
								float: left;
							}
							.services-list .text{
								width: calc(100% - 60px);
								float: right;
							}
							.services-list h3{
								margin-top: 0;
								margin-bottom: 0;
							}
							.services-list p{
								margin: 0;
							}

							.project-entry{
								position: relative;
							}
							.text-project{
								padding-top: 10px;
								position: absolute;
								bottom: 10px;
								left: 0;
								right: 0;
							}
							.text-project h3{
								margin-bottom: 0;
								font-size: 16px;
								font-weight: 600;
							}
							.text-project h3 a{
								color: #fff;
							}
							.text-project span{
								font-size: 13px;
								color: rgba(255,255,255,.8);
							}


							.pricing{
								position: relative;
								text-align: center;
								border: 1px solid rgba(0,0,0,.05);
								border: 1px solid #f1c638;
								padding: 2em 1em;

							}
							.pricing h3{
								font-weight: 400;
								margin-bottom: 10px;
							}
							.pricing h2{
								font-size: 50px;
								font-weight: 400;
								margin-bottom: 0;
								margin-top: 0;
								line-height: 1.4;
							}
							.pricing .start{
								padding: 0;
								font-weight: 600;
								margin-bottom: 0;
							}
							.pricing h2 span{
							}
							.pricing h2 small{
								font-size: 18px;
							}
							.pricing ul{
								padding: 0;
								margin: 20px 0 0 0;
							}
							.pricing ul li{
								list-style: none;
								margin-bottom: 10px;
							}


							.text-services .meta{
								text-transform: uppercase;
								font-size: 14px;
								margin-top: 0;
							}
							.text-services h3{
								margin-top: 0;
								line-height: 1.2;
								font-size: 20px;
							}

							.text-testimony .name{
								margin: 0;
							}
							.text-testimony .position{
								color: rgba(0,0,0,.3);

							}


							.img{
								width: 100%;
								height: auto;
								position: relative;
							}
							.img .icon{
								position: absolute;
								top: 50%;
								left: 0;
								right: 0;
								bottom: 0;
								margin-top: -25px;
							}
							.img .icon a{
								display: block;
								width: 60px;
								position: absolute;
								top: 0;
								left: 50%;
								margin-left: -25px;
							}

							.counter{
								width: 100%;
								position: relative;
								z-index: 0;
							}
							.counter .overlay{
								position: absolute;
								top: 0;
								left: 0;
								right: 0;
								bottom: 0;
								content: "";
								width: 100%;
								background: #000000;
								z-index: -1;
								opacity: .3;
							}
							.counter-text{
								text-align: center;
								color: white;
							}
							.counter-text .num{
								display: block;
								color: #000;
								font-size: 34px;
								font-weight: 400;
							}
							.counter-text .name{
								display: block;
								color: rgba(0,0,0,.9);
								font-size: 14px;
							}



							ul.social{
								padding: 20px 0 0 0;
							}
							ul.social li{
								display: inline-block;
								margin-right: 10px;
							}

							.footer{
								color: rgba(255,255,255,.5);

							}
							.footer .heading{
								color: #ffffff;
								font-size: 20px;
							}
							.footer ul{
								margin: 0;
								padding: 0;
							}
							.footer ul li{
								list-style: none;
								margin-bottom: 10px;
							}
							.footer ul li a{
								color: rgba(255,255,255,1);
							}


							@media screen and (max-width: 500px) {

								.icon{
									text-align: left;
								}

								.text-services{
									padding-left: 0;
									padding-right: 20px;
									text-align: left;
								}

							}


			</style>

	</head>

	<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #222222;">
		<center style="width: 100%; background-color: #f1f1f1;">

			<div style="max-width: 600px; margin: 0 auto;" class="email-container">
				<table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin: auto;">
					<tr>
						<td valign="top" class="bg_white" style="padding: 1em 2.5em;">
							<table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%">
								<tr>
									<td width="40%" class="logo" style="text-align: left;">
										<h1><a href="#">Find.Go.Enjoy</a></h1>
									</td>
									<td width="60%" class="logo" style="text-align: right;">
										<ul class="navigation">
											<li><a href="https://apps.apple.com/us/app/findgo/id1574321570">
													<img alt="app store button" src="https://www.findgo.co.za/admin/assets/images/apple_store.png" height="30">
											</a></li>
											<li><a href="https://play.google.com/store/apps/details?id=app.specials.findgo">
													<img alt="play store button" src="https://www.findgo.co.za/admin/assets/images/google_store.png" height="30">
											</a></li>
											<li><a href="https://appgallery.huawei.com/#/app/C104564149">
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
													<h2 style="color: white;">Welcome to FindGo</h2>
													</br>
													<h4 style="color: white;">' . $email . '</h4>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<tr>
						<td class="bg_white">
							<table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
								<tr>
									<td class="bg_white email-section">
										<div class="heading-section" style="text-align: center; padding: 0 30px;">
											<p>This email was sent to confirm you have signed up to FindGo with the recieving email.</p>
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
</html>
	';


// Send Register Email
$to = $email;
//$to = 'davidtgericke@gmail.com';
$from = 'support@findgo.co.za';

$fromName = 'FindGo Support';
$subject = "FindGo Sign Up";

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
