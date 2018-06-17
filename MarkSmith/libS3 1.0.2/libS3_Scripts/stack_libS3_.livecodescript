Script "stack_libS3_"

/*
# Name: stack "libS3"
# ID: stack "libS3"
*/


-- libS3 v 1.0.2
-- Mark Smith
-- mark@maseurope.net
-- 2008


--> script locals

local sAccessKey
local sSecretKey
local sSocketID
local sLastRequestHeaders
local sLastResponseHeaders
local sLastResponseBody
local sBaseAddr = "http://s3.amazonaws.com"
local sTransfer
local sCallbackName
local sCallbackTarget

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

private command clearLocals
   put empty into sLastRequestHeaders
   put empty into sLastResponseHeaders
   put empty into sLastResponseBody
   put empty into sTransfer
end clearLocals

--> s3 interface

on s3.setKeys pAccessKey, pSecretKey
   put pAccessKey into sAccessKey
   put pSecretKey into sSecretKey
end s3.setKeys

----------------------------------------

on s3.setStatusCallback pName, pTarget
   if pName is empty or pTarget is empty then
      put empty into sCallbackName
      put empty into sCallbackTarget
   else
      put pName into sCallbackName
      put pTarget into sCallbackTarget
   end if
end s3.setStatusCallback

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

function s3.listAllMyBucketsXML
   clearLocals
   httpGet "/"
   if the result then
      return linerize(getXmlFromData(sLastResponseBody))
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.listAllMyBucketsXML

----------------------------------------

function s3.listAllMyBuckets
   clearLocals
   httpGet "/"
   if the result then
      return bucketNamesFromXml(sLastResponseBody)
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.listAllMyBuckets

----------------------------------------

function s3.listBucketXML pBucket
   clearLocals
   httpGet makeObject(pBucket,"")
   if the result then
      return sLastResponseBody
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.listBucketXML

----------------------------------------

function s3.listBucket pBucket
   clearLocals
   httpGet makeObject(pBucket,"")
   if the result then
      return objectNamesFromXml(sLastResponseBody)
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.listBucket

----------------------------------------

function s3.listBucketArray pBucket
   clearLocals
   httpGet makeObject(pBucket,"")
   if the result then
      put bucketToArray(sLastResponseBody) into tArray
   else
      put line 1 of sLastResponseHeaders & cr & sLastResponseBody into tArray["error"]
   end if
   return tArray
end s3.listBucketArray

----------------------------------------

function s3.listObject pBucket, pKey
   clearLocals
   httpHead makeObject(pBucket, pKey)
   
   if the result then
      return sLastResponseHeaders
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.listObject

----------------------------------------

function s3.listObjectArray pBucket, pKey
   clearLocals
   httpHead makeObject(pBucket, pKey)
   put headInfo(sLastResponseHeaders) into tArray
   if (sLastResponseBody is not empty) then put sLastResponseBody into tArray["error"]
   return tArray
end s3.listObjectArray

----------------------------------------

function s3.getLocation pBucket
   clearLocals
   httpGetConfig urlencode(makeObject(pBucket)) & "?location"
   
   if the result then
      get gXEBN(sLastResponseBody)
      if it is empty then
         return "no location constraint"
      else
         return it
      end if
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.getLocation

----------------------------------------

function s3.getACL pBucket, pKey
   clearLocals
   httpGetConfig urlencode(makeObject(pBucket, pKey)) & "?acl"
   
   if the result then
      return linerize(sLastResponseBody)
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.getACL

----------------------------------------

on s3.setACL pBucket, pKey, pACList
   clearLocals
   put makeObject(pBucket, pKey) into tObject
   put urlencode(tObject) & "?acl" into sTransfer["objectName"]
   put pAClist into sTransfer["data"]
   put length(pAClist) into sTransfer["size"]
   
   httpPutConfig
    
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.setACL

----------------------------------------

function s3.getLogging pBucket
   clearLocals
   httpGetConfig urlencode(makeObject(pBucket)) & "?logging"
   put sLastResponseHeaders
   
   if the result then
      return sLastResponseBody
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.getLogging

----------------------------------------

on s3.setLogging pBucket, pTarget, pPrefix
   clearLocals
   if pTarget is not empty then
      put the enableLoggingXML of me into tXML
      replace "{target}" with pTarget in tXML
      replace "{prefix}" with pPrefix in tXML
   else
      put the disableLoggingXML of me into tXML
   end if
   replace cr with empty in tXML
   put tXML into sTransfer["data"]
   put length(tXML) into sTransfer["size"]
   put urlencode(makeObject(pBucket)) & "?logging" into sTransfer["objectName"]
   
   httpPutConfig
   
   if the result then
      return linerize(sLastResponseBody)
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.setLogging

----------------------------------------

function s3.downloadData pBucket, pKey
   clearLocals
   put urlencode(makeObject(pBucket, pKey)) into sTransfer["objectName"]
   
   httpGetObject
   
   if the result then
      return sLastResponseBody
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.downloadData

----------------------------------------

on s3.downloadFile pBucket, pKey, pDestFile
   clearLocals
   put urlencode(makeObject(pBucket, pKey)) into sTransfer["objectName"]
   put pDestFile into sTransfer["filePath"]
    
   httpGetObject
    
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.downloadFile

----------------------------------------

on s3.uploadData pBucket, pKey, @pData, pAcl
   clearLocals
   put makeObject(pBucket, pKey) into tObject
   put urlencode(tObject) into sTransfer["objectName"]
   put pData into sTransfer["data"]
   if pAcl is not among the items of "private,public-read,public-read-write,authenticated-read" then
      put "private" into sTransfer["accessControl"]
   else
      put pAcl into sTransfer["accessControl"]
   end if
   put getContentType(tObject) into sTransfer["contentType"]
   put length(sTransfer["data"]) into sTransfer["size"]
   put md5.b64(sTransfer["data"]) into sTransfer["md5.b64"]
   
   httpPutData
    
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.uploadData

----------------------------------------

