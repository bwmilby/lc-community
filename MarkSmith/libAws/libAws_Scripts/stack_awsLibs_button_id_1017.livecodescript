Script "stack_awsLibs_button_id_1017"

/*
# Name: button "common" of card id 1002 of stack "awsLibs"
# ID: button id 1017 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
awsLibs common library
version: 1.0
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> aws keys

local sAwsAccessKey
local sAwsSecretKey
local sAwsId
local sAwsCanonicalId
local sAwsDisplayName

-----
-- generally, only the access key and secret key are needed.

function getAwsAccessKey
   return sAwsAccessKey
end getAwsAccessKey

on setAwsAccessKey pKey
   put pKey into sAwsAccessKey
end setAwsAccessKey

function getAwsSecretkey
   return sAwsSecretKey
end getAwsSecretkey

on setAwsSecretKey pKey
   put pKey into sAwsSecretKey
end setAwsSecretKey

function getAwsId
   return sAwsId
end getAwsid

on setAwsId pId
   put pId into sAwsId
end setAwsId

function getAwsCanonicalId
   return sAwsCanonicalId
end getAwsCanonicalId

on setAwsCanonicalId pId
   put pId into sAwsCanonicalId
end setAwsCanonicalId

function getAwsDisplayName
   return sAwsDisplayName
end getAwsDisplayName

on setAwsDisplayName pName
   put pName into sAwsDisplayName
end setAwsDisplayName


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> utilities

function trim pStr
   return word 1 to -1 of pStr
end trim

function q aString
   return quote & aString & quote
end q

-----

function sq pStr
   return "'" & pStr & "'"
end sq

function bq pStr
   return "`" & pStr & "`"
end bq

-----

function pwEncrypt pStr
   put "NaCl" into tSalt
   return sha1.hex(tSalt & pStr)
end pwEncrypt

-----

function gXebn tName, tXml
   put offset("<" & tName & " ",tXml) into ichar
   if ichar = 0 then put offset("<" & tName & ">",tXml) into ichar
   if ichar = 0 then return empty
   get offset(">",tXml,ichar)
   if it = 0 then return empty
   put it + ichar + 1 into startchar
   get offset("</" & tname & ">",tXml)
   if it = 0 then return empty
   return char startchar to it - 1 of tXml
end gXebn

-----

function b64e pData
   put base64encode(pData) into bData
   replace cr with empty in bData
   return bData
end b64e

function b64d pData
   return base64decode(pData)
end b64d

function mb64e pData
   put base64encode(pData) into nData
   replace cr with empty in nData
   replace "+" with "-" in nData
   replace "/" with "_" in nData
   replace "=" with empty in nData
   return nData
end mb64e

function mb64d pData
   replace "-" with "+" in pData
   replace "_" with "/" in pData
   return base64decode(pData & "=")
end mb64d

function b64U8encode pData
   return b64e(utf8encode(pData))
end b64U8encode

function b64U8decode pData
   return utf8decode(base64decode(pData))
end b64U8decode

-----

function pcEncode pString
   put urlencode(pString) into tEncoded
   replace "+" with "%20" in tEncoded
   replace "*" with "%2A" in tEncoded
   return tEncoded
end pcEncode

function pcDecode pEncoded
   replace "%20" with "+" in pEncoded
   replace "%2A" with "*" in pEncoded
   return urldecode(pEncoded)
end pcDecode

-----

function shellEscape pStr
   repeat for each char tChar in "\`!$" & quote
      replace tChar with "\" & tChar in pStr
   end repeat
   return pStr
end shellEscape

-----

function linerize pdata
   replace "><" with ">" & cr & "<" in pdata
   return pdata
end linerize

-----

function utf8encode pString, pIsUnicode
   if pIsUnicode then
      return unidecode(pString, "UTF8")
   else
      return unidecode(uniencode(pString),"UTF8")
   end if
end utf8encode

-----

function utf8decode pString, pToUnicode
   if pToUnicode then
      return uniencode(pString,"UTF8")
   else
      return unidecode(uniencode(pString,"UTF8"))
   end if
end utf8decode

-----

function xmlHeader pEncoding
   if pEncoding is not empty then
      return "<?xml version=" & q(1.0) && "encoding=" & q(pEncoding) & "?>"
   else
      return "<?xml version=" & q(1.0) & "?>"
   end if
end xmlHeader

---------------------------------------------------------------------------------
-- takes a comma delimited list of messages and cancels them
---------------------------------------------------------------------------------

on cancelMessages mNames
   repeat for each line L in the pendingmessages
      if item 3 of L is among the items of mNames then cancel item 1 of L
   end repeat
end cancelMessages

---------------------------------------------------------------------------------
-- panic! attempts to stop all open processes
---------------------------------------------------------------------------------

on killAllProcs
   repeat for each line L in the openprocesses
      kill 9 process L
   end repeat
end killAllProcs

function uid pStr
   if the platform is not "Win32" then
      put shell("uuidgen") into tUuid
   else
      
   end if
   return md5.hex(tUUid & the millisecs & pStr)
end uid

-----

function levenshtein pStr1, pStr2
   put length(pStr1) into m
   put length(pStr2) into n
   
   repeat with i = 0 to m
      put i into d[i][0]
   end repeat
   repeat with i = 0 to n
      put i into d[0][i]
   end repeat
   
   repeat with i = 1 to m
      repeat with j = 1 to n
         if char i of pStr1 = char j of pStr2 then
            put 0 into cost
         else
            put 1 into cost
         end if
         
         put min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost) into d[i][j]
         
      end repeat
   end repeat
   return d[m][n]
end levenshtein


function damLevDistance pStr1, pStr2
   put length(pStr1) into m
   put length(pStr2) into n
   
   repeat with i = 0 to m
      put i into d[i][0]
   end repeat
   repeat with i = 0 to n
      put i into d[0][i]
   end repeat
   
   repeat with i = 1 to m
      repeat with j = 1 to n
         if char i of pStr1 = char j of pStr2 then
            put 0 into cost
         else
            put 1 into cost
         end if
         
         put min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost) into d[i][j]
         
         if (i > 1) and (j > 1) and (char i of pStr1 = char j-1 of pStr2) and \
               (char i-1 of pStr1 = char j of pStr2) then
            put min(d[i][j], d[i-2][j-2] + cost) into d[i][j]
         end if
         
      end repeat
   end repeat
   return d[m][n]
end damLevDistance

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> arrays etc.

---------------------------------------------------------------------------------
-- rough and ready way of displaying the contents of an array
---------------------------------------------------------------------------------
function showArray pArray
   if pArray is not an array then return pArray
   repeat for each line L in keys(pArray)
      if pArray[L] is an array then
         put L & ":" & cr & showArray(pArray[L]) & cr after tList
      else
         put L & "=" & pArray[L] & cr after tList
      end if
   end repeat
   return tList
end showArray

---------------------------------------------------------------------------------
-- rough and ready xml formatting - not needed
---------------------------------------------------------------------------------

function mformatXml pXml, pIndent
   put revCreateXmlTree(pXml, false, true, false) into tTree
   put revXmlText(tTree,,true) into tFtext
   revDeleteXmlTree tTree
   
   if "<?xml" is not in pXml then delete line 1 of tFtext
   if pIndent is empty then return tFtext
   
   repeat for each line L in tFtext
      put word 1 to -1 of L into tLine
      get offset("<", L)
      if it > 2 then
         repeat it div 2
            put pIndent before tLine
         end repeat
      end if
      put tLine & cr after tFormatted
   end repeat
   
   return tFormatted
end mformatXml

---------------------------------------------------------------------------------
-- returns an md5 of any data including multi-dimensional arrays
---------------------------------------------------------------------------------

function dataDigest pData
   if pData is an array then put flattenArray(pData) into pData
   return md5.hex(pData)
end dataDigest

function flattenArray pArray
   put keys(pArray) into tKeys
   sort lines of tkeys
   repeat for each line k in tKeys
      put k after tStr
      if pArray[k] is an array then
         put flattenArray(pArray[k]) after tStr
      else
         put pArray[k] after tStr
      end if
   end repeat
   return tStr
end flattenArray

---------------------------------------------------------------------------------
-- returns true if two arrays are identical, otherwise false
---------------------------------------------------------------------------------

function arraysMatch a1, a2
   put keys(a1) into k1 ; put keys(a2) into k2
   sort lines of k1; sort lnes of k2
   put (k1 = k2) into tArraysMatch
   if tArraysMatch then
      repeat for each key k in a1
         if a1[k] is an array then
            put arraysMatch(a1[k], a2[k]) into tArraysMatch
         else
            put (a1[k] = a2[k]) into tArraysMatch
         end if
         if not tArraysMatch then exit repeat
      end repeat
   end if
   return tArraysMatch
end arraysMatch

---------------------------------------------------------------------------------
-- takes any data including arrays, and returns a base 64 string
-- which can be turned back into the original input by "unrpak"
---------------------------------------------------------------------------------
-- rpak

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
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> dates

---------------------------------------------------------------------------------
-- turns short system date into date format yyyymmdd.
-- if no date is given todays date is used.
---------------------------------------------------------------------------------

function numericDate pDate
   if pDate is empty then
      put the short system date into tDate
   else
      put pDate into tDate
   end if
   convert tDate from short system date to dateItems
   return format("%04d%02d%02d", item 1 of tDate, item 2 of tDate, \
         item 3 of tDate)
end numericDate

-----

function numericDateTime
   put the seconds into tSecs
   convert tSecs from seconds to dateItems
   put format("%04d%02d%02d%02d%02d", item 1 of tSecs, item 2 of tSecs, \
         item 3 of tSecs, item 4 of tSecs, item 5 of tSecs) into tDateTime
   put "." after char 8 of tDateTime
   return tDateTime
end numericDateTime

-----

function numDateToSecs pDate
   put char 1 to 4 of pDate into item 1 of nDate
   put char 5 to 6 of pDate into item 2 of nDate
   put char 7 to 8 of pDate into item 3 of nDate
   put ",0,0,0,0" after nDate
   convert nDate from dateItems to seconds
   return nDate
end numDateToSecs

-----

function incYear pDate
   put char 1 to 4 of pDate into tYear
   add 1 to tYear
   return tYear & char 5 to 8 of pDate
end incYear

-----

function zDate pSeconds
   if pSeconds is empty then
      put internet date into tDate
   else
      put pSeconds into tDate
      convert tDate from seconds to internet date
   end if
   put word -1 of tDate into tOffset
   put char 2 to 3 of tOffset into tHoffset
   put char 4 to 5 of tOffset into tMoffset
   convert tDate to dateItems
   
   if char 1 of tOffset is "+" then
      subtract tHoffset from item 4 of tDate
      subtract tMoffset from item 5 of tDate
   else
      add tHoffset to item 4 of tDate
      add tMoffset to item 5 of tDate 
   end if
   
   set the twelvehourtime to false
   convert tDate to long date and long time
   put word -1 of tDate into tTime
   convert tDate to dateItems
   
   put item 1 of tDate & "-" into zDate
   put format("%02d",item 2 of tDate) & "-" after zDate
   put format("%02d",item 3 of tDate) & "T" after zDate
   put tTime & "Z" after zDate
   return zDate
end zDate

-----

function s3datetoseconds pdate
   replace "gmt" with 0 in pdate
   convert pdate from internet date to seconds
   return pdate
end s3datetoseconds

-----

function s3dateToSecondsB pDate
   replace "-" with comma in pDate
   replace "T" with comma in pDate
   replace ":" with comma in pDate
   replace "." with comma in pDate
   put 0 into item -1 of pDate
   convert pDate from dateitems to seconds
   return pDate
end s3dateToSecondsB

-----

function secondstos3date psecs
   convert psecs from seconds to internet date
   return psecs
end secondstos3date

function theDays
   return the seconds div (24 * 60 * 60)
end theDays

-----

function date.julian d,m,y
   if paramcount() = 0 then
      set the itemdelimiter to "/"
      put the date into td
      put item 1 of td into m
      put item 2 of td into d
      put "20" & item 3 of td into y
   end if
   return (1461*(y+4800+(m-14) div 12)) div 4+(367*(m-2-12*((m-14) div 12))) \
         div 12-(3*((y+4900.0+(m-14) div 12) div 100)) div 4+d-32075
end date.julian


function date.julian2DMY aJulian,@d,@m,@y
   put aJulian + 68569.0 into l
   put ( 4 * l )  div  146097.0 into n
   put l - ( 146097.0 * n + 3 )  div  4 into l
   put ( 4000.0 * ( l + 1 ) )  div  1461001.0  into i -- (that's 1,461,001)
   put l - ( 1461 * i )  div  4 + 31 into l
   put ( 80 * l )  div  2447.0 into j
   put l - ( 2447.0 * j )  div  80 into d -- day
   put j  div  11 into l
   put j + 2 - ( 12 * l ) into m -- month
   put 100 * ( n - 49 ) + i + l into y -- year
   return d & "/" & m & "/" & y
end date.julian2DMY


function date.julian2DayOfWeek aJulian
   return line ((aJulian+1) mod 7 + 1) of the weekdaynames
end date.julian2DayOfWeek

---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> files


on writeFile pFile, pData
   open file pFile for write
   write pData to file pFile
   close file pFile
   return the result
end writeFile

-----

function readFile pFile
   if there is a file pFile then
      open file pFile
      read from file pFile until eof
      put it into tData
      close file pFile
      return tData
   else
      return "error: not found"
   end if
end readFile

-----

on appendFile pFile, pData
   open file pFile for append
   write pData to file pFile
   close file pFile
end appendFile

-----

on writeBinFile pFile, pData
   open file pFile for binary write
   write pData to file pFile
   close file pFile
end writeBinFile

-----

function readBinFile pFile
   open file pFile for binary read
   read from file pFile until eof
   close file pFile
   return it
end readBinFile

-----

on deleteFile pFile
   if there is a file pFile then delete file pFile
end deleteFile

-----

function getFileName pPath
   set the itemdelimiter to "/"
   return item -1 of pPath
end getFileName

-----

function getFolder pPath
   set the itemdelimiter to "/"
   return item 1 to -2 of pPath & "/"
end getFolder

-----

function getExtension pPath
   if "." is not in pPath then return empty
   set the itemdelimiter to "."
   return "." & item -1 of pPath
end getExtension

-----

function getAllFiles pFolder
   put shell("find " & q(pFolder) & " -type f")  into fileList
   filter fileList without empty
   filter fileList without "*/.*"
   --filter fileList without "*/¬*"
   sort lines of fileList
   return fileList
