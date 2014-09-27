<?php

$method = $_SERVER['REQUEST_METHOD'];

syslog(LOG_INFO, "Using method: " . $method);
syslog(LOG_INFO, "Received new message");

if ( $method == "PUT") {
	$inputJSON = file_get_contents('php://input');
	$message= json_decode( $inputJSON, TRUE );
	
	syslog(LOG_INFO, "subject: " . $message["subject"]);
	syslog(LOG_INFO, "destination: " . $message["destination"]);
}


?>
