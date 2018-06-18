Script "stack_awsLibs_button_id_1012"

/*
# Name: button "bin-crypt" of card id 1002 of stack "awsLibs"
# ID: button id 1012 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
bin-crypt library
version: 1.0.0b
date: 20090501
author: Mark Smith
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---

# libHash-Hmac
# version 2.2
# January 2009
# v2.2 added htpasswd sha1 functions
# v2.1 optimised sha256 processing by putting rotations in line.


--> md5

private function md5 pSource, pIsFile, pFormat
   if pIsFile and there is a file pSource then
      if the platform is "Win32" then
         put url ("binfile:" & pSource) into tData
         put md5digest(tData) into tBin
      else
         put word -1 of shell("openssl md5" && q(pFile)) into tBin
      end if
   else
      put md5digest(pSource) into tBin
   end if
   
   switch pFormat
      case "bin"
         return tBin
         break
      case "b64"
         return base64encode(tBin)
         break
      case "all"
         put tBin into tArray["bin"]
         put binToHex(tbin) into tArray["hex"]
         put base64encode(tBin) into tArray["b64"]
         return tArray
      default
         return binToHex(tBin)
         break
   end switch
end md5

-----

function md5.bin pInput, pIsFile
   return md5(pInput, pIsFile, "bin")
end md5.bin

function md5.hex pInput, pIsFile
   return md5(pInput, pIsFile, "hex")
end md5.hex

function md5.b64 pInput, pIsFile
   return md5(pInput, pIsFile, "b64")
end md5.b64

function md5.all pInput, pIsFile
   return md5(pInput, pIsFile, "all")
end md5.all

-----------------------------------------------
# for compatibility with old version of library

function fileMd5.bin pFile
   put word -1 of shell("openssl md5" && q(pFile)) into tDigest
   return hexToBin(tDigest)
end fileMd5.bin

function fileMd5.hex pFile
   put word -1 of shell("openssl md5" && q(pFile)) into tDigest
   return tDigest
end fileMd5.hex

function fileMd5.b64 pFile
   put word -1 of shell("openssl md5" && q(pFile)) into tDigest
   return base64encode(hexToBin(tDigest))
end fileMd5.b64

function fileMd5.all pFile
   put word -1 of shell("openssl md5" && q(pFile)) into tDigest
   put tDigest into tArray["hex"]
   put hexToBin(tDigest) into tArray["bin"]
   put base64encode(tArray["bin"]) into tArray["b64"]
   return tArray
end fileMd5.all

-----

function m58 pString
   put md5.hex(pString) into tHash
   repeat with n = 1 to 28 step 4
      put byte n of tHash after tM5
   end repeat
   return tM5
end m58

------------------------------------------------
--> sha1

function ms_sha1digest pInput, pIsFile
   put sha1(pInput, pIsFile) into tDigest
   return tDigest
end ms_sha1digest

function sha1.bin pInput, pIsFile
   put sha1(pInput, pIsFile) into tDigest
   return tDigest
end sha1.bin

function sha1.hex pInput, pIsFile
   put sha1(pInput, pIsFile) into tDigest
   return binToHex(tDigest)
end sha1.hex

function sha1.b64 pInput, pIsFile
   put sha1(pInput, pIsFile) into tDigest
   return base64encode(tDigest)
end sha1.b64

-----------------------------------------------
# for compatibility with old version of library
# and uses openssl, so is faster for big files.

function fileSha1.bin pFile
   put word -1 of shell("openssl sha1" && q(pFile)) into tDigest
   return hexToBin(tDigest)
end fileSha1.bin

function fileSha1.hex pFile
   put word -1 of shell("openssl sha1" && q(pFile)) into tDigest
   return tDigest
end fileSha1.hex

function fileSha1.b64 pFile
   put word -1 of shell("openssl sha1" && q(pFile)) into tDigest
   return base64encode(hexToBin(tDigest))
end fileSha1.b64

------------------------------------------------
--> sha2

function sha256digest pInput, pIsFile
   put sha2(pInput, pIsFile, 256) into tDigest
   return tDigest
end sha256digest

function sha256.bin pInput, pIsFile
   put sha2(pInput, pIsFile, 256) into tDigest
   return tDigest
end sha256.bin

function sha256.hex pInput, pIsFile
   put sha2(pInput, pIsFile, 256) into tDigest
   return binToHex(tDigest)
end sha256.hex

function sha256.b64 pInput, pIsFile
   put sha2(pInput, pIsFile, 256) into tDigest
   return base64encode(tDigest)
end sha256.b64

------------------------------------------------

function sha224digest pInput, pIsFile
   put sha2(pInput, pIsFile, 224) into tDigest
   return tDigest
end sha224digest

function sha224.bin pInput, pIsFile
   put sha2(pInput, pIsFile, 224) into tDigest
   return tDigest
end sha224.bin

function sha224.hex pInput, pIsFile
   put sha2(pInput, pIsFile, 224) into tDigest
   return binToHex(tDigest)
end sha224.hex

function sha224.b64 pInput, pIsFile
   put sha2(pInput, pIsFile, 224) into tDigest
   return base64encode(tDigest)
end sha224.b64

------------------------------------------------
--> hmac

private function hmacMd5 pMsg, pKey
   if length(pKey) > 64 then put md5digest(pKey) into pKey
   repeat 64 - length(pKey)
      put null after pKey
   end repeat
   
   repeat for each byte c in pKey
      put numtobyte(bytetonum(c) bitXor 54) after ipad
      put numtobyte(bytetonum(c) bitXor 92) after opad
   end repeat
   
   return md5digest(opad & md5digest(ipad & pMsg))
end hmacMd5

function hmacMd5.hex pMsg, pKey
   return binToHex(hmacMd5(pMsg, pKey))
end hmacMd5.hex

function hmacMd5.b64 pMsg, pKey
   return base64encode(hmacMd5(pMsg, pKey))
end hmacMd5.b64

function hmacMd5.bin pMsg, pKey
   return hmacMd5(pMsg, pKey)
end hmacMd5.bin

------------------------------------------------

private function hmacSha1 pMsg, pKey
   if length(pKey) > 64 then put sha1(pKey) into pKey
   repeat 64 - length(pKey)
      put null after pKey
   end repeat
   
   repeat for each byte c in pKey
      put numtobyte(bytetonum(c) bitXor 54) after ipad
      put numtobyte(bytetonum(c) bitXor 92) after opad
   end repeat
   
   return sha1(opad & sha1(ipad & pMsg))
end hmacSha1

function hmacSha1.hex pMsg, pKey
   return binToHex(hmacSha1(pMsg, pKey))
end hmacSha1.hex

function hmacSha1.b64 pMsg, pKey
   return base64encode(hmacSha1(pMsg, pKey))
end hmacSha1.b64

function hmacSha1.bin pMsg, pKey
   return hmacSha1(pMsg, pKey)
end hmacSha1.bin

------------------------------------------------

private function hmacSha2 pMsg, pKey, pNumBits
   if length(pKey) > 64 then put sha2(pKey,,pNumBits) into pKey
   repeat 64 - length(pKey)
      put null after pKey
   end repeat
   
   repeat for each byte b in pKey
      put numtobyte(bytetonum(b) bitXor 54) after ipad
      put numtobyte(bytetonum(b) bitXor 92) after opad
   end repeat
   
   return sha2(opad & sha2(ipad & pMsg,,pNumBits),,pNumBits)
end hmacSha2

function hmacSha256.hex pMsg, pKey
   return binToHex(hmacSha2(pMsg, pKey, 256))
end hmacSha256.hex

function hmacSha256.b64 pMsg, pKey
   return base64encode(hmacSha2(pMsg, pKey, 256))
end hmacSha256.b64

function hmacSha256.bin pMsg, pKey
   return hmacSha2(pMsg, pKey, 256)
end hmacSha256.bin

function hmacSha224.hex pMsg, pKey
   return binToHex(hmacSha2(pMsg, pKey, 224))
end hmacSha224.hex

function hmacSha224.b64 pMsg, pKey
   return base64encode(hmacSha2(pMsg, pKey, 224))
end hmacSha224.b64

function hmacSha224.bin pMsg, pKey
   return hmacSha2(pMsg, pKey, 224)
end hmacSha224.bin


------------------------------------------------


local h0
local h1
local h2
local h3
local h4
local h5
local h6
local h7
local k



--> sha internals

private function sha1 pInput, pIsFile
   setInput pInput, pIsFile
   initSha1vars
   
   repeat
      put nextChunk() into tChunk
      if tChunk is not empty then
         processChunkSha1 tChunk
      else
         exit repeat
      end if
   end repeat
   
   return binaryencode("M5", h0,h1,h2,h3,h4)
end sha1

-----

private function sha2 pInput, pIsFile, pNumBits
   setInput pInput, pIsFile
   
   initSha256consts
   if pNumBits = 224 then
      initSha224vars
   else
      initSha256vars
   end if
   
   repeat
      put nextChunk() into tChunk
      if tChunk is not empty then
         processChunkSha256 tChunk
      else
         exit repeat
      end if
   end repeat
   
   if pNumBits = 224 then
      return binaryencode("M7", h0,h1,h2,h3,h4,h5,h6)
   else
      return binaryencode("M8", h0,h1,h2,h3,h4,h5,h6,h7)
   end if
end sha2

-----


private command initSha256vars
   put 1779033703 into h0
   put 3144134277 into h1
   put 1013904242 into h2
   put 2773480762 into h3
   put 1359893119 into h4
   put 2600822924 into h5
   put 528734635 into h6
   put 1541459225 into h7
end initSha256vars

-----

private command initSha224vars
   put 3238371032 into h0
   put 914150663 into h1
   put 812702999 into h2
   put 4144912697 into h3
   put 4290775857 into h4
   put 1750603025 into h5
   put 1694076839 into h6
   put 3204075428 into h7
end initSha224vars

-----

private command initSha1vars
   put 1732584193 into h0
   put 4023233417 into h1
   put 2562383102 into h2
   put 271733878 into h3
   put 3285377520 into h4
end initSha1vars

-----

private command initSha256consts
   if keys(k) is empty then
      put "1116352408,1899447441,3049323471,3921009573,961987163,1508970993," & \ 
            "2453635748,2870763221,3624381080,310598401,607225278," & \
            "1426881987,1925078388,2162078206,2614888103,3248222580," & \
            "3835390401,4022224774,264347078,604807628,770255983," & \
            "1249150122,1555081692,1996064986,2554220882,2821834349," & \
            "2952996808,3210313671,3336571891,3584528711,113926993," & \
            "338241895,666307205,773529912,1294757372,1396182291," & \
            "1695183700,1986661051,2177026350,2456956037,2730485921," & \
            "2820302411,3259730800,3345764771,3516065817,3600352804," & \
            "4094571909,275423344,430227734,506948616,659060556,883997877," & \
            "958139571,1322822218,1537002063,1747873779,1955562222," & \
            "2024104815,2227730452,2361852424,2428436474,2756734187," & \
            "3204031479,3329325298" into tConsts
      
      put 0 into count
      repeat for each item i in tConsts
         put i into k[count]
         add 1 to count
      end repeat
   end if
end initSha256consts

-----

private command processChunkSha256 pChunk
   put chunkToArray(pChunk) into w
   
   # make subchunks
   ----------------
   repeat with i = 16 to 63
      -- original - using rotate right
      -- put (rotr(w[i-15], 7)) bitXor (rotr(w[i-15], 18)) bitXor (shtr(w[i-15], 3)) into s0
      -- put (rotr(w[i-2], 17)) bitXor (rotr(w[i-2], 19)) bitXor (shtr(w[i-2], 10)) into s1
      
      -- substituting rotate left
      --put (rotl(w[i-15], 25)) bitXor (rotl(w[i-15], 14)) bitXor (w[i-15] div 8) into s0
      
      -- rotate left in line
      
      -- s0
      put w[i-15] * 33554432 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp1
         if temp1 = 0 then 
            put 4294967295 into temp1
         end if
      else
         put tNum into temp1
      end if
      
      put w[i-15] * 16384 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp2
         if temp2 = 0 then 
            put 4294967295 into temp2
         end if
      else
         put tNum into temp2
      end if
      
      put temp1 bitXor temp2 bitXor (w[i-15] div 8) into s0
      
      
      
      -- s1
      --put (rotl(w[i-2], 15)) bitXor (rotl(w[i-2], 13)) bitXor (w[i-2] div 1024) into s1
      
      put w[i-2] * 32768 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp1
         if temp1 = 0 then 
            put 4294967295 into temp1
         end if
      else
         put tNum into temp1
      end if
      
      put w[i-2] * 8192 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp2
         if temp2 = 0 then 
            put 4294967295 into temp2
         end if
      else
         put tNum into temp2
      end if
      
      put temp1 bitXor temp2 bitXor (w[i-2] div 1024) into s1
      
      
      put (w[i-16] + s0 + w[i-7] + s1) mod 4294967296 into w[i]
   end repeat
   
   # main processing loop
   ----------------------
   
   put h0 into a
   put h1 into b
   put h2 into c
   put h3 into d
   put h4 into e
   put h5 into f
   put h6 into g
   put h7 into h
   
   
   repeat with i = 0 to 63
      --put (rotr(a, 2)) bitXor (rotr(a, 13)) bitXor (rotr(a, 22)) into s0
      --put (rotl(a, 30)) bitXor (rotl(a, 19)) bitXor (rotl(a, 10)) into s0
      
      put a * 1073741824 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp1
         if temp1 = 0 then 
            put 4294967295 into temp1
         end if
      else
         put tNum into temp1
      end if
      
      put a * 524288 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp2
         if temp2 = 0 then 
            put 4294967295 into temp2
         end if
      else
         put tNum into temp2
      end if
      
      put a * 1024 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp3
         if temp3 = 0 then 
            put 4294967295 into temp3
         end if
      else
         put tNum into temp3
      end if
      
      put temp1 bitXor temp2 bitXor temp3 into s0
      
      
      put (a bitAnd b) bitXor (a bitAnd c) bitXor (b bitAnd c) into maj
      put (s0 + maj) mod 4294967296 into t2
      
      --put (rotr(e, 6)) bitXor (rotr(e, 11)) bitXor (rotr(e, 25)) into s1
      --put (rotl(e, 26)) bitXor (rotl(e, 21)) bitXor (rotl(e, 7)) into s1
      
      put e * 67108864 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp1
         if temp1 = 0 then 
            put 4294967295 into temp1
         end if
      else
         put tNum into temp1
      end if
      
      put e * 2097152 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp2
         if temp2 = 0 then 
            put 4294967295 into temp2
         end if
      else
         put tNum into temp2
      end if
      
      put e * 128 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into temp3
         if temp3 = 0 then 
            put 4294967295 into temp3
         end if
      else
         put tNum into temp3
      end if
      
      put temp1 bitXor temp2 bitXor temp3 into s1
      
      
      
      put (e bitAnd f) bitXor ((bitNot e) bitAnd g) into ch
      put (h + s1 + ch + k[i] + w[i]) mod 4294967296 into t1
      
      put g into h
      put f into g
      put e into f
      put (d + t1) mod 4294967296 into e
      put c into d
      put b into c
      put a into b
      put (t1 + t2) mod 4294967296 into a
   end repeat
   
   
   put (h0 + a) mod 4294967296 into h0
   put (h1 + b) mod 4294967296 into h1
   put (h2 + c) mod 4294967296 into h2
   put (h3 + d) mod 4294967296 into h3
   put (h4 + e) mod 4294967296 into h4
   put (h5 + f) mod 4294967296 into h5
   put (h6 + g) mod 4294967296 into h6
   put (h7 + h) mod 4294967296 into h7
   
end processChunkSha256

-----

private command processChunkSha1 pChunk
   put chunkToArray(pChunk) into w
   -- if the number of lines in keys(w) <> 16 then
   -- put showArray(w)
   -- exit to top
   -- end if
   
   repeat with n = 16 to 79
      put (w[n-3] bitXor w[n-8] bitXor w[n-14] bitXor w[n-16]) * 2 into tNum
      --put rotl(tNum, 1) into w[n]
      
      -- rotateLeft
      if tNum > 4294967295 then
         put tNum mod 4294967295 into r1
         if r1 = 0 then 
            put 4294967295 into r1
         end if
      else
         put tNum into r1
      end if
      put r1 into w[n]
      
   end repeat
   
   
   put h0 into a
   put h1 into b
   put h2 into c
   put h3 into d
   put h4 into e
   
   repeat with n = 0 to 79
      
      if n < 20 then
         put (b bitAnd c) bitOr ((bitNot b) bitAnd d) into f
         put 1518500249 into k
      else if n < 40 then
         put (b bitXor c bitXor d) into f
         put 1859775393 into k
      else if n < 60 then
         put (b bitAnd c) bitOr (b bitAnd d) bitOr (c bitAnd d) into f
         put 2400959708 into k
      else
         put (b bitXor c bitXor d) into f
         put 3395469782 into k
      end if
      
      -- rotateLeft 5
      put a * 32 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into r1
         if r1 = 0 then 
            put 4294967295 into r1
         end if
      else
         put tNum into r1
      end if
      put (r1 + f + e + k + w[n]) mod 4294967296 into tTemp
      
      put d into e
      put c into d
      
      -- rotateLeft 30
      put b * 1073741824 into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into r1
         if r1 = 0 then 
            put 4294967295 into r1
         end if
      else
         put tNum into r1
      end if
      
      put r1 into c
      
      
      
      put a into b
      put tTemp into a
      
   end repeat
   
   put (h0 + a) mod 4294967296 into h0
   put (h1 + b) mod 4294967296 into h1
   put (h2 + c) mod 4294967296 into h2
   put (h3 + d) mod 4294967296 into h3
   put (h4 + e) mod 4294967296 into h4
end processChunkSha1

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--> sha input

local sSource
local sIsFile
local sBytesDone
local sDataSize
local sTail


private command setInput pSource, pIsFile
   put 0 into sDataSize
   put 0 into sBytesDone
   put pSource into sSource
   put empty into sTail
   
   
   if pIsFile and there is a file pSource then
      put true into sIsFile
      open file sSource for binary read
      put getFileSize(sSource) into sDataSize
   else
      put false into sIsFile
      put length(sSource) into sDataSize
   end if
   
   
   put sDataSize mod 64 into tRem
   
   if tRem = 0 then
      put binaryencode("M16", 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) into sTail["u"]
      put numtobyte(128) into byte 1 of sTail["u"]
   else if tRem > 55 then
      repeat 64 - tRem
         put null after sTail["p"]
      end repeat
      put numtobyte(128) into byte 1 of sTail["p"]
      put binaryencode("M16", 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) into sTail["u"]
   else 
      repeat 64 - tRem
         put null after sTail["u"]
      end repeat
      put numtobyte(128) into byte 1 of sTail["u"]
      
   end if
   
   put dataSizeBytes(sDataSize) into byte -8 to -1 of sTail["u"]
   
end setInput

-----

private function dataSizeBytes pNum
   multiply pNum by 8
   repeat with n = 63 down to 0
      put 2 ^ n into tPow
      if pNum div tPow > 0 then
         put 1 after tBits
         subtract tPow from pNum
      else
         put 0 after tBits
      end if
   end repeat
   return binaryencode("B*",tBits)
end dataSizeBytes

-----

private function nextChunk
   put empty into tChunk
   
   if (sBytesDone < sDataSize) and (sDataSize > 0) then
      
      if sIsFile then
         read from file sSource for 64
         put it into tChunk
      else
         put byte (sBytesDone + 1) to (sBytesDone + 64) of sSource into tChunk
      end if
      
      put length(tChunk) into tChunkSize
      add tChunkSize to sBytesDone
      
      if tChunkSize < 56 then
         put sTail["u"] after tChunk
         delete variable sTail
         if sIsFile then 
            close file sSource
         end if
      else if tChunksize > 55 and tChunkSize < 64 then
         put sTail["p"] after tChunk
      end if
      
   else
      if sTail["u"] is not empty then
         put sTail["u"] into tChunk
         delete variable sTail
         if sIsFile then close file sSource
      end if
   end if
   
   return tChunk
end nextChunk

-----

private function chunkToArray pChunk
   local bNum
   put 0 into count
   repeat with n = 1 to 64 - 4 step 4
      get binarydecode("M", byte n to n + 3 of pChunk, bNum)
      put bNum into tArray[count]
      add 1 to count
   end repeat
   return tArray
end chunkToArray

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--> htpasswd

function htpasswd.sha1 pPword
   return "{ SHA} " & sha1.b64(pPword)
end htpasswd.sha1

----

function htpasswd.sha1.salted pPword
   put numtochar(random(255)) & numtochar(random(255)) into tSalt
   return "{ SSHA} " & base64encode(sha1.bin(pPword & tSalt) & (tSalt))
end htpasswd.sha1.salted

-----

function verify.htpasswd.sha1 pPword, pStoredPword
   if pStoredPword begins with "{ SHA} " then
      return htpasswd.sha1(pPword) = pStoredPword
      
   else if pStoredPword begins with "{ SSHA} " then
      put base64decode(byte 8 to -1 of pStoredPword) into tBinStr
      put byte -2 to -1 of tBinStr into tSalt
      
      return sha1.bin(pPword & tSalt) = char 1 to -3 of tBinStr
   end if
end verify.htpasswd.sha1


----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> rpak

function rpak pData
   put pData into tArray["rpakdata"]
   put compress(arrayencode(tArray)) into tPak
   put md5digest(tPak) into tMd5
   
   put base64encode(tPak & md5digest(tPak)) into tPak
   
   replace cr with empty in tPak
   return "rpak" & tPak
end rpak

function unrpak pData
   if char 1 to 4 of pData is not "rpak" then return "not rpak data"
   put base64decode(char 5 to -1 of pData) into tData
   put byte -16 to -1 of tData into tMd5
   delete byte -16 to -1 of tData
   if md5digest(tData) <> tMd5 then return "corrupted data"
   
   put arraydecode(decompress(tData)) into tArray
   return tArray["rpakdata"]
end unrpak

-----

function rpakrc4 pData, pPassphrase
   put pData into tArray["rpakdata"]
   put compress(arrayencode(tArray)) into tPak
   put md5digest(tPak) into tMd5
   
   put base64encode(rc4(tPak & md5digest(tPak), pPassphrase)) into tPak
   
   replace cr with empty in tPak
   return "rpkr" & tPak
end rpakrc4

function unrpakrc4 pData, pPassphrase
   if char 1 to 4 of pData is not "rpkr" then return "not rpakrc4 data"
   put rc4(base64decode(char 5 to -1 of pData), pPassphrase) into tData
   put byte -16 to -1 of tData into tMd5
   delete byte -16 to -1 of tData
   if md5digest(tData) <> tMd5 then return "corrupted data"
   
   put arraydecode(decompress(tData)) into tArray
   return tArray["rpakdata"]
end unrpakrc4

-----

function rpakcrypt pData, pPassphrase, pCipher
   if pCipher is empty then put "blowfish" into pCipher
   put pData into tArray["rpakdata"]
   put compress(arrayencode(tArray)) into tPak
   put md5digest(tPak) into tMd5
   encrypt tPak using pCipher with password pPassphrase
   
   put base64encode(it & tMd5) into tPak
   
   replace cr with empty in tPak
   return "rpkc" & tPak
end rpakcrypt

function unrpakcrypt pData, pPassphrase, pCipher
   if pCipher is empty then put "blowfish" into pCipher
   if char 1 to 4 of pData is not "rpkc" then return "not rpakcrypt data"
   
   put base64decode(char 5 to -1 of pData) into tData
   put byte -16 to -1 of tData into tMd5
   delete byte -16 to -1 of tData
   
   decrypt tData using pCipher with password pPassphrase
   put it into tData
   if md5digest(tData) <> tMd5 then return "corrupted data"
   
   put arraydecode(decompress(tData)) into tArray
   return tArray["rpakdata"]
end unrpakcrypt


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> rc4


function rc4encrypt pData, pKey
   put base64encode(rc4(pData, pKey)) into tData
   replace cr with empty in tData
   return tData
end rc4encrypt

function rc4decrypt pData, pKey
   return rc4(base64decode(pData), pKey)
end rc4decrypt

-----

function cs2encrypt pData, pKey, pEncoding, pIterations
   if pIterations is empty then put 20 into pIterations
   put rc4bytes(10) into tIv
   put rc4(pData, pKey & tIv, pIterations) into tEnc
   
   switch pEncoding
      case "b64"
      case "base64"
         put base64encode(tIv & tEnc) into tRet
         break
      case "mb64"
         put mb64e(tIv & tEnc) into tRet
         break
      case "hex"
         put binToHex(tIv & tEnc) into tRet
         break
      default
         put tIv & tEnc into tRet
         break
   end switch
   return tRet
end cs2encrypt

function cs2decrypt pData, pKey, pEncoding, pIterations
   if pIterations is empty then put 20 into pIterations
   switch pEncoding
      case "b64"
      case "base64"
         put base64decode(pData) into pData
         break
      case "mb64"
         put mb64d(pData) into pData
         break
      case "hex"
         put hexToBin(pData) into pData
         break
   end switch
   put rc4(char 11 to -1 of pData, pKey & char 1 to 10 of pData, pIterations) \
         into tUnenc
   return tUnenc
end cs2decrypt

-----

function rc4 pData, pKey, pIterations
   if not (pIterations is an integer and pIterations > 0) then \
         put 1 into pIterations
   
   -- initialize
   repeat with i = 0 to 255
      put i into S1[i]
   end repeat
   
   put 0 into i
   repeat with n = 0 to 255
      add 1 to i
      if i > length(pkey) then put 1 into i
      put bytetonum(char i of pKey) into S2[n]
   end repeat
   
   put 0 into j
   repeat pIterations
      repeat with i = 0 to 255
         put (j + S1[i] + S2[i]) mod 256 into j
         put S1[i] into temp
         put S1[j] into S1[i]
         put temp into S1[j]
      end repeat
   end repeat
   
   -- encrypt/decrypt
   put 0 into i ; put 0 into j
   repeat for each byte c in pData
      put bytetonum(c) into tChar
      
      put (i + 1) mod 256 into i
      put (j + S1[i]) mod 256 into j
      put S1[i] into temp
      put S1[j] into S1[i]
      put temp into S1[j]
      put (S1[i] + S1[j]) mod 256 into t
      put S1[t] into K
      
      put numtobyte(tChar bitXor K) after tOutput
   end repeat
   
   return tOutput
end rc4

function rc4bytes pNumBytes
   put the millisecs & the seconds & the long date & the platform & the version \
         into tKey
   put the long seconds & $USER & the systemversion & the long id of me \
         after tKey
   put the environment & the millisecs after tKey
   
   put random(1000) into tData
   set the itemdelimiter to "."
   repeat until length(tData) >= pNumBytes
      put item 2 of the long seconds after tData
   end repeat
   
   return rc4(char 1 to pNumBytes of tData, tKey)
end rc4bytes

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> utilities

function q pStr
   return quote & pStr & quote
end q

function sq pStr
   return "'" & pStr & "'"
end sq

function bq pStr
   return "`" & pStr & "`"
end bq

# shift right
private function shtr pNum, pSteps
   if pSteps is empty then put 1 into pSteps
   return pNum div (2 ^ pSteps)
end shtr

-----

# shift left
private function shtl pNum, pSteps
   if pSteps is empty then put 1 into pSteps
   return (pNum * (2 ^ pSteps)) mod 4294967296
end shtl

-----

# rotate right
-- function rotr pNum, pSteps
-- if pNum = 0 then return 0
-- if pSteps is empty then put 1 into pSteps
-- 
-- repeat pSteps
-- put (pNum mod 2 <> 0) into isOdd
-- put pNum div 2 into pNum
-- if isOdd then add 2147483648 to pNum
-- end repeat
-- 
-- return pNum
-- end rotr


private function rotr pNum, pSteps
   if pNum = 0 then return 0
   if pSteps is empty then put 1 into pSteps
   
   return rotl(pNum, 32 - pSteps)
end rotr


-----

# rotate left
private function rotl pNum, pSteps
   if pNum = 0 then return 0
   if pSteps is empty then put 1 into pSteps
   
   put pNum * (2 ^ pSteps) into tNum
   
   if tNum > 4294967295 then
      put tNum mod 4294967295 into r1
      if r1 = 0 then 
         put 4294967295 into r1
      end if
   else
      put tNum into r1
   end if
   return r1
end rotl

-----

private function getFileSize pFileName
   set the itemdelimiter to "/"
   put item 1 to -2 of pFileName into tFolderName
   put item -1 of pFileName into tFileName
   set the itemdelimiter to comma
   
   
   put the directory into tOldFolder
   set the directory to tFolderName
   put urldecode(the detailed files) into tFileList
   
   get lineoffset(tFileName,tFileList)
   put line it of tFileList into tInfo
   return item 2 of tInfo
end getFileSize

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> uuid

function uuidgen pNoDashes
   try
      put shell("uuidgen") into tUuid
   catch tErr
      put newUid() into tUUid
   end try
   if pNoDashes then replace "-" with empty in tUuid
   return tolower(tUuid)
end uuidgen

------------------------
------------------------

function newUid pNoDashes
   put randomHexChars(15) into tTimeStamp
   put bitsToHex("10" & randomBits(14)) into tClockSeq
   put randomHexChars(12) into tNode
   
   put char 8 to 15 of tTimeStamp & "-" into tUUID
   put char 4 to 7 of tTimeStamp & "-" after tUUID
   put "4" & char 1 to 3 of tTimeStamp & "-" after tUUID 
   put tClockSeq & "-" after tUUID
   put tNode after tUUID
   
   if pNoDashes then replace "-" with empty in tUUID
   
   return tolower(tUUID)
end newUid

private function randomHexChars pHowMany
   repeat pHowMany
      put any char of "0123456789abcdef" after tHexChars
   end repeat
   return tHexChars
end randomHexChars

private function randomBits pHowMany
   repeat pHowMany
      put random(2) - 1 after tBits
   end repeat
   return tBits
end randomBits

---===---===---===---===---===---===---===---===---===---===---===---===---===---

/*
libBinConvert
version: 1.1
date: January 2008
author: Mark Smith
*/
-----------------------------------------------------------------