end getAllFiles

-----

function gaf pFolder
   put dWalk(pFolder) into tList
   filter tList without empty
   filter tList without "*/.*"
   sort lines of tList
   return tList
end gaf

private function dWalk pFo
   put the directory into tOldFo
   set the directory to pFo
   
   repeat for each line L in the folders
      --if char 1 of L is "." then next repeat
      put cr & dWalk(pFo & "/" & L) after tFileList
   end repeat
   repeat for each line L in the files
      --if char 1 of L is "." then next repeat
      put cr & pFo & "/" & L after tFileList
   end repeat
   --filter tFileList without empty
   
   set the directory to tOldFo
   return tFileList
end dWalk


-----

function folderToArray tFo
   put the directory into tOldFo
   set the directory to tFo
   
   repeat for each line L in the folders
      if char 1 of L is "." then next repeat
      put folderToArray(tFo & "/" & L) into tArray[L]
   end repeat
   repeat for each line L in the files
      if char 1 of L is "." then next repeat
      put L & "|" after tArray["~f"]
   end repeat
   delete char -1 of tArray["~f"]
   
   set the directory to tOldFo
   return tArray
end folderToArray

-----

# pType can be f (files only), d (folders only), a (all) defaults to f
function folderWalk pFolder, pType
   if pType is not in "fda" then put "f" into pType
   put the directory into tOldFolder
   set the itemdelimiter to "/"
   set the directory to pFolder
   
   if pType is not "d" then
      repeat for each line L in the files
         if L is not empty and char 1 of L is not "." then \
               put pFolder & "/" & L & cr after tFiles
      end repeat
   end if
   
   repeat for each line L in the folders
      if L is not empty and char 1 of L is not "." then 
         if pType is not "f" then put pFolder & "/" & L & cr after tFiles
         put  folderWalk(pFolder & "/" & L, pType) & cr after tFiles
      end if
   end repeat
   filter tFiles without empty
   set the directory to tOldFolder
   return tFiles
