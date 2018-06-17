Script "stack_libUUID_"

/*
# Name: stack "libUUID"
# ID: stack "libUUID"
*/


--> all handlers

/******************************************************************

# libUUID 0.9 (for Revolution pre 2.7)
# author: Mark Smith
# © Mark Smith 2007
# EULA: http://opensource.org/licenses/osl-3.0.php
#
# Public handlers
# on luiSetTrueRandom--
#  inputs :  true|false
#  if true, tells the library to fetch any needed random 
#  numbers from random.org, if false, generates them internally.
#
# function luiGetTueRandom()
#  inputs : none
#  Returns the current status as set above
#
# function luiTimeUUID()
#  inputs : pSecureNode true|false
#  if true, use a random-based number for the last part of the
#  UUID, instead of the hosts MAC address.
#  Returns a type 1 (time based) UUID
#
# function luiNameUUID()
#  Returns a type 3 (name based) UUID
#
# function luiRandomUUID()
#  inputs : none
#  Returns a type 4 (random based) UUID
#	# 
# function luiExtractTime()
#  inputs : a type 1 UUID
#  Returns the time at which the input was generated

*******************************************************************/

local sTrueRandom
local sNamespaces
constant kRFCtimeOffset = 122192928000000000


------------------------
------------------------

on libraryStack
  initLibrary
end libraryStack

on initLibrary
  checkState
  loadNamespaces
end initLibrary


------------------------
------------------------
--> interface

on luiSetTrueRandom tf
  if tf is "true" OR tf is "false" then
    put tf into sTrueRandom
  else
    put false into sTrueRandom
  end if
end luiSetTrueRandom

function luiGetTrueRandom
  if sTrueRandom is empty then return false
  return sTrueRandom
end luiGetTrueRandom

------------------------
------------------------

function luiRandomUUID
  put randomHexChars(15) into tTimeStamp
  put bitsToHex("10" & randomBits(14)) into tClockSeq
  put randomHexChars(12) into tNode
   
  return buildUUID(tTimeStamp, tClockSeq, tNode, "4")
end luiRandomUUID

------------------------
------------------------

function luiTimeUUID pSecureNode
  if pSecureNode is empty then put false into pSecureNode
  
  put getTimeStamp() into tTimeStamp
  put getClockSeq() into tRawCS
  put bitsToHex("10" & tRawCS) into tClockSeq
  if pSecureNode then
    put getSecureNode() into tNode
  else
    put getNode() into tNode
  end if
  
  saveState baseConvert(tRawCS,2,10)
  
  return buildUUID(tTimeStamp, tClockSeq, tNode, "1")
end luiTimeUUID

------------------------
------------------------

function luiNameUUID pNamespace, pName, pDigest
  if pNamespace is empty then return "no namespace provided"
  if pName is empty then return "no name provided"
  if pDigest is empty then put "md5" into pDigest
  
  if pNamespace is "random" then
    put luiRandomUUID() into tNsUUID
  else
    if pNamespace is not among the lines of luiGetNamespaces() then
      addNamespace pNamespace
      put luiTimeUUID() into sNamespaces[pNamespace]
    end if
    put sNamespaces[pNamespace] into tNsUUID
  end if
  replace "-" with empty in tNsUUID
  
  repeat for each char c in tNsUUID
    put hexToBits(c) after tBits
  end repeat
   
  put binaryEncode("B128",tBits) into tUUIDstring
  
  put md5Digest(tUUIDstring & pName) into tDigest
  put charToNum(char 7 of tDigest) bitAnd 15 into tVers
  put tVers bitOr 48 into tVers
  put numToChar(tVers) into  char 7 of tDigest
  
  put charToNum(char 9 of tDigest) bitAnd 63 into tVar
  put tVar bitOr 128 into tVar
  put numToChar(tVar) into char 9 of tDigest
  
  put empty into tBits
  get binaryDecode("B128",tDigest,tBits)
  
  put bitsToHex(tBits) into tUUID
  
  repeat with c = 8 to 23 step 5
    put "-" after char c of tUUID
  end repeat
   
  return toLower(tUUID)
end luiNameUUID

------------------------
------------------------

