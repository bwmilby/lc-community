libHash-Hmac
Version 2.3
September 2009

-----------
v2.3: added crc (16, ccitt, 32) functions
v2.2: added sha1 htpasswd functions
v2.1: optimised the sha256 processing - increased speed by factor of 5.

-----------

This library provides hmac and hash functions that are not currently available in the Revolution engine:

sha-1, sha-224, and sha-256, and hmac functions for each hash type (including md5, which is provided by the engine).

-----

The hash functions take either any string of bytes, or a full path name, and optionally a boolean (true|false) to indicate whether or not to read from a file.

sha1.hex(pInput, pIsaFile) -- returns the hexadecimal representation of the digest
sha1.bin((pInput, pIsaFile) -- returns the binary representation of the digest
sha1.b64((pInput, pIsaFile) -- return the binary representation of the digest, base64 encoded
sha224.hex(pInput, pIsaFile)
sha224.bin(pInput, pIsaFile)
sha224.b64(pInput, pIsaFile)
sha256.hex(pInput, pIsaFile)
sha256.bin(pInput, pIsaFile)
sha256.b64(pInput, pIsaFile)
and (included for consistency and convenience, calling the built-in md5digest function)
md5.hex(pInput, pIsaFile)
md5.bin(pInput, pIsaFile)
md5.b64(pInput, pIsaFile)

nb. if you pass a file to the md5 functions, the whole file will be read in to a variable - not always desirable if a the file is very big. 


So, to get the sha-256 digest of a string:
put sha256.hex("the cat sat on the mat") into tDigest
put sha256.b64(someVariable) into tDigest

and of a file
put sha256.bin("/Users/yourusername/Desktop/somefile.txt", true) into tDigest

-----

Hmacs take a message, and a key, so

hmacSha1.hex(pMessage, pKey)
hmacSha1.bin(pMessage, pKey)
hmacSha1.b64(pMessage, pKey)
hmacSha224.hex(pMessage, pKey)
hmacSha224.bin(pMessage, pKey)
hmacSha224.b64(pMessage, pKey)
hmacSha256.hex(pMessage, pKey)
hmacSha256.bin(pMessage, pKey)
hmacSha256.b64(pMessage, pKey)
hmacMd5.hex(pMessage, pKey)
hmacMd5.bin(pMessage, pKey)
hmacMd5.b64(pMessage, pKey)

-----

For compatiblity with previous versions of this library ("HMACSHA1"), there are also these hash functions that take a full path name and call openssl, which will tend to be very much quicker for big files:

filemd5.hex(tPath)
filemd5.bin(tPath)
filemd5.b64(tPath)
fileSha1.hex(tPath)
fileSha1.bin(tPath)
fileSha1.b64(tPath)

-----

htpasswd functions

htpasswd.sha1(pPassword)	returns the hashed password in the form:
				{ SHA} passwordhash

htpasswd.sha1.salted(pPassword)	returns the hashed password in the form:
				{ SSHA} saltedpasswordhash

verify.htpasswd.sha1(pPassword, pStoredPwHash)
				returns true or false

-----

crc functions:
.hex return a hexadecimal value
.bin returns a binary value
.dec returns a decimal integer value

crc16.hex(tData)
crc16.bin(tData)
crc16.dec(tData)
filecrc16.hex(tPath)
filecrc16.bin(tPath)
filecrc16.dec(tPath)

crc16ccitt.hex(tData)
crc16ccitt.bin(tData)
crc16ccitt.dec(tData)
filecrc16ccitt.hex(tData)
filecrc16ccitt.bin(tData)
filecrc16ccitt.dec(tData)

crc32.hex(tData)
crc32.bin(tData)
crc32.dec(tData)
filecrc32.hex(tPath)
filecrc32.bin(tPath)
filecrc32.dec(tPath)

-----				
Mark Smith
mark@maseurope.net
9th September 2009