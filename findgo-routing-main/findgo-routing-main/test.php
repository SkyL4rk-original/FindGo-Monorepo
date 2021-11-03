<?php

	if (true) {
		$firebaseToken = trim($_SERVER['HTTP_FB_TOKEN']);
		$jwt = trim($_SERVER['HTTP_JWT']);
		echo "JWT: ".$jwt."\r\n";
		echo "Token: ".$firebaseToken."\r\n";
		if ($firebaseToken != "") {
		 echo "update: ".$firebaseToken;
		}
	}

?>