end folderWalk

-----

function getAllFolders pFolder
   return shell("find " & q(pFolder) & " -type d")
end getAllFolders


-----

function getBigFileInfo pFile, pIncludeMd5
   put getFolder(pFile) into tFolderName
   put getFileName(pFile) into tFileName
   put the directory into tOldFolder
   set the directory to tFolderName
   put urldecode(the detailed files) into tFileList
   
   filter tFileList with tFileName & ",*"
   put line 1 of tFileList into tInfo
   
   put pFile into tFileInfo["fullPathName"]
   put item 1 of tInfo into tFileInfo["fileName"]
   put tFolderName into tFileInfo["location"]
   put item 2 of tInfo into tFileInfo["size"]
   put item 3 of tInfo into tFileInfo["resourceSize"]
   put item 4 of tInfo into tFileInfo["created"]
   put item 5 of tInfo into tFileInfo["lastModified"]
   put item 6 of tInfo into tFileInfo["lastAccessed"]
   put item 7 of tInfo into tFileInfo["lastBackedUp"]
   put item 8 of tInfo into tFileInfo["Owner"]
   put item 9 of tInfo into tFileInfo["GroupOwner"]
   put item 10 of tInfo into tFileInfo["Permissions"]
   put item 11 of tInfo into tFileInfo["fileType"]
   if pIncludeMd5 then
      put getContentType(pFile) into tFileInfo["ContentType"]
      put fileMd5.all(pFile) into tMd5s
      put tMd5s["b64"] into tFileInfo["md5.b64"]
      put tMd5s["hex"] into tFileInfo["md5.hex"]
   end if
   
   set the directory to tOldFolder
   return tFileInfo