--> bin convert

-----

on setEndian
   put (char 1 of (binaryencode("I",1)) is null) into sBigEndian
end setEndian

-----

function getEndianness
   if sBigEndian then
      return "big"
   else
      return "little"
   end if
end getEndianness

-----

function lbcVersion
   return "1.1"
end lbcVersion

-----

function reverseBytes pBytes
   repeat for each char c in pBytes
      put c before nBytes
   end repeat
   return nBytes
end reverseBytes

-----

function swapBytes pBytes
   repeat with n = 1 to length(pBytes) - 1
      put char n + 1 of pBytes & char n of pBytes after swappedBytes
   end repeat
   return swappedBytes
end swapBytes

-----

function binToHex pString
   repeat for each char c in pString
      get chartonum(c)
      put baseconvert(it,10,16) into tTemp
      if it < 16 then put "0" before tTemp
      put tTemp after tHex
   end repeat
   return tolower(tHex)
end binToHex

----

function binToBits pString
   repeat for each char c in pString
      put format("%08s",baseConvert(chartonum(c),10,2)) into tTemp
      put tTemp after tBits
   end repeat
   return tBits
end binToBits

----

function bitsToBin pBits
   repeat with n = 1 to length(pBits) - 8 step 8
      put char n to n + 7 of pBits into tNum
      
      put numtochar(baseconvert(tNum,2,10)) after tBin
   end repeat
   return tBin