on s3.uploadFile pBucket, pKey, pSourceFile, pAcl
   if the platform is "MacOS" and isPackage(pSourceFile) then return "error:" && "file is a package"
   if there is no file pSourceFile then return "error:" && "file not found"
   
   put makeObject(pBucket, pKey) into tObject
   clearLocals
   put urlencode(tObject) into sTransfer["objectName"]
   put pSourceFile into sTransfer["filePath"]
   if pAcl is not among the items of "private,public-read,public-read-write,authenticated-read" then
      put "private" into sTransfer["accessControl"]
   else
      put pAcl into sTransfer["accessControl"]
   end if
    
   httpPutFile
    
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.uploadFile

----------------------------------------
-- takes a return delimited list where each line is:
-- item 1 = bucket, item 2 = objectKey, item 3 = full path of file, item 4 (optional) = acl

on s3.uploadFileList pList
   put empty into tFailures
   repeat for each line L in pList
      s3.uploadFile item 1 of L, item 2 of L, item 3 of L, item 4 of L
      if the result is not empty then put item 3 of L & cr after tFailures
   end repeat
   delete char -1 of tFailures
   return tFailures
end s3.uploadFileList

----------------------------------------

on s3.deleteObject pBucket, pKey
   clearLocals
   httpDelete makeObject(pBucket, pKey)
   
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.deleteObject

----------------------------------------

on s3.deleteBucket pBucket
   clearLocals
   httpDelete makeObject(pBucket, "")
   
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.deleteBucket

----------------------------------------

on s3.deleteBucketAndContents pBucket
   s3.emptyBucket pBucket
   if the result is empty then
      s3.deleteBucket pBucket
      return the result
   else
      return "bucket not deleted" & cr & the result
   end if
end s3.deleteBucketAndContents

----------------------------------------

on s3.emptyBucket pBucket
   put s3.listBucket(makeObject(pBucket, "")) into tObjectList
   repeat for each line L in tObjectList
      s3.deleteObject pBucket, L
      if the result is not empty then
      put L && line 1 of sLastResponseHeaders & cr after errorList
      end if
      wait 20 ticks
   end repeat
   delete char -1 of errorList
   return errorList
end s3.emptyBucket

----------------------------------------

on s3.createBucket pBucket, pAcl
   clearLocals
   put makeObject(pBucket, "") into tReqInfo["objectName"]
   if pAcl is not among the items of "private,public-read,public-read-write,authenticated-read" then
      put "private" into tReqInfo["accessControl"]
   else
      put pAcl into tReqInfo["accessControl"]
   end if
   
   httpPutB tReqInfo
    
   if the result then
      return empty
   else
      return line 1 of sLastResponseHeaders & cr & sLastResponseBody
   end if
end s3.createBucket

----------------------------------------

function s3.timeLimitUrls  pBucket, pExpiry
   put s3.listBucket(pBucket) into tObjectList
  
   repeat for each line L in tObjectList
      put "http://" & pBucket & ".s3.amazonaws.com/" & L & "?AWSAccessKeyId=" & sAccessKey into tUrl
      put "&Expires=" & pExpiry & "&Signature=" & makeQauth(pBucket, L, pExpiry) after tUrl
      put tUrl & cr after tUrls
   end repeat
   return char 1 to -2 of tUrls
end s3.timeLimitUrls



private function makeQauth pBucket, pObject, pExpiry
   put makeObject(pBucket, pObject) into tObject
   put "GET" & cr & cr & cr & pExpiry & cr & tObject into stringToSign
   return urlencode(hmacSha1.b64(stringToSign, sSecretKey))
end makeQauth

----------------------------------------

function s3.getVersion
   return "1.0.2"
end s3.getVersion

----------------------------------------

function s3.checkLatestVersion
   put url ("http://maspub.s3.amazonaws.com/libS3latestVersion.txt") into tVersion
   return "this version : " & s3.getVersion() & cr & "available : " & tVersion
end s3.checkLatestVersion

----------------------------------------

private function makeObject pBucket, pKey
   replace "/" with empty in pBucket
   put "/" & pBucket into tObject
   if pKey is not empty then
      if char 1 of pKey is not "/" then put "/" after tObject
      put pKey after tObject
   end if
   return tObject
end makeObject

--> debug

function s3debug.lastRsh
   return sLastResponseHeaders
end s3debug.lastRsh

function s3debug.lastRshArray
   put headersToArray(sLastResponseHeaders) into tArray
   return tArray
end s3debug.lastRshArray

function s3debug.lastRqh
   return sLastRequestHeaders
end s3debug.lastRqh

function s3debug.lastRqhArray
   put headersToArray(sLastResponseHeaders) into tArray
   return tArray
end s3debug.lastRqhArray

function s3debug.lastRb
   return sLastResponseBody
end s3debug.lastRb


--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> libUrl

private command libUrlGet pObject
   put pObject into tReqInfo["objectName"]
   put makeRequestHeaders("GET", tReqInfo) into tHeaders
   libUrlSetCustomHttpHeaders sLastRequestHeaders
    
   put URL (sBaseAddr & pObject) into sLastResponseBody
   put libUrlLastRhHeaders() into sLastResponseHeaders
    
   return ("200 OK" is in line 1 of sLastResponseHeaders)
end libUrlGet

----------------------------------------

private command libUrlPut pObject
   put pObject into tReqInfo["objectName"]
   put makeRequestHeaders("PUTB", tReqInfo) into tHeaders
   
   libUrlSetCustomHttpHeaders sLastRequestHeaders
    
   put empty into URL (sBaseAddr & pObject)
   put libUrlLastRhHeaders() into sLastResponseHeaders
    
   return ("200 OK" is in line 1 of sLastResponseHeaders)
end libUrlPut

----------------------------------------

private command libUrlHead pObject
   put pObject into tReqInfo["objectName"]
   put makeRequestHeaders("HEAD", tReqInfo) into tHeaders
    
   libUrlSetCustomHttpHeaders sLastRequestHeaders
    
   put URL (sBaseAddr & pObject) into sLastResponseBody
   
   put libUrlLastRhHeaders() into sLastResponseHeaders
    
   return ("200 OK" is in line 1 of sLastResponseHeaders)
