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
	} else if($_SERVER["REQUEST_METHOD"] != "POST") {
		http_response_code(405);
		echo '{"Message":"Wrong HTTP method"}';
		return;
	}

	$data = json_decode(file_get_contents('php://input'), true);
	$query = $data["query"];

	$url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=".$query."&components=country:za&key=AIzaSyD36E4GLWYxW4uW3atoR4ufYL3wXRl8-H8";

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, $url);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	$output = curl_exec($curl);
	curl_close($curl);

 	echo $output;
?>