end bitsToBin

----

function decToBits pNum, pNumBits
   if pNumBits is empty then put 32 into pNumBits
   if pNum < 0 then put (2 ^ pNumBits - 1) + pNum into pNum
   if pNum < 2 ^ pNumBits then 
      put baseconvert(pNum,10,2) into tBits
   else
      repeat while pNum >= 1
         if pNum mod 2 = 0 then
            put 0 before tBits
         else
            put 1 before tBits
            subtract 1 from pNum
         end if
         put (pNum / 2) into pNum
      end repeat
   end if
   
   put "%0" & pNumBits & "s" into fStr
   put format(fStr,tBits) into tBits
   
   return tBits
end decToBits

----

function decToHex pDec, pNumDigits
   if pDec < 2 ^ 32 then
      put baseconvert(pDec,10,16) into tHex
   else
      repeat while pDec >= 1
         put pDec mod 16 into tNum
         put baseconvert(tNum,10,16) before tHex
         put pDec div 16 into pDec
      end repeat
   end if
   
   if pNumDigits is not empty and pNumDigits > length(tHex) then
      repeat pNumDigits - length(tHex)
         put 0 before thex
      end repeat
   end if
   
   return tolower(tHex)
end decToHex

----

function hexToBin pHex
   repeat with n = 1 to (length(pHex) - 1) step 2
      put numtochar(baseconvert(char n to n + 1 of pHex, 16, 10)) after tBin
   end repeat
   return tBin