end libUrlHead

----------------------------------------

private command libUrlGetFile
    
end libUrlGetFile

----------------------------------------
--> curl

private command curlHead pObject
    
end curlHead

----------------------------------------

private command curlGet pObject
    
end curlGet

----------------------------------------

private command curlDataUpload pObject, @pData, pContentType
   
end curlDataUpload

----------------------------------------

private command curlFileUpLoad pObject, pFile, pContentType
   
end curlFileUpLoad

----------------------------------------

private command curlDataDownload pObject, pDestFile
    
end curlDataDownload

----------------------------------------

private command curlFileDownLoad pObject, pFile
    
end curlFileDownLoad

----------------------------------------

private command curlDelete pObject
   
end curlDelete

----------------------------------------
--> http


private command httpHead pObject
   put empty into sLastResponseBody
   put urlencode(pObject) into tReqInfo["objectName"]
   put makeRequestHeaders("HEAD", tReqInfo) into tHeaders
    
   put "s3.amazonaws.com:80|headSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      close socket tSock
      return ("200 OK" is in line 1 of sLastResponseHeaders)
   else
      put empty into sLastResponseHeaders
      put "couldn't connect" into sLastResponseBody
      close socket tSock
      return false
   end if
end httpHead

----------------------------------------

private command httpDelete pObject
   put empty into sLastResponseBody
   put urlencode(pObject) into tReqInfo["objectName"]
   put makeRequestHeaders("DELETE", tReqInfo) into tHeaders
   
   put "s3.amazonaws.com:80|deleteSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      if "204 No Content" is not in line 1 of sLastResponseHeaders then
         put httpReadResponseBody(tSock) into sLastResponseBody
      end if
      close socket tSock
      return (sLastResponseBody is empty)
   else
      put empty into sLastResponseHeaders
      put "couldn't connect" into sLastResponseBody
      close socket tSock
      return false
   end if
end httpDelete

----------------------------------------

private command httpPutB pReqInfo
   put empty into sLastResponseBody
   put makeRequestHeaders("PUTB", pReqInfo) into tHeaders
   
   put "s3.amazonaws.com:80|putBSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      if "200 OK" is not in line 1 of sLastResponseHeaders then
         put httpReadResponseBody(tSock) into sLastResponseBody
      end if
      close socket tSock
      return (sLastResponseBody is empty)
   else
      put empty into sLastResponseHeaders
      put "couldn't connect" into sLastResponseBody
      close socket tSock
      return false
   end if
end httpPutB

----------------------------------------

private command httpPutFile
   put getFileInfo(sTransfer["filePath"]) into tInfo
   union sTransfer with tInfo
    
   put makeRequestHeaders("PUT", sTransfer) into tHeaders
   put empty into sLastResponseHeaders
   
   put "s3.amazonaws.com:80|putFileSocket" into tSock
   if tSock is not among the lines of the opensockets then open socket to tSock
   put (the result is empty) into noError
   write tHeaders to socket tSock
    
   put httpReadResponseHeaders(tSock) into sLastResponseHeaders
   put ("100 Continue" is in sLastResponseHeaders) into noError
   
   if noError then
      put tSock into sTransfer["socketID"]
      put 0 into sTransfer["bytesWrit"]
      put 0 into sTransfer["percentDone"]
      put "loading" into sTransfer["status"]
      open file sTransfer["filePath"] for binary read
      httpWriteFromFile
      return the result
   else
      resetAll
      close file pSourceFile
      close socket tSock
      put empty into sTransfer
      return false
   end if
end httpPutFile

----------------------------------------

private command httpWriteFromFile
   repeat while sTransfer["bytesWrit"] < sTransfer["size"]
      if the optionkey is down and the controlkey is down then exit repeat
      put min(8192, sTransfer["size"] - sTransfer["bytesWrit"]) into writeSize
      wait 6 ticks
       
      read from file sTransfer["filePath"] for writeSize 
      write it to socket sTransfer["socketID"]
      if the result is not empty then
         put "error:aborted" into sTransfer["status"]
         exit repeat
      end if
      add writeSize to sTransfer["bytesWrit"]
      put round(sTransfer["bytesWrit"] / sTransfer["size"] * 100) into sTransfer["percDone"]
      put "loading" into sTransfer["status"]
      doCallback
   end repeat
   
   put httpReadResponseHeaders(sTransfer["socketID"]) into sLastResponseHeaders
   if ("200 OK" is not in line 1 of sLastResponseHeaders) then
      put httpReadResponseBody(sTransfer["socketID"]) into sLastResponseBody
   end if
   if "error" is not in sTransfer["status"] then put "done" into sTransfer["status"]
   doCallback
   close file sTransfer["filePath"]
   close socket sTransfer["socketID"]
   put empty into sTransfer
   return "200 OK" is in line 1 of sLastResponseHeaders
end httpWriteFromFile

----------------------------------------

private command httpPutConfig
   put makeRequestHeaders("PUTC", sTransfer) into tHeaders
   
   put "s3.amazonaws.com:80|putConfigSocket" into tSock
   open socket to tSock
   if (the result is empty) then
      write tHeaders & sTransfer["data"] & crlf to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      return "200 OK" is in line 1 of sLastResponseHeaders
   else
      close socket tSock
      put empty into sTransfer
      put "couldn't connect" into sLastResponseBody
      return false
   end if
end httpPutConfig

----------------------------------------

private command httpPutData
   put makeRequestHeaders("PUT", sTransfer) into tHeaders
   
   put "s3.amazonaws.com:80|putDataSocket" into tSock
   open socket to tSock
   put (the result is empty) into noError
   write tHeaders to socket tSock
   put httpReadResponseHeaders(tSock) into sLastResponseHeaders
   put ("100 Continue" is in sLastResponseHeaders) into noError
   if noError then
      put tSock into sTransfer["socketID"]
      put 0 into sTransfer["bytesWrit"]
      put 0 into sTransfer["percDone"]
      httpWriteData
      return the result
   else
      close socket tSock
      put empty into sTransfer
      put "error" into sLastResponseBody
      return false
   end if
