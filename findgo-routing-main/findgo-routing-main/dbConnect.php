<?php

$dbHost = '127.0.0.1';  //or 127.0.0.1 or localhost

// Prod
//$dbUsername = 'findg_skydev';
//$dbPassword = '1!23SkyL4rk_74$';
//$dbName = 'findg_specials';

// Dev
$dbUsername = 'skylasde_jordan';
$dbPassword = '1!23Abc_74$%^';
$dbName = 'skylasde_specials';
$db = new mysqli($dbHost, $dbUsername, $dbPassword, $dbName);

if ($db->connect_error) {
    die("Connection failed: " . $db->connect_error);
} else {
	//echo 'connected';
}
?>