end hexToBin

-----

function bitsToHex pBits
   repeat with n = 1 to length(pBits)-4 step 4
      put baseconvert(char n to n + 3 of pBits,2,16) after tHexString
   end repeat
   return tolower(tHexString)
end bitsToHex

-----

function hexToBits pHex
   put length(pHex) * 4 into tBitLength
   if tBitLength > 32 then
      repeat for each char c in pHex
         put baseconvert(c,16,2) into tb
         repeat 4 - length(tb)
            put 0 before tb
         end repeat
         put tb after tBits
      end repeat
   else
      put baseconvert(pHex,16,2) into tBits
      repeat tBitLength - length(tBits)
         put 0 before tBits
      end repeat
   end if
   return tBits
end hexToBits

----------------
--> integers

function getUIntListBE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getUIntBE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getUIntListBE

function getIntListBE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getIntBE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getIntListBE

function getUIntListLE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getUIntLE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getUIntListLE

function getIntListLE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getIntLE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getIntListLE

-----

function getIntBE pBytes
   local tNum
   switch length(pBytes)
      case 1
         get binarydecode("c", pBytes, tNum)
         break
      case 2
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("s", pBytes, tNum)
         break
      case 3
         put null after pBytes
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("i", pBytes, tNum)
         put tNum div 256 into tNum
         break
      case 4
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("i", pBytes, tNum)
         break
      default
         return getBigInt(pBytes)
         break
   end switch
   
   return tNum