end httpPutData

----------------------------------------

private command httpWriteData
   repeat while sTransfer["bytesWrit"] < sTransfer["size"]
      if the optionkey is down and the controlkey is down then exit repeat
      put min(8192, sTransfer["size"] - sTransfer["bytesWrit"]) into writeSize
      
      get char sTransfer["bytesWrit"] + 1 to sTransfer["bytesWrit"] + writeSize of sTransfer["data"]
      write it to socket sTransfer["socketID"]
      add writeSize to sTransfer["bytesWrit"]
      put round(sTransfer["bytesWrit"] / sTransfer["size"] * 100) into percentDone
      put percentDone into sTransfer["percDone"]
      
      doCallback
      wait 6 ticks
   end repeat
   put httpReadResponseHeaders(sTransfer["socketID"]) into sLastResponseHeaders
   if ("200 OK" is not in line 1 of sLastResponseHeaders) then
      put httpReadResponseBody(sTransfer["socketID"]) into sLastResponseBody
   end if
   close socket sTransfer["socketID"]
   put empty into sTransfer
   return ("200 OK" is in line 1 of sLastResponseHeaders)
end httpWriteData

----------------------------------------

private command httpGetObject
   put makeRequestHeaders("GET", sTransfer) into tHeaders
    
   put "s3.amazonaws.com:80|getFileSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      
      if "200 OK" is in line 1 of sLastResponseHeaders then
         put headInfo(sLastResponseHeaders) into tArray
         union sTransfer with tArray
          
         put tSock into sTransfer["socketID"]
          
         put 0 into sTransfer["bytesRead"]
         put 0 into sTransfer["percDone"]
         if sTransfer["filePath"] is not empty then
            httpDownloadFile
            return sLastResponseBody is empty
         else
            httpDownloadData
            return the result
         end if
      else
         put httpReadResponseBody(tSock) into sLastResponseBody
         close socket tSock
      end if
   else
      put "couldn't connect" into sLastResponseBody
      return false
   end if
end httpGetObject

----------------------------------------

private command httpDownloadFile
   put empty into sLastResponseBody
   open file sTransfer["filePath"] for binary write
   put ("Transfer-Encoding: chunked" is in sLastResponseHeaders) into isChunked
   if isChunked then beep
   repeat 
      if the optionkey is down and the controlkey is down then exit repeat
      if isChunked then
         put httpReadChunkedData(tSock) into tChunk
      else
         put httpReadData() into tChunk
      end if
      if tChunk["data"] is not empty then write tChunk["data"] to file sTransfer["filePath"]
      if tChunk["size"] = 0 then exit repeat
      if tChunk["error"] then
         put "read error" into sLastResponseBody
         exit repeat
      end if
      put "loading" into sTransfer["status"]
      put round(sTransfer["bytesRead"] / sTransfer["size"] * 100) into sTransfer["percDone"]
      doCallback
      wait 3 ticks
   end repeat
   close file sTransfer["filePath"]
   close socket sTransfer["socketID"]
   doCallback
   
   if sTransfer["md5"] is not fileMd5.hex(sTransfer["filePath"]) then
      put "download error: digests do not match" into sLastResponseBody
   end if
end httpDownloadFile

----------------------------------------

private command httpDownloadData
   put empty into sLastResponseBody
   put empty into tData
   put ("Transfer-Encoding: chunked" is in sLastResponseHeaders) into isChunked
   repeat 
      if isChunked then
         put httpReadChunkedData(tSock) into tChunk
      else
         put httpReadData() into tChunk
      end if
      if tChunk["data"] is not empty then put tChunk["data"] after tData
      if tChunk["size"] = 0 then exit repeat
      if tChunk["error"] then
         put "read error" into sLastResponseBody
         exit repeat
      end if
      put "loading" into sTransfer["status"]
      put round(sTransfer["bytesRead"] / sTransfer["size"] * 100) into sTransfer["percDone"]
      doCallback
      wait 6 ticks
   end repeat
   close file sTransfer["filePath"]
   close socket sTransfer["socketID"]
   doCallback
   
   if sLastResponseBody is not empty then return false
   if sTransfer["md5"] is not md5.hex(tData) then
      put "download error: digests do not match" into sLastResponseBody
      return false
   else
      put tData into sLastResponseBody
      return true
   end if
end httpDownloadData

----------------------------------------

private function httpReadChunkedData pSock
   put empty into tData
   
   repeat
      wait 100 millisecs
      read from socket pSock until crlf
      put baseconvert(char 1 to -3 of it, 16, 10) into tSize
      if tSize = 0 then exit repeat
      read from socket pSock for tSize
      put it after tData
      read from socket pSock for 2
   end repeat
   return tData
end httpReadChunkedData

----------------------------------------

private function httpChunkedDataByChunk pSock
   put empty into tChunk["data"]
   put false into tChunk["error"]
   wait 100 millisecs
   
   read from socket pSock until crlf
   put baseconvert(char 1 to -3 of it, 16, 10) into tChunk["size"]
   if tChunk["size"] > 0 then
      read from socket pSock for tChunk["size"]
      put it into tChunk["data"]
      read from socket pSock for 2
   end if
   return tChunk
end httpChunkedDataByChunk

----------------------------------------

private function httpReadData
   put false into tChunk["error"]
   put min(8192, sTransfer["size"] - sTransfer["bytesRead"]) into readSize
   repeat 20
      wait 50 millisecs
      read from socket sTransfer["socketID"] for readSize
      if the result is not empty then put true into tChunk["error"]
      if it is not empty then
         put it into tChunk["data"]
         add readSize to sTransfer["bytesRead"]
      end if
      if tChunk["error"] or tChunk["data"] is not empty then exit repeat
   end repeat
   put sTransfer["size"] - sTransfer["bytesRead"] into tChunk["size"]
   return tChunk
end httpReadData

----------------------------------------