function luiExtractTime pUUID
  if char 15 of pUUID is not "1" then return "not a time-based uuid"
  
  replace "-" with empty in pUUID
  put char 14 to 16 of pUUID into tu
  put char 9 to 12 of pUUID after tu
  put char 1 to 8 of pUUID after tu
  
  put bitsToDec(hexToBits(tu)) into tNum
  subtract kRFCtimeOffset from tNum
  divide tNum by 10000000
  convert tNum from seconds to long system date and long time
  return tNum
end luiExtractTime

-----

function luiGetNamespaces
  put the keys of sNamespaces into tNS
  sort lines of tNS
  return tNS
end luiGetNamespaces

------------------------
------------------------
--> makeUUId

function buildUUID pTimeStamp, pClockSeq, pNode, pType
  put char 8 to 15 of pTimeStamp & "-" into tUUID
  put char 4 to 7 of pTimeStamp & "-" after tUUID
  put pType & char 1 to 3 of pTimeStamp & "-" after tUUID 
  put pClockSeq & "-" after tUUID
  put pNode after tUUID
   
  return toLower(tUUID)
end buildUUID

------------------------

function getTimeStamp
  put (the millisecs * 10000) + kRFCtimeOffset into tSixty
  put bitsToHex(decToBits(tSixty, 60)) into tTimeStamp
  return tTimeStamp
end getTimeStamp

------------------------
------------------------
--> clockSequence

function getClockSeq
  put 2^14 - 1 into tMaxSeq
  
  put getPreviousState() into tState
  if tState is not "no state" then
    put tState["clockSeq"] + 1 into tClockSeq
  else
    put newClockseq() into tClockSeq
  end if
  
  if tClockSeq >= tMaxSeq then put newClockseq() into tClockSeq
  saveState tClockSeq
  
  return decToBits(tClockSeq,14)
end getClockSeq

function newClockseq
  return baseConvert(randomBits(14),2,10)
end newClockseq

------------------------
------------------------

-- the mac address. if not available uses a random number.

function getNode
  put GetMACAddress() into mNode
  if "error" is not in mNode then
    repeat for each char c in mNode
      if c is in "1234567890abcdef" then put c after tNode
    end repeat
  else
    put getSecureNode() into tNode
  end if
  return tNode
end getNode

------------------------

-- uses some local info and hashes it, and uses six arbitary bytes from the hash,
-- as suggested in rfc1422

function getSecureNode
  put empty into tBits
  put the systemVersion & the version & the buildNumber into tString
  put md5Digest(tString) into tBin
  
  put random(11) into tStartChar
  put char tStartChar to tStartChar + 5 of tBin into tBinNode
  
  get binaryDecode("B48",tBinNode,tBits)
  put 1 into char -1 of tBits -- set the multicast bit
  
  return bitsToHex(tBits)
end getSecureNode

------------------------
------------------------

-- We save the current time in ms., the passed in clockSeq and the local MAC address.
-- Then, if the system clock gets reset to an earlier time, or the MAC address changes, 
-- we can reset the clockSeq to maintain a high probability of uniqueness in our time based UUIDs.
-- NB. Not quite the rfc1422 spec, but I'm using the millisecs, since that's our actual resolution, 
-- even though the actual timestamps are in 100 nanosecond intervals since 1583, as per the spec.

on saveState pClockSeq
  put specialFolderPath("Preferences") & "/libuuidstate" into fName
  put "timestamp=" & the millisecs & cr into tState
  put "clockseq=" & pClockSeq & cr after tState
  put "node=" & getNode() after tState
  put tState into URL ("file:" & fName)
end saveState

function getPreviousState
  put specialFolderPath("Preferences") & "/libuuidstate" into fName
  if there is a file fName then
    put URL ("file:" & fName) into tState
    split tState by cr and "="
    return tState
  else
     return "no state"
  end if
end getPreviousState

on checkState
  put getPreviousState() into tState
  if tState is "no state" then
    saveState newClockseq()
  else
    if tState["timestamp"] >= the millisecs OR tState["node"] <> getNode() then
      saveState newClockseq()
    end if
  end if
end checkState

------------------------
------------------------
--> nameSpaces

