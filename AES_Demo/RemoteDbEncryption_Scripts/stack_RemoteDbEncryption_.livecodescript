Script "stack_RemoteDbEncryption_"

/*
# Name: stack "RemoteDbEncryption"
# ID: stack "RemoteDbEncryption"
*/


-- The following handlers should be in the main stack
--These contain the secret information that you don't want
--users or hackers to find.

--This stack was authored by:
--William A. Prothero
--prothero@ucsb.edu
--https://earthlearningresources.org
--with inspiration and help from:
--Brian Milby and Andre Garza

local theRandomSeed


function randomChrs n
   local tChars, tChar

   setRandomSeed
   put "" into tChars
   repeat with i=1 to n
      put random(256) into tChar
      put numToNativeChar(tChar) after tChars
   end repeat
   return tChars
end randomChrs


on setRandomSeed
   local tMS

   put (the milliseconds) into tMS
   put tMS mod 1000000 into theRandomSeed
   set the randomseed to theRandomSeed
end setRandomSeed


function theRandomIV
   local tIVBytes

   put randomChrs(16) into tIVBytes
   return tIVBytes
end theRandomIV


--This handler encodes the data. First it generates a random
--initialization vector (iv), then encrypts the data and puts
--adds iv to the encoded data.
--tArray is an array that controls the action of the php script.
function theEncoded tArray
   local tIV, tB64IV, tJson, tEncryptionKey, tCipher, tDataToSend

   put  theRandomIV() into tIV
   put base64Encode(tIV) into tB64IV
   put ArrayToJSON(tArray,"string","") into tJson
   put "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC" into tEncryptionKey
   put "AES-256-CTR" into tCipher
   encrypt tJson using tCipher with key tEncryptionKey and iV tIV
   put base64encode(it) into tDataToSend
   --comment out next statement if iv not included in data
   put tB64IV & tDataToSend into tDataToSend
   return tDataToSend
end theEncoded


--This decodes the data that is returned by the php on the
--remote server.
--The iv is expected as the first 24 bytes of the returned data.
function theDecoded tData
   local tIVB64, tIV, n, tRetB64Data, tRetData, tCipher, tEncryptionKey, tReturn

   put byte 1 to 24 of tData into tIVB64
   put base64decode(tIVB64) into tIV
   put the number of bytes in tData into n
   put byte 25 to n of tData into tRetB64Data
   put base64decode(tRetB64Data) into tRetData
   put "AES-256-CTR" into tCipher
   --the next line must math the emcryption string in the php script
   put "AFBDDFCFBDBBDDCCFFACGHDFFFFEEDCC" into tEncryptionKey
   decrypt tRetData using tCipher with key tEncryptionKey and iV tIV
   put it into tReturn
   return tReturn
end theDecoded
-- End of handlers should be in the main stack


--This handler is called to do the complete encrypt, send, retrieve, decrypt
-- operations.
on testEncryption
   local myURL, tCipher, tPostA, tMyEncryptedData, tRet

   put "" into fld "status"
   put "https://milby.us/lc/wpEncryptionTest.php" into myURL
   put "AES-256-CTR" into tCipher
   put "If you can read this, the test is successful." into tPostA["theQuery"]
   put "query" into tPostA["type"]
   put theEncoded(tPostA) into tMyEncryptedData
   post tMyEncryptedData to url myURL
   put it into tRet
   put "Encrypted return from php" & lf into fld "status"
   put tRet after fld "status"
   put lf & theDecoded(tRet) after fld "status"
end testEncryption


on preOpenCard
   revUpdateGeometry
end preOpenCard
