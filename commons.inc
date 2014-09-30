<?php
require_once( dirname( __FILE__ ) . "/config.inc");


function logMessage(  $message, $level ){
	$fp = fopen( LOG_FILE_PATH, 'a');
	
	$record = "Level: " . $level . " | Message: " .  $message . "\n";
	fwrite($fp, $record);
	
	fclose($fp);
}

?>