on loadNamespaces
  put specialFolderPath("Preferences") & "/libuuidnamespaces" into fName
  if there is a file fName then
    put URL ("file:" & fName) into tNamespaces
    split tNamespaces by cr and "="
    put tNamespaces into sNamespaces
  else
    put "6ba7b811-9dad-11d1-80b4-00c04fd430c8" into sNamespaces["URL"]
    put "6ba7b810-9dad-11d1-80b4-00c04fd430c8" into sNamespaces["DNS"]
    put "6ba7b812-9dad-11d1-80b4-00c04fd430c8" into sNamespaces["OID"]
    put "6ba7b814-9dad-11d1-80b4-00c04fd430c8" into sNamespaces["X500"]
    put "1493d859-97ad-32c5-b868-e2c39a26a3bf" into sNamespaces["TIT"]
    saveNamespaces
  end if
end loadNamespaces

on saveNamespaces
  put sNamespaces into tNamespaces
  combine tNamespaces by cr and "="
  put specialFolderPath("Preferences") & "/libuuidnamespaces" into fName
  put tNamespaces into URL ("file:" & fName)
end saveNamespaces

on addNamespace pNamespace
  put luiTimeUUID() into sNamespaces[pNamespace]
  saveNamespaces
end addNamespace



----------------------------------
----------------------------------
--> bitsHexBinDec

function bitsToHex pBits
  repeat with n = 1 to length(pBits)-4 step 4
    put baseConvert(char n to n + 3 of pBits,2,16) after tHexString
  end repeat
  return toLower(tHexString)
end bitsToHex

function bitsToBin pBits
  repeat with n = 1 to length(pBits) - 8 step 8
    put char n to n + 7 of pBits into tNum
    put binaryEncode("B8",tNum) after tBin
  end repeat
  return tBin
end bitsToBin

function bitsToDec pBits
  if length(pBits) > 32 then 
    put length(pBits) into tLen
    repeat for each char c in pBits
      subtract 1 from tLen
      if c = 1 then add 2 ^ tLen to tDecNum
    end repeat
  else
    return baseConvert(pBits,2,10)
  end if
  return tDecNum
end bitsToDec

------------------------

function hexToBits pHex
  put length(pHex) * 4 into tBitLength
  if tBitLength > 32 then
    repeat for each char c in pHex
      put baseConvert(c,16,2) into tb
      repeat 4 - length(tb)
        put 0 before tb
      end repeat
      put tb after tBits
    end repeat
  else
    put baseConvert(pHex,16,2) into tBits
    repeat tBitLength - length(tBits)
      put 0 before tBits
    end repeat
  end if
  return tBits
end hexToBits


function hexToDec pHex
  if length(pHex) > 8 then
    put length(pHex) into tLen
    repeat for each char c in pHex
      subtract 1 from tLen
      put baseConvert(c,16,10) into tNum
      add tNum * (16 ^ tLen) to tDecNum
    end repeat
  else
    put baseConvert(pHex,16,10) into tDecNum
  end if
  return tDecNum
end hexToDec


function hexToBin pHex
  repeat with n = 1 to length(pHex) - 2 step 2
    put numToChar(baseConvert(char n to n+1 of pHex,16,10)) after tString
  end repeat
  return tString
end hexToBin

------------------------
------------------------

function decToBits pNum, pNumBits
  if pNumBits is empty then put 32 into pNumBits
  if pNum < 0 then put (2 ^ pNumBits - 1) + pNum into pNum
  if pNum < 2 ^ 32 then 
    put baseConvert(pNum,10,2) into tBits
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
   
  if pNumBits > length(tBits) then
    repeat pNumBits - length(tBits)
      put 0 before tBits
    end repeat
  end if
   
  return tBits
end decToBits


function decToHex pDec, pNumDigits
  if pDec < 2 ^ 32 then
    put baseConvert(pDec,10,16) into tHex
  else
    repeat while pDec >= 1
      put pDec mod 16 into tNum
      put baseConvert(tNum,10,16) before tHex
      put pDec div 16 into pDec
    end repeat
  end if
  
  if pNumDigits is not empty AND pNumDigits > length(tHex) then
    repeat pNumDigits - length(tHex)
      put 0 before thex
    end repeat
  end if
  
  return toLower(tHex)
