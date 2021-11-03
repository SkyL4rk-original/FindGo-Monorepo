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

	//$data = json_decode(file_get_contents('php://input'), true);
	$placeId = $_GET["place"];

	$url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=".$placeId."&key=AIzaSyD36E4GLWYxW4uW3atoR4ufYL3wXRl8-H8";
	//$url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=ChIJv_g_UNwU9x4RtVqWhm_7Uz4&key=AIzaSyD36E4GLWYxW4uW3atoR4ufYL3wXRl8-H8";

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	$output = curl_exec($curl);
	curl_close($curl);

 	echo $output;
?>