end getIntBE

function getUIntBE pBytes
   local tNum
   switch length(pBytes)
      case 1
         get binarydecode("C", pBytes, tNum)
         break
      case 2
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("S", pBytes, tNum)
         break
      case 3
         put null before pBytes -- falls through to 4
      case 4
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("I", pBytes, tNum)
         break
      default
         return getBigUint(pBytes)
         break
   end switch
   
   return tNum
end getUIntBE



function getIntLE pBytes
   local tNum
   switch length(pBytes)
      case 1
         get binarydecode("c", pBytes, tNum)
         break
      case 2
         if sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("s", pBytes, tNum)
         break
      case 3
         put null before pBytes
         if sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("i", pBytes, tNum)
         put tNum div 256 into tNum
         break
      case 4
         if sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("i", pBytes, tNum)
         break
      default
         return getBigInt(reverseBytes(pBytes))
         break
   end switch
   
   return tNum
end getIntLE

function getUIntLE pBytes
   local tNum
   switch length(pBytes)
      case 1
         get binarydecode("C", pBytes, tNum)
         break
      case 2
         if  sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("S", pBytes, tNum)
         break
      case 3
         put null after pBytes -- falls through to 4
      case 4
         if  sBigEndian then put reverseBytes(pBytes) into pBytes
         get binarydecode("I", pBytes, tNum)
         break
      default
         return getBigUint(reverseBytes(pBytes))
         break
   end switch
   
   return tNum