private command httpGet pObject
   put empty into sLastResponseBody
   put pObject into tReqInfo["objectName"]
   put makeRequestHeaders("GET", tReqInfo) into tHeaders
   
   put "s3.amazonaws.com:80|getSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      put httpReadResponseBody(tSock) into sLastResponseBody
      close socket tSock
      return ("200 OK" is in line 1 of sLastResponseHeaders)
   else
      put empty into sLastResponseHeaders
      close socket tSock
      return false
   end if
end httpGet

----------------------------------------

private command httpGetConfig pObject
   put empty into sLastResponseBody
   put pObject into tReqInfo["objectName"]
   
   put makeRequestHeaders("GET", tReqInfo) into tHeaders
   
   put "s3.amazonaws.com:80|getAclSocket" into tSock
   open socket to tSock
   if the result is empty then
      write tHeaders to socket tSock
      put httpReadResponseHeaders(tSock) into sLastResponseHeaders
      --put sLastResponseHeaders
      put httpReadResponseBody(tSock) into sLastResponseBody
      close socket tSock
      return ("200 OK" is in line 1 of sLastResponseHeaders)
   else
      put empty into sLastResponseHeaders
      close socket tSock
      return false
   end if
end httpGetConfig

----------------------------------------

private function httpReadResponseHeaders pSock
   put empty into tResponse
   repeat 20
      wait 100 millisecs
      read from socket pSock until crlf & crlf
      if it is not empty then
         put it into tResponse
         exit repeat
      end if
   end repeat
   replace crlf with cr in tResponse
   filter tResponse without empty
   return tResponse
end httpReadResponseHeaders

----------------------------------------

private function httpReadResponseBody pSock
   if ": chunked" is not in sLastResponseHeaders then
      put empty into tResponse
      repeat 20
         wait 50 millisecs
         read from socket pSock until empty
         if it is not empty then
            put it after tResponse
            exit repeat
         end if
      end repeat
   else
      repeat
         put httpChunkedDataByChunk(pSock) into tChunk
         if tChunk["size"] = 0 then exit repeat
         if tChunk["error"] then
            put "error reading socket" into tResponse
            exit repeat
         end if
         put tChunk["data"] after tResponse
      end repeat
   end if
    
   replace crlf with cr in tResponse
   return tResponse
end httpReadResponseBody

----------------------------------------

private command doCallback
   if sCallbackName is not empty and sCallbackTarget is not empty then
      send sCallbackName && urldecode(sTransfer["objectName"]) & comma & sTransfer["status"] & comma & sTransfer["percDone"] to sCallbackTarget
   end if
end doCallback

----------------------------------------

--> headers

private function makeRequestHeaders pMethod, pReqInfo
   
   switch pMethod
      case "PUT"
         put the putHeaders of me into tHeaders
         replace "{contentlength}" with pReqInfo["size"] in tHeaders
         replace "{contentmd5}" with pReqInfo["md5.b64"] in tHeaders
         replace "{contenttype}" with pReqInfo["contentType"] in tHeaders
         replace "{acl}" with pReqInfo["accessControl"] in tHeaders
         break
      case "PUTB"
         put the putBHeaders of me into tHeaders
         replace "{contentlength}" with "0" in tHeaders
         replace "{acl}" with pReqInfo["accessControl"] in tHeaders
         break
      case "PUTC"
         put the PUTCheaders of me into tHeaders
         replace "{contentlength}" with pReqInfo["size"] in tHeaders
         replace "{contentmd5}" with pReqInfo["md5.b64"] in tHeaders
         break
      case "GET"
         put the getHeaders of me into tHeaders
         break
      case "HEAD"
         put the headHeaders of me into tHeaders
         break
      case "DELETE"
         put the deleteHeaders of me into tHeaders
         break
   end switch
    
   replace "{uri}" with  pReqInfo["objectName"] in tHeaders
   replace "{date}" with the internet date in tHeaders
   
   put cr & getAuthString(tHeaders, pReqInfo["objectName"]) after tHeaders
   put tHeaders into sLastRequestHeaders
   replace cr with crlf in tHeaders
   put crlf & crlf after tHeaders
   return tHeaders
end makeRequestHeaders

----------------------------------------

private function headersToArray pHeaders
   if "HTTP" is in word 1 of tHeaders then
      put word 2 of line 1 of tHeaders into tArray["response"]
      put word 1 of line 1 of tHeaders into tArray["httpVersion"]
   else
      put word 1 -2 of line 1 of tHeaders into tArray["request"]
      put word -1 of line 1 of tHeaders into tArray["httpVersion"]
   end if
   delete line 1 of tHeaders
   set the itemdelimiter to ":"
   repeat for each line L in tHeaders
      put word 1 to -1 of item 2 of L into tArray[item 1 of L]
   end repeat
   return tArray
end headersToArray


--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> s3Auth

private function getAuthString pHeaders, pPath
   return "Authorization:" && "AWS" && sAccessKey & ":" & hmacSha1.b64(makeStringToSign(pHeaders, pPath), sSecretKey)
end getAuthString

----------------------------------------

private function makeStringToSign pHeaders, pPath
   -- pHeaders is the http headers, of course
   -- pPath is /bucket/object
    
   put word 1 of pHeaders into tMethod
   split pHeaders by cr and ":"
    
   repeat for each line tKey in the keys of pHeaders
      if tKey is among the items of "Content-md5,Content-type,date" or char 1 to 6 of tKey is "x-amz-" then
         put word 1 to -1 of pHeaders[tKey] into interestingHeaders[toLower(tKey)]
      end if
   end repeat
   if "content-md5" is not in the keys of interestingHeaders then put empty into interestingHeaders["content-md5"]
   if "content-type" is not in the keys of interestingHeaders then put empty into interestingHeaders["content-type"]
   if "x-amz-date" is in the keys of interestingHeaders then put empty into interestingHeaders["date"]
    
   put the keys of interestingHeaders into ihKeys
   sort lines of ihKeys
    
   put tMethod & cr into stringToSign
   repeat for each line tKey in ihKeys
      if "x-amz-" is in tKey then
         put tKey & ":" & interestingHeaders[tKey] & cr after stringToSign
      else
         put interestingHeaders[tKey] & cr after stringToSign
      end if
   end repeat
    
   put pPath after stringToSign
    
   -- get offset("?",pPath)
   -- if it = 0 then get length(pPath) + 1
   -- put char 1 to it-1 of pPath after stringToSign
   -- if char -4 to -1 of pPath is "?acl" then put "?acl" after stringToSign
   -- if char -8 to -1 of pPath is "?torrent" then put "?torrent" after stringToSign
   -- if char -9 to -1 of pPath is "?location" then put "?location" after stringToSign
   -- if char -8 to -1 of pPath is "?logging" then put "?logging" after stringToSign
    
   replace numtochar(13) with numtochar(10) in stringToSign -- just to make damn sure!
   return unidecode(uniencode(stringToSign),"UTF8")
