Script "stack_libHash-Hmac_"

/*
# Name: stack "libHash-Hmac"
# ID: stack "libHash-Hmac"
*/


# libHash-Hmac
# version 2.3
# September 2009
# v2.3 added crc 16, 16ccitt, 32 functions
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
      put "1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748," & \
            "2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206," & \
            "2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983," & \
            "1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671," & \
            "3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291," & \
            "1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771," & \
            "3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877," & \
            "958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452," & \
            "2361852424,2428436474,2756734187,3204031479,3329325298" into tConsts
       
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
   if the number of lines in keys(w) <> 16 then
      put showArray(w)
      exit to top
   end if
   
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
--> FNV hashes

function fnv132.hex pInput
   return binToHex(fnv132(pInput))
end fnv132.hex

function fnv132.bin pInput
   return fnv132(pInput)
end fnv132.bin

function fnv132.b64 pInput
   return base64encode(fnv132(pInput))
end fnv132.b64

function fnv1a32.hex pInput
   return binToHex(fnv1a32(pInput))
end fnv1a32.hex

function fnv1a32.bin pInput
   return fnv1a32(pInput)
end fnv1a32.bin

function fnv1a32.b64 pInput
   return base64encode(fnv1a32(pInput))
end fnv1a32.b64


private function fnv132 pString
   put 2166136261 into tDigest
   
   repeat for each byte b in pString
      put bytetonum(b) into tByte
      put (tDigest * 16777619) into tDigest
      if tDigest > 4294967295 then put tDigest mod 4294967296 - 1 into tDigest
      put tDigest bitXor tByte into tDigest
   end repeat
   return binaryencode("N", tDigest)
end fnv132

private function fnv1a32 pString
   put 2166136261 into tDigest
   
   repeat for each byte b in pString
      put mod32((tDigest bitXor bytetonum(b)) * 16777619) into tDigest
      --put (tDigest * 16777619) mod 4294967296 - 1 into tDigest
   end repeat
   return binaryencode("N", tDigest)
end fnv1a32

function fnv032 pStr
   put 0 into tDigest
   repeat for each byte b in pStr
      put (tDigest * 16777619) mod 4294967296 - 1 into tDigest
      put tDigest bitXor bytetonum(b) into tDigest
   end repeat
   return tDigest
end fnv032

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--> crc

constant kCrc_32Poly = 3988292384 -- (0xEDB88320 bitreflected 0x04C11DB7)
constant kCrc_ccittPoly = 4129 -- (0x1021)
constant kCrc_16Poly = 40961 -- (0xA001 bitreflected 0x8005)
constant kCrc_kermitPoly = 33800 -- (0x8408)
constant kCrc_dnpPoly = 42684 -- (0xA6BC)
constant kCrc_ibmPoly = 32773 -- (0x8005)

constant kCrc_32StartVal = 4294967295 -- (0xFFFFFFFF)
constant kCrc_16StartVal = 0
constant kCrc_ccittStartVal = 65535 --(0xFFFF)
constant kCrc_ccittStartValB = 7439 --(0x1D0F)

constant kCrc_32xorVal = 4294967295 -- (0xFFFFFFFF)

local sCrcTable

function bitreflect pNum, pWidth
   put "%0" & pWidth & "s" into tFormatString
   put format(tFormatString, baseconvert(pNum, 10, 2)) into tNum
   repeat for each char c in tNum
      put c before nNum
   end repeat
   return baseconvert(nNum, 2, 10)
end bitreflect

---------------------------------------------------------------------
-- the 32 bit crc checksum as used in ethernet, pkzip etc.
-- using the reflected poynomial 0xEDB88320 (0x04c11db7 unreflected)
-- initialising with 0xffffffff and xoring with 0xffffffff at the end

function crc32.bin pData
   put crc.32(pData) into tCrc
   return binaryencode("M", tCrc)
end crc32.bin

function crc32.hex pData
   put crc.32(pData) into tCrc
   return format("%08s", baseconvert(tCrc, 10, 16))
end crc32.hex

function crc32.dec pData
   return crc.32(pData)
end crc32.dec