end getBigFileInfo

-----

function getContentType pFile
   set the itemdelimiter to "."
   put "." & item -1 of pFile into tExtension
   get the mimeTypes[tExtension] of me
   if it is empty then
      return "binary/octet-stream"
   else
      return it
   end if
end getContentType

function detailedFiles pFolder, pIncludeMd5
   put the directory into tOldFo
   put utf8decode(shell("find " & q(pFolder) & " -type d")) into tFolderList
   
   repeat for each line tFolder in tFolderList
      if there is a folder tFolder then
         set the directory to tFolder
         put the detailed files into tFileList
         filter tFileList without ".*"
         repeat for each line tFile in tFileList
            put readDetailedFileLine(tFile) into tArray
            put tFolder & "/" & tArray["name"] into tPath
            if pIncludeMd5 then put fileMd5.hex(tPath) into tArray["md5"]
            put tArray into tFileArray[tPath]
         end repeat
      end if
   end repeat
   
   set the directory to tOldFo
   return tFileArray
end detailedFiles

function readDetailedFileLine pLine
   put urldecode(item 1 of pLine) into tArray["name"]
   
   put 1 into tCount
   repeat for each item i in \
         "size,ressize,created,modified,accessed,backedup,owner,group,perms,type"
      add 1 to tCount
      put item tCount of pLine into tArray[i]
   end repeat
   return tArray
