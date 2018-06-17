Script "stack_libRevFreeDb_"

/*
# Name: stack "libRevFreeDb"
# ID: stack "libRevFreeDb"
*/


/*
libRevFreeDB v1.0.1b
20090925
Author: Mark Smith
*/

--> all handlers
local sRaw = false
local sCDpath
local sRawResponse
local sBaseUrl = "http://freedb.freedb.org/~cddb/cddb.cgi?"
local sHello = "futsoft+futilism.com+libRevFreeDb+1.0.1b"
local sProtocol = 1



function getCDdata pCDpath, pRaw
   put pCDpath into sCDpath
   put (pRaw is true) into sRaw
   put listCDasFiles() into tPaths
   if "error" is in tPaths then
      put tPaths into tResponse
   else
      put idcd(pCDpath) into tResponse
      if tResponse is an array then put tPaths into tResponse["cdpaths"]
   end if
   
   if not sRaw then
      return tResponse
   else
      return sRawResponse
   end if
end getCDdata

-----

private function listCDasFiles
   switch the platform
      case "MacOS"
         put listCDmac() into tArray
         break
      case "Win32"
         put listCDwin() into tArray
         break
          
      default
         break
   end switch
   return tArray
end listCDasFiles

private function listCDmac 
   put the directory into oldFo
   set the directory to sCDpath
   put the files into tFiles
   set the directory to oldFo
   filter tFiles without ".*"
   repeat for each line L in tFiles
      if not (L ends with ".aiff") then
         put "error: not an audio cd" into tArray
         exit repeat
      else
         add 1 to c
         put sCDpath & "/" & L into tArray[c]
      end if
   end repeat
   return tArray
end listCDmac

private function listCDwin
   put the directory into oldFo
   set the directory to "D:"
   put the files into tFiles
   set the directory to oldFo
    repeat for each line L in tFiles
      if not (L ends with ".cda") then
         put "error: not an audio cd" into tArray
         exit repeat
      else
         add 1 to c
         put "D:" & L into tArray[c]
      end if
   end repeat
   return tArray
end listCDwin

-----

private function idcd
   put readCDtoc() into tTocData
   if "error:" is in tTocData then return tTocData
   put makeDiscId(tTocData) into tDiscId
  
   put makeCddbQuery(tDiscId, tTocData) into tCmd
   put sBaseUrl & tCmd & "&hello=" & sHello & "&proto=" & sProtocol into tUrl
   put url tUrl into tResponse
   if the platform is "MacOS" then put isotomac(tResponse) into tResponse
   if sRaw then put tResponse into sRawResponse
   put parseCddbQuery(tResponse) into tArray
   
   
   if tArray["cddb"] is "ok" then
      delete variable tArray["nummatches"]
      put "cmd=cddb+read+" & tArray["category"] & "+" & tArray["discid"] into tCmd
      put sBaseUrl & tCmd & "&hello=" & sHello & "&proto=" & sProtocol into tUrl
      put url tUrl into tData
      if the platform is "MacOS" then put isotomac(tData) into tData
      if sRaw then
         put tData into sRawResponse
      else
         parseCddbRead tArray, tData
         put "ok" into tArray["cddb"]
      end if
   end if
   return tArray
end idcd

private function makeCddbQuery pDiscId, pTocData
   put pDiscId & "+" & pTocData["numtracks"] & "+" into tQ
   repeat with n = 1 to pTocData["numtracks"]
      put pTocData[n] & "+" after tQ
   end repeat
   put (pTocData["leadout"] - pTocData[1]) div 75 after tQ
   put "cmd=cddb+query+" & tQ into tCmd
   return tCmd
end makeCddbQuery

-----

private function parseCddbQuery pData
   switch word 1 of pData
      case "200"
         -- everything is ok
         put parseCddbQline(word 2 to -1 of pData) into tArray
         put "ok" into tArray["cddb"]
         break
      case "211"
         -- inexact match(es) - but if there's only one we use it like it's exact
         delete line 1 of pData
         delete line -1 of pData
         filter pData without empty
         if the number of lines in pData = 1 then
            put parseCddbQline(pData) into tArray
            put "ok" into tArray["cddb"]
         else
            repeat for each line L in pData
               add 1 to c
               put parseCddbQline(L) into tArray[c]
            end repeat
            put c into tArray["nummatches"]
            put "inexact matches" into tArray["cddb"]
         end if
         break
      default
         put "error: not found" into tArray
         break
   end switch
   return tArray