function filecrc32.bin pFile
   put fileCrc.32(pFile) into tCrc
   return binaryencode("M", tCrc)
end filecrc32.bin
   
function filecrc32.hex pFile
   put fileCrc.32(pFile) into tCrc
   return format("%08s", baseconvert(tCrc, 10, 16))
end filecrc32.hex

function filecrc32.dec pFile
   return fileCrc.32(pFile)
end filecrc32.dec

-----

private function crc.32 @pData
   if sCrctable["crc"] is not "crc32" then makecrc32table kCrc_32Poly
   put kCrc_32StartVal into tCrc
   
   repeat for each byte b in pData
      put bytetonum(b) bitXor tCrc bitand 255 into tIndex
      put (tCrc div 256) bitxor sCrctable[tIndex] into tCrc
   end repeat
   return tCrc bitxor kCrc_32xorVal
end crc.32

-----

private function fileCrc.32 pFile
   if there is not file pFile then return "no file..."
   if sCrctable["crc"] is not "crc32" then makecrc32table kCrc_32Poly
   put kCrc_32StartVal into tCrc
   
   put false into fileDone
   open file pFile for binary read
   repeat until fileDone
      read from file pFile for 4096
      put it into tData
      put (the result is "eof") into fileDone
      
      repeat for each byte b in tData
         put bytetonum(b) bitXor TCrc bitand 255 into tIndex
         put (tCrc div 256) bitxor sCrctable[tIndex] into tCrc
      end repeat
      
   end repeat
   close file pFile
   return tCrc bitxor 4294967295
end fileCrc.32

-----

private command makecrc32table pPoly
   put empty into sCrcTable
   repeat with i = 0 to 255
      put i into c
      repeat 8
         if (c bitand 1) <> 0 then
            put (c div 2) bitXor pPoly into c
         else
            put c div 2 into c
         end if
      end repeat
      put c into sCrctable[i]
   end repeat
   put "crc32" into sCrctable["crc"]
end makecrc32table

--------------------------------------------------
-- the 16 bit crc checksum as defined by the ccitt
-- using the poynomial 0x1021
-- initialising with 0xffff 

function crc16ccitt.bin pData
   put crc.ccitt(pData) into tCrc
   return binaryencode("m", tCrc)
end crc16ccitt.bin

function crc16ccitt.hex pData
   put crc.ccitt(pData) into tCrc
   return format("%04s",baseconvert(tCrc, 10, 16))
end crc16ccitt.hex

function crc16ccitt.dec pData
   return crc.ccitt(pData)
end crc16ccitt.dec

function filecrc16ccitt.bin pFile
   put fileCrc.ccitt(pFile) into tCrc
   return binaryencode("m", tCrc)
end filecrc16ccitt.bin
   
function filecrc16ccitt.hex pFile
   put fileCrc.ccitt(pFile) into tCrc
   return format("%04s", baseconvert(tCrc, 10, 16))
end filecrc16ccitt.hex

function filecrc16ccitt.dec pFile
   return fileCrc.ccitt(pFile)
end filecrc16ccitt.dec

-----

private function crc.ccitt pData
   if sCrcTable["crc"] is not "ccitt" then makeCcittTable 
   put kCrc_ccittStartVal into tCrc
   
   repeat for each byte b in pData
      put (tCrc div 256) bitxor (bytetonum(b) bitand 255) into tIndex
      put (tCrc * 256 mod 65536) bitxor sCrctable[tIndex] into tCrc
   end repeat
   
   return tCrc
end crc.ccitt

-----

private function fileCrc.ccitt pFile
   if there is no file pFile then return "no file..."
   if sCrctable["crc"] is not "ccitt" then makeCcittTable
   put kCrc_ccittStartVal into tCrc
   
   open file pFile for binary read
   repeat until eof
      read from file pFile for 4096
      put it into tData
      if length(tData) = 0 then exit repeat
       
      repeat for each byte b in tData
         put bytetonum(b) bitXor tCrc bitand 255 into tIndex
         put (tCrc div 256) bitxor sCrcTable[tIndex] into tCrc
      end repeat
      
   end repeat
   close file pFile
   return tCrc