end getUIntLE

----

function getBigUint pBytes
   local tBits
   get binarydecode("B*", pBytes, tBits)
   
   put length(tBits) into tPow
   repeat for each char c in tBits
      subtract 1 from tPow
      add c * (2 ^ tPow) to tot
   end repeat
   
   return tot
end getBigUint

function getBigInt pBytes
   local tBits
   get binarydecode("B*", pBytes, tBits)
   
   put char 1 of tBits into sign
   put length(tBits) into tPow
   repeat for each char c in tBits
      subtract 1 from tPow
      add (c - sign) * (2 ^ tPow) to tot
   end repeat
   return tot - sign
end getBigInt


-----------------------------------------------------------------------

function toUInt1 pNum
   return binaryencode("C", pNum)
end toUInt1

function toInt1 pNum
   return binaryencode("c", pNum)
end toInt1

-----

function toUint2LE pNum
   put binaryencode(S, pNum) into binNum
   if sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toUint2LE

function toInt2LE pNum
   put binaryencode(s, pNum) into binNum
   if sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toInt2LE

-----

function toUint3LE pNum
   put binaryencode(I, pNum * 256) into binNum
   if sBigEndian then
      return reverseBytes(char 1 to 3 of binNum)
   else
      return char 2 to 4 of binNum
   end if