end readDetailedFileLine

-----

on createPath pPath
   set the itemdelimiter to "/"
   if char -1 of pPath is "/" then
      delete char -1 of pPath
   else
      delete item -1 of pPath
   end if
   
   repeat with n = 1 to the number of items in pPath
      if there is no folder (item 1 to n of pPath) then
         create folder (item 1 to n of pPath)
      end if
   end repeat
end createPath

--------------------------------------------------------

local sCopyFileDone
local sCopyFileProg
local sCopyFileStop

function copyFileDone
   return sCopyFileDone
end copyFileDone

function copyFileProg
   return sCopyFileProg
end copyFileProg

on copyFileStop
   put true into sCopyFileStop
end copyFileStop

on copyFile pSource, pDest
   put 0 into sCopyFileProg
   put false into sCopyFileDone
   put false into sCopyFileStop
   
   if there is no file pSource then return "error: source file does not exist"
   createPath pDest
   
   put getfileSize(pSource) into tFileSize
   put 0 into bytesDone
   open file pSource for binary read
   open file pDest for binary write
   send "doCCFile pSource, pDest, tFileSize, bytesDone" to me in 10 millisecs
end copyFile

command doCCfile pSource, pDest, pFileSize, bytesDone
   --put 32768 into tChunkSize
   if (bytesDone >= pFileSize) or sCopyFileStop then
      close file pSource
      close file pDest
      put true into sCopyFileDone
      if sCopyFileStop then
         delete file pDest
      end if
   else
      read from file pSource for 131072
      write it to file pDest
      add length(it) to bytesDone
      put round(bytesDone / pFileSize * 100) into sCopyFileProg
      send "doCCfile pSource, pDest, pFileSize, bytesDone" to me in 10 millisecs
   end if
