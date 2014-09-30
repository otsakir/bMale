<?php

require_once ( dirname(__FILE__) . "/../commons.inc" );

$method = $_SERVER['REQUEST_METHOD'];

if ( $method == "PUT") {
	$inputJSON = file_get_contents('php://input');
	$message= json_decode( $inputJSON, TRUE );
	
	logMessage("Method Put ". $message, "INFO");
}
elseif($method == "GET"){
	header('content-type: application/json');
	$arr=array('subject' => 'Hello this is otsakir', 'from' => 'otsakir',  'subject1' => 'Hello this is Irene',  'from' => 'irene');
	$message=json_encode($arr);
	
	logMessage("Method GET ".$message, "INFO");
}
else{
	http_response_code(405);
}


	

?>