end toUint3LE

function toInt3LE pNum
   put binaryencode(i, pNum * 256) into binNum
   if sBigEndian then
      return reverseBytes(char 1 to 3 of binNum)
   else
      return char 2 to 4 of binNum
   end if
end toInt3LE

-----

function toUint4LE pNum
   put binaryencode("I", pNum) into binNum
   if sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toUint4LE

function toInt4LE pNum
   put binaryencode("i", pNum) into binNum
   if sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toInt4LE

-----

function toUInt2BE pNum
   put binaryencode(S, pNum) into binNum
   if not sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toUInt2BE

function toInt2BE pNum
   put binaryencode(s, pNum) into binNum
   if not sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toInt2BE

-----

function toUint3BE pNum
   put binaryencode(I, pNum * 256) into binNum
   if not sBigEndian then
      return reverseBytes(char 2 to 4 of binNum)
   else
      return char 1 to 3 of binNum
   end if
end toUint3BE

function toInt3BE pNum
   put binaryencode(i, pNum * 256) into binNum
   if not sBigEndian then
      return reverseBytes(char 2 to 4 of binNum)
   else
      return char 1 to 3 of binNum
   end if
end toInt3BE

-----

function toUInt4BE pNum
   put binaryencode(I, pNum) into binNum
   if not sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toUInt4BE

function toInt4BE pNum
   put binaryencode(i, pNum) into binNum
   if not sBigEndian then
      return reverseBytes(binNum)
   else
      return binNum
   end if
end toInt4BE

----

function toBigUIntBE pNum, pSize
   if pSize is empty then put 8 into pSize
   put pSize * 8 into numBits
   repeat with n = numBits - 1 down to 0
      put 2 ^ n into tPow
      if pNum div tPow > 0 then
         put 1 after tBits
         subtract tPow from pNum
      else
         put 0 after tBits
      end if
   end repeat
   return binaryencode("B*",tBits)
end toBigUIntBE

function toBigUIntLE pNum, pSize
   return reverseBytes(toBigUIntBE(pNum, pSize))
end toBigUIntLE

function toBigIntBE pNum, pSize
   if pSize is empty then put 8 into pSize
   put pSize * 8 into numBits
   
   if pNum < 0 then
      put  1 into scrag
   else
      put 0 into scrag
   end if
   
   put abs(pNum) - scrag into pNum
   repeat with n = numBits - 1 down to 0
      put 2 ^ n into tPow
      if pNum div tPow > 0 then
         put 1 - scrag after tBits
         subtract tPow from pNum
      else
         put 0 + scrag after tBits
      end if
   end repeat
   
   return binaryencode("B*",tBits)
end toBigIntBE

function toBigIntLE pNum, pSize
   return reverseBytes(toBigIntBE(pNum, pSize))
end toBigIntLE

-----------------------------------------------------------------------
--> floats

function getFloatListLE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getFloatLE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getFloatListLE

function getFloatListBE pData, pSize, pDelim
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put getFloatBE(char n to n + (pSize - 1) of pData) & pDelim after numList
   end repeat
   return char 1 to -2 of numList
end getFloatListBE

-----

function getFloatLE pBytes
   local tNum
   if sBigEndian then put reverseBytes(pBytes) into pBytes
   
   switch length(pBytes)
      case 4
         put "f" into bdc
         break
      case 8
         put "d" into bdc
         break
      case 10
         put "d" into bdc
         put ieeeExtendedToDouble(pBytes) into pBytes
         if sBigEndian then put reverseBytes(pBytes) into pBytes
         break
      default
         return empty
         break
   end switch
   
   get binarydecode(bdc, pBytes, tNum)
   return tNum
end getFloatLE

-----

function getFloatBE pBytes
   local tNum
   if not sBigEndian then put reverseBytes(pBytes) into pBytes
   
   switch length(pBytes)
      case 4
         put "f" into bdc
         break
      case 8
         put "d" into bdc
         break
      case 10
         put "d" into bdc
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         put ieeeExtendedToDouble(pBytes) into pBytes
         if not sBigEndian then put reverseBytes(pBytes) into pBytes
         break
      default
         return empty
         break
   end switch
   
   get binarydecode(bdc, pBytes, tNum)
   return tNum