end doCCfile


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> numbers

function nzp
   repeat with n = 1 to paramcount()
      if (not isnumber(param(n))) or (param(n) <= 0) then return false
   end repeat
   return true
end nzp

-----

function nzn
   repeat with n = 1 to paramcount()
      if (not isnumber(param(n))) or (param(n) >= 0) then return false
   end repeat
   return true
end nzn

-----

function nza
   repeat with n = 1 to paramcount()
      if (not isnumber(param(n))) or (param(n) = 0) then return false
   end repeat
   return true
end nza

-----

function nzpi
   repeat with n = 1 to paramcount()
      if (not (param(n) is an integer)) or (param(n) <= 0) then return false
   end repeat
   return true
end nzpi

-----

function nzni
   repeat with n = 1 to paramcount()
      if (not (param(n) is an integer)) or (param(n) >= 0) then return false
   end repeat
   return true
end nzni

-----

function nzi
   repeat with n = 1 to paramcount()
      if (not (param(n) is an integer)) or (param(n) = 0) then return false
   end repeat
   return true
end nzi

-----

function formatDataSize pNum
   if pNum is not a number then return empty
   if pNum < 1 then return "0 bytes"
   
   repeat until pNum < 1
      add 1 to c
      put round(pNum, 2) into dNum
      divide pNum by 1024
   end repeat
   return dNum && item c of "bytes,Kb,Mb,Gb,Tb,Pb,Eb,Zb,Yb" 
end formatDataSize

-----

function formatMs t
   put t div 3600000 mod 24 into h
   put t mod 3600000 div 60000  into m
   put t mod 60000 div 1000 into s
   put t mod 1000 into ms
   return format( "%02d:%02d:%02d:%03d", h, m, s, ms)
end formatMs

-----

function formatSecs t
   put t div 3600 mod 24 into h
   put t mod 3600 div 60  into m
   put t mod 60 into s
   return format( "%02d:%02d:%02d", h, m, s)
end formatSecs

-----

function ordinate pNum
   if (char -1 of pNum is in "0456789") or (char -2 of pNum is "1") then
      put "th" into tSuffix
   else
      put item (char -1 of pNum) of "st,nd,rd" into tSuffix
   end if
   return pNum & tSuffix
end ordinate

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> email

command mail pTo, pSub, pMsg, pFrom, pCc, pBcc, pAttachment, pAttachment2
   put shellEscape(pTo) into pTo
   put shellEscape(pSub) into pSub
   put shellEscape(pMsg) into pMsg
   put shellEscape(pFrom) into pFrom
   put shellEscape(pCC) into pCc
   put shellEscape(pBcc) into pBcc
   put shellEscape(pAttachment) into pAttachment
   put shellEscape(pAttachment2) into pAttachment2
   
   get shell("(uuencode" && q(pAttachment) && q(pAttachment2) & ";echo -e" && \
         q(pMsg) & ")" && "| mail -s" && q(pSub) && q(pTo) && "-c" && q(pCc) \
         && "-b" && q(pBcc) && "-- -f" && q(pFrom))
end mail

-----

function emailValid pEmail
   return matchtext(pEmail,\
         "^[A-z0-9_\-\.]+[@][A-z0-9_\-]+([.][A-z0-9_\-]+)+[A-z]$")
end emailValid

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> common paths

-----

function tempDir
   put the tempname into tName
   set the itemdelimiter to "/"
   return item 1 to -2 of tName
end tempDir


-----

function curlPath
   switch the platform
      case "Win32"
         
         break
      default
         return "curl"
         break
   end switch
end curlPath

-----

function sslPath
   switch the platform
      case "Win32"
         
         break
      default
         return "openssl"
         break
   end switch
end sslPath


---===---===---===---===---===---===---===---===---===---===---===---===---===---
