Script "stack_libBinConvert_"

/*
# Name: stack "libBinConvert"
# ID: stack "libBinConvert"
*/


-----------------------------------------------------------------

/*
libBinConvert
version: 1.1
date: January 2008
author: Mark Smith
*/
-----------------------------------------------------------------

local sBigEndian

--> all handlers

on libraryStack
  initLibBin
end libraryStack


on initLibBin
  setEndian
end initLibBin

-----

on setEndian
  put (char 1 of (binaryencode("I",1)) is null) into sBigEndian
end setEndian

function getEndianness
  if sBigEndian then
    return "big"
  else
    return "little"
  end if
end getEndianness

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