end getFloatBE

-----

function toFloat4LE pNum
   put binaryencode("f", pNum) into tFloat
   if sBigEndian then return reverseBytes(tFloat)
   return tFloat
end toFloat4LE

function toFloat4BE pNum
   put binaryencode("f", pNum) into tFloat
   if not sBigEndian then return reverseBytes(tFloat)
   return tFloat
end toFloat4BE

-----

function toFloat8LE pNum
   put binaryencode("d", pNum) into tFloat
   if sBigEndian then return reverseBytes(tFloat)
   return tFloat
end toFloat8LE

function toFloat8BE pNum
   put binaryencode("d", pNum) into tFloat
   if not sBigEndian then return reverseBytes(tFloat)
   return tFloat
end toFloat8BE

-----

function toFloat10LE pNum
   put binaryencode("d", pNum) into tDouble
   if sBigEndian then put reverseBytes(tDouble) into tDouble
   put ieeeDoubleToExtended(tDouble) into tExtended
   if sBigEndian then return reverseBytes(tExtended)
   return tExtended
end toFloat10LE

function toFloat10BE pNum
   put binaryencode("d", pNum) into tDouble
   if not sBigEndian then put reverseBytes(tDouble) into tDouble
   put ieeeDoubleToExtended(tDouble) into tExtended
   return tExtended
end toFloat10BE

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------



-- These came from Mark Waddingham at RunRev, as I'm too thick to have done them myself.

-- Take a sequence of 10-bytes encoding an extended number, and return
-- a sequence of 8-bytes encoding a double number
function ieeeExtendedToDouble pExtended
   local tExtendedSign, tExtendedExponent, tExtendedMantissa, tExtendedBits
   local tDoubleExponent, tDoubleMantissa, tDoubleBits
   
   if the length of pExtended is not 10 then
      throw "ieeeerr,Extended number must be 10 bytes long"
   end if
   
   -- Step 1: Split the extended number up
   get binarydecode("B80", pExtended, tExtendedBits)
   put char 1 of tExtendedBits into tExtendedSign
   put char 2 to 16 of tExtendedBits into tExtendedExponent
   put char 17 to 80 of tExtendedBits into tExtendedMantissa
   
   -- Step 2: Truncate the fields
   
   -- The exponent is the trickiest because it is stored as a number relative to
   -- the smallest possible exponent which in the case of an extended number is
   -- -16383.
   -- Therefore, we take the following steps:
   --   . Make sure we have 16-binary digits
   --   . Encode as two binary bytes
   --   . Decode as a 2-byte integer, most-significant byte first (network byte-order)
   --   . Adjust and clamp to the double exponent range
   local tNumericExponent
   get binarydecode("n", binaryencode("B16", "0" & tExtendedExponent), tNumericExponent)
   subtract 16383 from tNumericExponent
   put max(min(tNumericExponent, 2046), -2046) into tNumericExponent
   
   -- IEEE Doubles actually have a normalization requirement for representation.
   -- The Mantissa is taken to be 1.F where F is the binary fraction encoded in the
   -- number. This seems subtly different from the extended format, which has no
   -- such requirement (it appears). Therefore, we have to find the leading '1' in the
   -- extended mantissa and adjust the exponent accordingly.
   -- Of course, if there is no leading 1, then the number is 0
   local tLeadingOne
   
   -- Find the leading one, and return zero if there is none
   put offset("1", tExtendedMantissa) into tLeadingOne
   if tLeadingOne is 0 then
      return 0
   end if
   
   -- Extract 52-bits for the mantissa, and pad with zeros if we don't have enough
   put char tLeadingOne + 1 to tLeadingOne + 1 + 52 of tExtendedMantissa into tDoubleMantissa
   repeat while the length of tDoubleMantissa < 52
      put "0" after tDoubleMantissa
   end repeat
   
   -- Adjust the exponent
   subtract tLeadingOne - 1 from tDoubleExponent
   
   -- Finish encoding the exponent
   get binarydecode("B16", binaryencode("n", 1023 + tNumericExponent), tDoubleExponent)
   put char 6 to 16 of tDoubleExponent into tDoubleExponent
   
   -- Now reconstruct the double as bits
   put tExtendedSign & tDoubleExponent & tDoubleMantissa into tDoubleBits
   
   -- And perform the final encoding
   return binaryencode("B64", tDoubleBits)
end ieeeExtendedToDouble

-- Take a sequence of 8 bytes encoding a double number, and return a
-- sequence of 10-bytes encoding an extended number
function ieeeDoubleToExtended pDouble
   local tSign, tExtendedExponent, tExtendedMantissa, tExtendedBits
   local tDoubleExponent, tDoubleMantissa, tDoubleBits
   
   if the length of pDouble is not 8 then
      throw "ieeeerr,Double number must be 8 bytes long"
   end if
   
   get binarydecode("B64", pDouble, tDoubleBits)
   put char 1 of tDoubleBits into tSign
   put char 2 to 12 of tDoubleBits into tDoubleExponent
   put char 13 to 64 of tDoubleBits into tDoubleMantissa
   
   local tNumericExponent
   get binarydecode("n", binaryencode("B16", "00000" & tDoubleExponent), tNumericExponent)
   if tNumericExponent is 0 then
      put 0 into tNumericExponent
      put tDoubleMantissa into tExtendedMantissa
   else
      add 16383 - 1023 to tNumericExponent
      put "1" & tDoubleMantissa into tExtendedMantissa
   end if
   
   repeat while the length of tExtendedMantissa < 64
      put "0" after tExtendedMantissa
   end repeat
   
   get binarydecode("B16", binaryencode("n", tNumericExponent), tExtendedExponent)
   put char 2 to 16 of tExtendedExponent into tExtendedExponent
   
   put tSign & tExtendedExponent & tExtendedMantissa into tExtendedBits
   
   return binaryencode("B80", tExtendedBits)
end ieeeDoubleToExtended

------------

