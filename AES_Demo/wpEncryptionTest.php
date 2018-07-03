<?php
//file: wpEncryptionTest.php
//external function
 function debug($msg) {
     $debug = false;
     if ($debug) {
         error_log("[DB LIB] $msg");
         echo "$msg.\n";
     	}
 	}
//php code
//the encryption key should be stored in the .htaccess file in the directory of this file
//	$encryption_key = "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC";
//create a different encryption key, 32 chars long and put it into the .htacess
//file by adding the line:
//SetEnv ekeyTest "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC"
//Be sure to use a different key for your application.
	$encryption_key = getEnv("ekeyTest");
 	$cipher = "AES-256-CTR"; // do not change cipher unless you know what you're doing
	$postR = file_get_contents('php://input');
//getting iv from data. Note that since IV has been base64 encoded, a
//16 bit IV will be 24 base64 bits.
	$b64iv = substr($postR, 0, 24);
	$post = substr($postR,24);  //deletes the first 24 chars
	$iv = base64_decode($b64iv); //decode to get the IV
	$post = openssl_decrypt($post, $cipher, $encryption_key, $options=0, $iv);
	$req = json_decode($post,true);
	if (!$req) {
     	     debug("error on decrypt");
     	     debug(openssl_error_string());
 	}
 	$theSQLQuery = $req["theQuery"];  //This is just the text of the query
 //Put the sql commands here.
 //You could also use array params in input array (LiveCode) to invoke other commands.

 //This is for debugging only. Delete the next line after it works.
     $retVal = "Decrypted query:.\n $theSQLQuery.\n";

     $retVal = openssl_encrypt($retVal, $cipher, $encryption_key,0,$iv);
	echo $b64iv.$retVal;

?>
