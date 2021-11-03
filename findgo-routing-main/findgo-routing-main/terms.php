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

	$terms = "<div>
    <h1>Demo Page</h1>
    <p>This is a fantastic product that you should buy!</p>
    <h3>Features</h3>
    <ul>
      <li>It actually works</li>
      <li>It exists</li>
      <li>It doesn't cost much!</li>
    </ul>
    <!--You can pretty much put any html in here!-->
  </div>";

	http_response_code(200);
	echo $terms;
?>