end decToHex



------------------------
------------------------
--> randomOrg	

function randomBits pNumBits
  if luiGetTrueRandom() then
    put (pNumBits div 8) + 1 into howMany
    
    put randomOrgBytes(howMany,"b") into tBits
    
    if tBits is not empty then
      delete char pNumBits + 1 to -1 of tBits
      return tBits
    end if
  end if
  
  repeat pNumBits
    put random(2) - 1 after tBits
  end repeat
  
  return tBits
end randomBits

------------------------

function randomHexChars pHowMany
  if luiGetTrueRandom() then
    put (pHowMany  div 2) + 1 into howMany
    put randomOrgBytes(howMany,"h") into tHexChars
    if tHexChars is not empty then
      delete char pHowMany + 1 to -1 of tHexChars
      return tHexChars
    end if
  end if
  
  repeat pHowMany
    put baseConvert(random(16) - 1,10,16) after tHexChars
  end repeat
  
  return tHexChars
end randomHexChars

------------------------
------------------------

function randomOrgBytes howMany,tFormat
  -- set defaults if parameters are not given
  if not isNumber(howMany) then put 1 into howMany
  if tFormat is not among the items of "f,h,d,o,b" then put "f" into tFormat
  
  -- check the level of the servers buffer
  -- if below 20% then return empty
  put URL "http://www.random.org/cgi-bin/checkbuf" into bufferLevel
  replace "%" with empty in bufferLevel
  if not isNumber(bufferLevel) OR bufferLevel < 20 then return empty
  
  -- create the URL request
  put "http://www.random.org/cgi-bin/randbyte?nbytes=HOWMANY&format=WHATFORMAT" into tURL
  replace "HOWMANY" with howMany in tURL
  replace "WHATFORMAT" with tFormat in tURL
  set the httpHeaders to "User-Agent: mark@maseurope.net"
  put URL tURL into tBytes
  replace space with empty in tBytes
  replace cr with empty in tBytes
  return tBytes
end randomOrgBytes

------------------------
------------------------
--> MacAddress

-- from the excellent Ken Ray

function GetMACAddress
  local retVal
  switch (the platform)
  case "MacOS"
    set the itemDel to "."
    if item 1 of the systemVersion < 10 then
      set the directory to specialFolderPath("apple")
      put "tell application" && quote & "Apple System Profiler" & \
        quote & cr & "get appletalk address" & cr & "end tell" into getMACScript
      put "tell application" && quote & "Apple System Profiler" & \
        quote & cr & "close window" && quote & "Apple System Profiler" & quote & \
        cr & "end tell" into quitASPScript
      do getMACScript as AppleScript
      put the result into retVal
      do quitASPScript as AppleScript
      replace "{" with "" in retVal
      replace "}" with "" in retVal
      replace quote with "" in retVal
    else
      put shell("/sbin/ifconfig en0") into ifConfigs
      if char 1 to 4 of ifConfigs = "zsh:" then
        return "Error retrieving interface configuration."
      else
        get matchText(ifconfigs,"(?s)ether (.*?) ",retVal)  -- These are spaces on either side of (.*?)
        if it is false then
          return "Error retrieving MAC address."
        end if
      end if
    end if
    break
  case "Win32"
    put (there is a file (specialFolderPath("system") & "/IPCONFIG.EXE")) into winExists
    put (there is a file (specialFolderPath("system") & "/SYSTEM32/IPCONFIG.EXE")) into sys32Exists
    if winExists or sys32Exists then
      set the hideConsoleWindows to true
      put shell("ipconfig /all") into temp
      get matchText(temp,"Physical Address[\. ]*: ([A-Z0-9-]*)",retVal)
    else
      return "IPCONFIG not found"
    end if
    break
  case "Linux"
    if there is a file("/sbin/ifconfig") then
      put shell("/sbin/ifconfig") into temp
      get matchText(temp,"HWaddr[* ]([0-9A-Z:]*)",retVal)
    else
      return "An error has occured."
    end if
    break
  end switch
  return retVal
end GetMACAddress