end parseCddbQuery

-----

private function parseCddbQline pData
   put word 1 of pData into tArray["category"]
   put word 2 of pData into tArray["discid"]
   put word 3 to -1 of pData into temp
   set the itemdelimiter to "/"
   put word 1 to -1 of item 1 of temp into tArray["artist"]
   put word 1 to -1 of item 2 of temp into tArray["album"]
   return tArray
end parseCddbQline

-----

private command parseCddbRead @pArray, pData
   replace numtobyte(13) with empty in pData
   set the itemdelimiter to "="
   repeat for each line L in pData
      if L begins with "TTITLE" then
         add 1 to trackcount
         put item 2 of L into pArray["tracks"][trackcount]
      else if L begins with "EXT" and "YEAR:" is in L then
         put word 3 of L into pArray["year"]
      end if
   end repeat
   
   return tArray
end parseCddbRead

-----

private function readCDtoc
   switch the platform
      case "MacOS"
         put readTocMac() into tOffs
         break
      case "Win32"
         put readTocWin() into tOffs
         break
      default
         put "error:" && the platform && "not yet supported" into tOffs
         break
   end switch
   return tOffs
end readCDtoc

-----

private function readTocMac
   put sCDpath & "/.TOC.plist" into tFile
   if there is no file tFile then return "error: can't read cd TOC"
   put url ("file:" & tFile) into tPlist
  
   put 0 into tNum
   put 0 into pNum
   repeat
      add lineoffset("Last Track", tPlist, tNum) to tNum
      if tNum = pNum then
         exit repeat
      else
         put tNum into pNum
      end if
   end repeat
   if tNum > 0 then put getNodeContents(line tNum + 1 of tPlist) into tArray["numtracks"]
    
   put 0 into tNum
   put 0 into pNum
   repeat
      add lineoffset("Leadout Block", tPlist, tNum) to tNum
      if tNum = pNum then
         exit repeat
      else
         put tNum into pNum
      end if
   end repeat
   if tNum > 0 then put getNodeContents(line tNum + 1 of tPlist) into tArray["leadout"]
    
   put 0 into tLineCount
   repeat with n = 1 to tArray["numtracks"]
      add lineoffset("Start Block", tPlist, tLineCount) to tLineCount
      if tLineCount > 0 then put getNodeContents(line tLineCount + 1 of tPlist) into tArray[n]
   end repeat
    
   return tArray
end readTocMac

private function getNodeContents pLine
   replace ">" with comma in pLine
   replace "<" with comma in pLine
   return item 3 of pLine
end getNodeContents

-----

private function readTocWin
   try
      put mcisendstring("set cdaudio timeformat msf") into tRes
      put mcisendstring("status cdaudio number of tracks") into tOffs["numtracks"]
      repeat with n = 1 to tOffs["numTracks"]
         put mcisendstring("status cdaudio position track" && n) into tNum
         put mciMsfToFrames(tNum) into tOffs[n]
      end repeat
      put mcisendstring("status cdaudio length track" && ttOffs["numtracks"]) into tNum
      put tOffs[numtracks] + mciMsfToFrames(tNum) into tOffs["leadout"]
   catch tError
      put "error: coudn't read TOC" into tOffs
   end try
   return tOffs
end readTocWin

private function mciMsfToFrames pNum
   set the itemdelimiter to ":"
   put 0 into tFrames
   add (item 1 of pNum * 60 * 75) to tFrames
   add (item 2 of pNum * 75) to tFrames
   add item 3 of pNum to tFrames
   return tFrames
end mciMsfToFrames
 
-----
 
private function makeDiscId pOffs
   put (pOffs["leadout"] - pOffs[1]) div 75 into totSecs
   
   put 0 into tSum
   repeat with n = 1 to pOffs["numtracks"]
      add sumOfDigits(pOffs[n] div 75) to tSum
   end repeat
   
   put format("%02s",baseconvert(tSum mod 255, 10, 16)) into tDiscId
   put format("%04s",baseconvert(totSecs, 10, 16)) after tDiscId
   put format("%02s",baseconvert(pOffs["numtracks"], 10, 16)) after tDiscId
   return tDiscId
end makeDiscId

-----

private function sumOfDigits pNum
   put 0 into tSum
   repeat for each byte b in pNum
      add b to tSum
   end repeat
   return tSum
end sumOfDigits

-----

private function q pStr
   return quote & pStr & quote
end q

-----

