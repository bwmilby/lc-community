<?php
/*file: wpEncryptionTest.php
--Authored by:
--William A. Prothero
--prothero@ucsb.edu
--https://earthlearningresources.org
--with inspiration and help from:
--Brian Milby and Andre Garza
*/

//external function
function debug($msg) {
	$debug = false;
	if ($debug) {
		error_log("[DB LIB] $msg");
		echo "$msg.\n";
	}
}

function getRandomIV($n) {
	$tIV = openssl_random_pseudo_bytes($n,$cstrong);
	return $tIV;
}

//php code
//the encryption key should be stored in the .htaccess file in the directory of this file
//create a different encryption key, 32 chars long and put it into the .htacess
//file by adding the line:
//SetEnv ekeyTest "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC"
	$encryption_key = getEnv("ekeyTest");
//if you want to include the key in this script (less secure), do
//	$encryption_key = "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC";  //after uncommenting
//Be sure to use a different key for your application.
	$cipher = "AES-256-CTR"; // do not change cipher unless you know what you're doing
	$postR = file_get_contents('php://input');
//getting iv from data. Note that since IV has been base64 encoded, a
//16 bytes IV will be 24 base64 bytes.
	$b64iv = substr($postR, 0, 24);
	$post = substr($postR,24);  //deletes the first 24 chars
	$iv = base64_decode($b64iv); //decode to get the IV
	$post = openssl_decrypt($post, $cipher, $encryption_key, $options=0, $iv);
	$req = json_decode($post,true);
	if (!$req) {
		debug("error on decrypt");
		debug(openssl_error_string());
	}
//$req is an array containing the members of the array sent
	$theSQLQuery = $req["theQuery"];  //This is just the text of the query

//Put the sql command here.
//You could also use array params in input array (LiveCode) to invoke other commands.
//examples:
/*
	$type = $req["type"];
	switch($type) {
		case "query":
			$values = $result->fetch_all(MYSQLI_ASSOC);
			$tJ = json_encode($values);
			break;
		case "update":
			$lastError = mysqli_error($mysqli);
			if ($lastError == ""){
				$tJ=array("return"=>"Record was updated successfully.");
			} else {
				$tErr = "ERROR: Not able to execute $sql. " . mysqli_error($mysqli);
				$tJ=array("return"=>$tErr);
			}
			$tJ = json_encode($tJ);
			break;
		case "new":
			$newRecID = $mysqli->insert_id;
			$lastError = mysqli_error($mysqli);
			if ($lastError == ""){
				$tJ=array("return"=>"New id: ".$newRecID);
			} else {
				$tErr = "ERROR: Not able to execute $sql. " . mysqli_error($mysqli);
				$tJ=array("return"=>$tErr);
			}
			$tJ = json_encode($tJ);
			break;
		default:
			break;
	}
*/

//This is for debugging only. Delete the next line after it works.
	$retVal = "Decrypted query:\n $theSQLQuery\n";

//new iv for return text decoding
	$iv = getRandomIV(16);
	$b64iv = base64_encode($iv);
	//
	$retVal = openssl_encrypt($retVal, $cipher, $encryption_key,0,$iv);
	echo $b64iv.$retVal;

?>