end makeStringToSign

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> XML etc

private function getXmlFromData pData
   replace crlf with cr in pData
   get lineoffset("<?xml ", pData)
   if it = 0 then return empty
    
   put line it to -1 of pData into tXml
   filter tXml without empty
    
   if char -1 of tXml is not ">" then
      repeat with n = length(tXml) down to 1
         if char n of tXml is not ">" then
            delete char n of tXml
         else
            exit repeat
         end if
      end repeat
   end if
   return tXml
end getXmlFromData

----------------------------------------

private function listAllBucketsToArray tXML
   put revCreateXMLTree(tXML,false,true,false) into tID
   put revXmlRootNode(tID) into tRootNode
   put revXmlNodeContents(tID,tRootNode & "/Owner/ID") into tData["ownerID"]
   put revXmlNodeContents(tID,tRootNode & "/Owner/DisplayName") into tData["displayName"]
    
   put revXmlNumberOfChildren(tID, tRootNode & "/Buckets", "Bucket", 0) into tData["numBuckets"]
   put revXmlFirstChild(tID, tRootNode & "/Buckets") into tNode
   repeat
      put revXmlNodeContents(tId, tNode & "/Name") into tName
      put revXmlNodeContents(tId, tNode & "/CreationDate") into tData[tName, "CreationDate"]
       
      get revXmlNextSibling(tId, tNode)
      if it is empty then
         exit repeat
      else
         put it into tNode
      end if
   end repeat
   revDeleteXmlTree tID
    
   return tData
end listAllBucketsToArray

----------------------------------------

private function bucketToArray tXML
   put revCreateXMLTree(tXML,false,true,false) into tID
   put revXmlRootNode(tID) into tRootNode
   put revXmlNumberOfChildren(tID, tRootNode, "Contents", 0) into numKeys
   put tRootNode & "/Contents" into tNode
   repeat numKeys
      put revXmlNodeContents(tID, tNode & "/Key") into tKey
      put revXmlNodeContents(tID, tNode & "/LastModified") into tArray[tKey, "modified"]
      put s3DateToSecondsB(tArray[tKey, "modified"]) into tArray[tKey, "modified"]
      put revXmlNodeContents(tID, tNode & "/ETag") into tArray[tKey, "md5"]
      replace quote with empty in tArray[tKey, "md5"]
      put revXmlNodeContents(tID, tNode & "/Size") into tArray[tKey, "size"]
      add tArray[tKey, "size"] to tArray["totalSize"]

      put revXmlNextSibling(tID, tNode) into tNode
   end repeat
   revDeleteXmlTree tID
   return tArray
end bucketToArray

----------------------------------------


----------------------------------------



private function bucketNamesFromXml tXML
   put revCreateXMLTree(tXML,false,true,false) into tID
   put revXmlRootNode(tID) into tRootNode
   put revXmlFirstChild(tID, tRootNode & "/Buckets") into tNode
   repeat
      put revXmlNodeContents(tId, tNode & "/Name") & cr after tNames
       
      get revXmlNextSibling(tId, tNode)
      if it is empty then
         exit repeat
      else
         put it into tNode
      end if
   end repeat
   revDeleteXmlTree tID
    
   filter tNames without empty
   sort lines of tNames
   return tNames
end bucketNamesFromXml

----------------------------------------

private function objectNamesFromXml tXML
   put linerize(tXML) into tXML
   filter tXML with "<Key>*"
   replace "<Key>" with empty in tXML
   replace "</Key>" with empty in tXML
   filter tXML without empty
   sort lines of tXML
   return fixHtml(tXML)
end objectNamesFromXml

private function fixHtml pText
   if "&" is not in pText then return pText
   replace cr with "<p>" in pText
   set the htmltext of field "htmltemp" of me to pText
   return the text of field "htmltemp" of me
end fixHtml

----------------------------------------

private function headInfo pHeaders
   put word 2 to -1 of of line 1 of pHeaders into tArray["responseCode"]
   repeat for each line L in pHeaders
      if "Last-Modified" is in L then put s3DateToSeconds(word 2 to -1 of L) into tArray["modified"]
      if "ETag" is in L then 
         put word 2 to -1 of L into tArray["md5"]
         replace quote with empty in tArray["md5"]
      end if
      if "Content-Type" is in L then put word 2 to -1 of L into tArray["type"]
      if "Content-Length" is in L then put word 2 to -1 of L into tArray["size"]
   end repeat
   return tArray
end headInfo

----------------------------------------

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> sha1Internals

---------------------------------
-----SHA1 Digest-----------------
---------------------------------

local sChunks
local sSubChunks
local h1, h2, h3, h4, h5
local sBigEndian

----------------------------------

private command initSha1Locals
   put 1732584193 into h1
   put 4023233417 into h2
   put 2562383102 into h3
   put 271733878 into h4
   put 3285377520 into h5
   
   put empty into sChunks
   put empty into sSubChunks
   put (char 1 of (binaryencode("I",1)) is null) into sBigEndian
end initSha1Locals

----------------------------------

--  we have to end up with the input being a multiple
--  of 64 bytes (512 bits) in length.
--  we have to place a lonely "1" bit at the end of the string,
--  then pad with "0" bits, and finally append a 64 bit number
--  that is the length in bits of the original input.
--  Then, we convert the binary data to a Revolution-style
--  item-list of numbers, which we return.