end fileCrc.ccitt

-----

private command makeCcittTable
   put empty into sCrctable
   repeat with i = 0 to 255
      put 0 into crc
      put i * 256 mod 65536 into c
       
      repeat 8
         if ((crc bitxor c) bitand 32768) <> 0 then
            put (crc * 2 mod 65536) bitxor kCrc_ccittPoly into crc
         else
            put crc * 2 mod 65536 into crc
         end if
         put c * 2 mod 65536 into c
      end repeat
      put crc into sCrctable[i]
   end repeat
   put "ccitt" into sCrctable["crc"]
end makeCcittTable

-----------------------------
-- 16 bit crc

function crc16.bin pData
   put crc.16(pData) into tCrc
   return binaryencode("m", tCrc)
end crc16.bin

function crc16.hex pData
   put crc.16(pData) into tCrc
   return format("%04s",baseconvert(tCrc, 10, 16))
end crc16.hex

function crc16.dec pData
   return crc.16(pData)
end crc16.dec

function filecrc16.bin pFile
   put fileCrc.16(pFile) into tCrc
   return binaryencode("m", tCrc)
end filecrc16.bin
   
function filecrc16.hex pFile
   put fileCrc.16(pFile) into tCrc
   return format("%04s", baseconvert(tCrc, 10, 16))
end filecrc16.hex

function filecrc16.dec pFile
   return fileCrc.16(pFile)
end filecrc16.dec

-----

private function crc.16 pData
   if sCrctable["crc"] is not "crc16" then makeCrc16table
   put kCrc_16StartVal into tCrc
   
   repeat for each byte b in pData
      put (255 bitand bytetonum(b)) bitxor tCrc bitand 255 into tIndex
      put (tCrc div 256) bitxor sCrcTable[tIndex] into tCrc
   end repeat
   
   return tCrc
end crc.16

-----

private function fileCrc.16 pFile
   if there is no file pFile then return "no file..."
   if sCrctable["crc"] is not "crc16" then makeCrc16table
   put kCrc_16StartVal into tCrc
   
   open file pFile for binary read
   repeat until eof
      read from file pFile for 4096
      put it into tData
      if length(tData) = 0 then exit repeat
       
      repeat for each byte b in tData
         put bytetonum(b) into tByte
         put (255 bitand tByte) bitxor tCrc bitand 255 into tIndex
         put (tCrc div 256) bitxor sCrcTable[tIndex] into tCrc
      end repeat
      
   end repeat
   close file pFile
   return tCrc
end fileCrc.16

-----

private command makeCrc16table pPoly
   put empty into sCrcTable
   
   repeat with i = 0 to 255
      put 0 into crc
      put i into c
       
      repeat 8
         if ((crc bitxor c) bitand 1) <> 0 then
            put (crc div 2) bitxor kCrc_16Poly into crc
         else
            put crc div 2 into crc
         end if
         put c div 2 into c
      end repeat
      put crc into sCrcTable[i]
   end repeat
   put "crc16" into sCrcTable["crc"]
end makeCrc16table
 
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
--> utilities

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
   
   
   
   put format("%032s", baseconvert(pNum, 10, 2)) into bNum
   
   put byte (0 - pSteps) to -1 of bNum before bNum
   return baseconvert(byte 1 to 32 of bNum, 2, 10)
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

function mod32 pNum
   if pNum > 4294967296 then
      put pNum mod 4294967296 into r1
      if r1 = 0 then 
         put 4294967296 into r1
      end if
   else
      put pNum into r1
   end if
   return r1
end mod32

-----

private function binToHex pString
  repeat for each byte c in pString
    get bytetonum(c)
    put baseconvert(it,10,16) into tTemp
    if it < 16 then put "0" before tTemp
    put tTemp after tHex
  end repeat
  return tolower(tHex)
end binToHex

private function hexToBin pString
   repeat with n = 1 to length(pString) - 1 step 2
      put numtobyte(baseconvert(byte n to n + 1 of pString, 16, 10)) after tBin
   end repeat
   return tBin
end hexToBin

-----

private function q pStr
   return quote & pStr & quote
end q

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

-----