private function preProcess @pString
   put length(pString) * 8 into tSizeInBits
    
   put tSizeInBits + 65 into tSize
    
   put 512 into tMinSize
   repeat while tMinSize < tSize
      add 512 to tMinSize
   end repeat
    
   put empty into tPadding
   repeat tMinSize - tSize
      put "0" after tPadding
   end repeat
    
   put "1" & tPadding & format("%064s",baseConvert(tSizeInBits,10,2)) into tTail
   put bitsToBin(tTail) after pString
    
   --  now we have a string of bytes, some multiple of 64 bytes in length,
   --  and we take 4 byte chunks of it and turn them into a comma separated
   --  list of revolution numbers.
   -----------------------------------------------------------------------
    
   return getUIntListBE(pString, 4)
end preProcess

----------------------------------

--  we take the list of numbers from preProcess()
--  and we put them into an array of chunks,
--  each chunk containing 16 numbers.

private command makeChunks @pMsg
   put 0 into numCount
   put 1 into chunkCount
    
   repeat for each item i in pMsg
      add 1 to numCount
       
      if numCount mod 16 <> 0 then
         put i & comma after sChunks[chunkCount]
      else
         put i after sChunks[chunkCount]
         add 1 to chunkCount
      end if
       
   end repeat
    
end makeChunks

----------------------------------

--  for the current chunk, we put each of it's 16 numbers into
--  an element of the (script local) sSubChunks array, calculating
--  a further 64 subChunks from there, ending up with a full chunk
--  of 80 sub-chunks.

private command makeSubChunks pChunkNum
    
   put sChunks[pChunkNum] into sSubChunks
   split sSubChunks by comma
    
   repeat with n = 17 to 80
      -- n-3 xor n-8 xor n-14 xor n-16
       
      put (sSubChunks[n-3] bitXor sSubChunks[n-8] bitXor sSubChunks[n-14] bitXor sSubChunks[n-16]) * 2 into tNum
       
      -- rotateLeft
      if tNum > 4294967295 then
         put tNum mod 4294967295 into r1
         if r1 = 0 then 
            put 4294967295 into r1
         end if
      else
         put tNum into r1
      end if
       
      put r1 into sSubChunks[n]
       
   end repeat
end makeSubChunks

----------------------------------

--  we process each of the 80 subChunks in turn,
--  updating the values in a,b,c,d,and e each time.
--  when all subChunks are processed, we add those values to the
--  hash values h1,h2,h3,h4 and h5.

private command processChunk
   put h1 into a
   put h2 into b
   put h3 into c
   put h4 into d
   put h5 into e
    
   repeat with n = 1 to 80
       
      if n < 21 then
         put (b bitAnd c) bitOr ((bitNot b) bitAnd d) into f
         put 1518500249 into k
      else if n < 41 then
         put (b bitXor c bitXor d) into f
         put 1859775393 into k
      else if n < 61 then
         put (b bitAnd c) bitOr (b bitAnd d) bitOr (c bitAnd d) into f
         put 2400959708 into k
      else
         put (b bitXor c bitXor d) into f
         put 3395469782 into k
      end if
       
      -- rotateLeft
      put a * (2 ^ 5) into tNum
      if tNum > 4294967295 then
         put tNum mod 4294967295 into r1
         if r1 = 0 then 
            put 4294967295 into r1
         end if
      else
         put tNum into r1
      end if
      put (r1 + f + e + k + sSubChunks[n]) mod 4294967296 into tTemp
       
      put d into e
      put c into d
       
      -- rotateLeft again
      put b * (2 ^ 30) into tNum
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
    
   put (h1 + a) mod 4294967296 into h1
   put (h2 + b) mod 4294967296 into h2
   put (h3 + c) mod 4294967296 into h3
   put (h4 + d) mod 4294967296 into h4
   put (h5 + e) mod 4294967296 into h5
    
end processChunk


----------------------------------
----------------------------------

-- now inline
--private function rotateLeft pNum, pSteps
--    if pNum = 0 then return 0
--    if pSteps is empty then put 1 into pSteps
--     
--    put pNum * (2 ^ pSteps) into tNum
--     
--    if tNum > 4294967295 then
--        put tNum mod 4294967295 into r1
--        if r1 = 0 then 
--            put 4294967295 into r1
--        end if
--    else
--        put tNum into r1
--    end if
--    return r1
--end rotateLeft


private function ms_sha1Digest pString
   initSha1Locals
    
   put preProcess(pString) into tMsg
   makeChunks tMsg
    
   repeat with n = 1 to the number of lines in the keys of sChunks
      makeSubChunks n
      processChunk
   end repeat
    
   put bitsToBin(decToBits(h1) & decToBits(h2) & decToBits(h3) & decToBits(h4) & decToBits(h5)) into tDigest
    
   initSha1Locals
   return tDigest
end ms_sha1Digest

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--
--> sha1Interface

function sha1.bin pString
   return sha1Digest(pString)
end sha1.bin

function sha1.hex pString
   return binToHex(sha1Digest(pString))
end sha1.hex

function sha1.b64 pString
   return bas64Encode(sha1Digest(pString))
end sha1.b64




--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> md5

function md5.bin @pString
   return md5digest(pString)
end md5.bin

function md5.hex @pString
   return binToHex(md5digest(pString))
end md5.hex

function md5.b64 @pString
   return base64encode(md5digest(pString))
end md5.b64

function fileMd5.bin pFile
   return shell("openssl md5 -binary" && q(pFile)) 
end fileMd5.bin

function fileMd5.hex pFile
   return word -1 of shell("openssl md5" && q(pFile))
end fileMd5.hex

function fileMd5.b64 pFile
   return base64encode(shell("openssl md5 -binary" && q(pFile)))
end fileMd5.b64

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> hmac

private function hmacMd5 pMsg, pKey
   if length(pKey) > 64 then put md5digest(pKey) into pKey
   repeat 64 - length(pKey)
      put null after pKey
   end repeat
    
   repeat for each char c in pKey
      put numtochar(chartonum(c) bitXor 54) after ipad
      put numtochar(chartonum(c) bitXor 92) after opad
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

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

private function hmacSha1 pMsg, pKey
   if length(pKey) > 64 then put sha1Digest(pKey) into pKey
   repeat 64 - length(pKey)
      put null after pKey
   end repeat
    
   repeat for each char c in pKey
      put numtochar(chartonum(c) bitXor 54) after ipad
      put numtochar(chartonum(c) bitXor 92) after opad
   end repeat
    
   return sha1Digest(opad & sha1Digest(ipad & pMsg))
end hmacSha1

function hmacSha1.hex pMsg, pKey
   return binToHex(hmacSha1(pMsg, pKey))
end hmacSha1.hex

function hmacSha1.b64 pMsg, pKey
   return base64encode(hmacSha1(pMsg, pKey))
end hmacSha1.b64

function hmacSha1.bin
   return hmacSha1(pMsg, pKey)
end hmacSha1.bin

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> utilities

private function binToHex pString
   repeat for each char c in pString
      get chartonum(c)
      put baseconvert(it,10,16) into tTemp
      if it < 16 then put "0" before tTemp
      put tTemp after tHex
   end repeat
   return tolower(tHex)
end binToHex

--------------------------------------

private function binToBits pString
   repeat for each char c in pString
      put format("%08s",baseConvert(chartonum(c),10,2)) into tTemp
      put tTemp after tBits
   end repeat
   return tBits
end binToBits

--------------------------------------

private function bitsToBin pBits
   repeat with n = 1 to length(pBits) - 8 step 8
      put char n to n + 7 of pBits into tNum
       
      put numtochar(baseconvert(tNum,2,10)) after tBin
   end repeat
   return tBin
end bitsToBin

--------------------------------------

private function decToBits pNum, pNumBits
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

--------------------------------------

private function decToHex pDec, pNumDigits
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

--------------------------------------

private function hexToBin pHex
   repeat with n = 1 to (length(pHex) - 1) step 2
      put numtochar(baseconvert(char n to n + 1 of pHex, 16, 10)) after tBin
   end repeat
   return tBin
end hexToBin

--------------------------------------

private function getUIntListBE pData, pSize, pDelim
   local tNum
   if pDelim is empty then put comma into pDelim
   repeat with n = 1 to length(pData) - (pSize - 1) step pSize
      put char n to n + (pSize - 1) of pData into pBytes
      if not sBigEndian then put reverseBytes(pBytes) into pBytes
      get binarydecode("I", pBytes, tNum)
      put tNum & comma after numList
   end repeat
   return char 1 to -2 of numList
end getUIntListBE

--------------------------------------

private function reverseBytes pBytes
   repeat for each char c in pBytes
      put c before nBytes
   end repeat
   return nBytes
end reverseBytes

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

--> other

private function gXEBN tName, tXML
   put offset("<" & tName & " ",tXML) into iChar
   if iChar = 0 then put offset("<" & tName & ">",tXML) into iChar
   if iChar = 0 then return empty
   get offset(">",tXML,iChar)
   if it = 0 then return empty
   put it + iChar + 1 into startChar
   get offset("</" & tName & ">",tXML)
   if it = 0 then return empty
   return char startChar to it - 1 of tXML
end gXEBN


private function q pStr
   return quote & pStr & quote
end q

private function sq pStr
   return "'" & pStr & "'"
end sq

private function getFileNameFromPath pPath
   set the itemdelimiter to "/"
   return item -1 of pPath
end getFileNameFromPath

-----

private function getPathWithoutFileName pPath
   set the itemdelimiter to "/"
   return item 1 to -2 of pPath & "/"
end getPathWithoutFileName

-----

private function getFileInfo pFile
   put getPathWithoutFileName(pFile) into tFolderName
   put getFileNameFromPath(pFile) into tFileName
   put the directory into tOldFolder
   set the directory to tFolderName
   put urldecode(the detailed files) into tFileList
    
   repeat for each line L in tFileList
      if item 1 of L is tFileName then
         put L into tInfo
         exit repeat
      end if
   end repeat
    
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
   put getContentType(pFile) into tFileInfo["ContentType"]
   put fileMd5.b64(pFile) into tFileInfo["md5.b64"]
   put fileMd5.hex(pFile) into tFileInfo["md5.hex"]
    
   set the directory to tOldFolder
   return tFileInfo
end getFileInfo

----------------------------------------

private function getContentType pFile
   set the itemdelimiter to "."
   put "." & item -1 of pFile into tExtension
   get the mimeTypes[tExtension] of me
   if it is empty then
      return "binary/octet-stream"
   else
      return it
   end if
end getContentType

----------------------------------------

private function s3DateToSeconds pDate
   replace "GMT" with 0 in pDate
   convert pDate from internet date to seconds
   return pDate
end s3DateToSeconds

private function s3DateToSecondsB pDate
   replace "-" with comma in pDate
   replace "T" with comma in pDate
   replace ":" with comma in pDate
   replace "." with comma in pDate
   put 0 into item -1 of pDate
   convert pDate from dateItems to seconds
   return pDate
end s3DateToSecondsB


private function secondsToS3Date pSecs
   convert pSecs from seconds to internet date
   return pSecs
end secondsToS3Date

private function isPackage pFolder
    put revMacFromUnixPath(pFolder) & ":" into pFolder
    put "package folder of (info for alias " & quote & pFolder & quote & ")" into tScr
    do tScr as applescript
    return the result
end isPackage


private function thePackages pFolder
    put revMacFromUnixPath(pFolder) into pFolder
    
    put "tell application" && quote & "Finder" & quote & cr & "packages of folder" \
    && quote & pFolder & quote & cr & "end tell" into tScr
    do tScr as applescript
    put the result into tList
    replace comma with cr in tList
     
    repeat for each line L in tList
        get wordoffset("file", L)
        put word it + 1 of L & cr after tPackages
    end repeat
    replace quote with empty in tPackages
    return char 1 to -2 of tPackages
end thePackages

--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--

function linerize pData
   replace "><" with ">" & cr & "<" in pData
   return pData
end linerize
