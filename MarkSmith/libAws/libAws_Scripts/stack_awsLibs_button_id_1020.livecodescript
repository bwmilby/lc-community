Script "stack_awsLibs_button_id_1020"

/*
# Name: button "s3" of card id 1002 of stack "awsLibs"
# ID: button id 1020 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
libRevS3
version: 2.0b
date: 20090617
Author Mark Smith
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> locals & constants

constant kS3url = "s3.amazonaws.com"
local sUseHttps = false
local sCancel = false
local sAkey
local sSkey

-----
--> global functions


on s3.cancel
   put true into sCancel
end s3.cancel

-----

on s3.setSecure pBool
   put (pBool is true) into sUseHttps
end s3.setSecure

-----


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> interface simple
---------------------------

function s3.store pS3path, pData, pCannedAcl, pMetaTags
   if char 1 to 5 of pData is "file:" then
      put s3.putFile.curl(pS3path, char 6 to -1 of pData, pCannedAcl, \
            pMetaTags) into tCurl
   else
      put s3.putData.curl(pS3path, pData, pCannedAcl, pMetaTags) into tCurl
   end if
   
   try
      put curl.runTilDone(tCurl) into tRes
      put s3.response(tRes) into tResponse
      if tResponse["status"] is "error" then
         return tResponse["curlerror"] & cr & tResponse["Code"]
      else
         return empty
      end if
      
   catch tError
      return "libRevS3 error: couldn't store" && pS3path
   end try
end s3.store

-----

function s3.fetch pS3path, pDestFile
   if pDestFile is not empty then
      put s3.getFile.curl(pS3path, pDestFile) into tCurl
   else
      put s3.getData.curl(pS3path) into tCurl
   end if
   
   try
      put curl.runTilDone(tCurl) into tRes
      put s3.response(tRes) into tResponse
      if tResponse["status"] is "error" then
         return tResponse["curlerror"] & cr & tResponse["Code"]
      else
         if pDestFile is empty then
            return tResponse
         else
            return empty
         end if
      end if
   catch tError
      return "libRevS3 error:' couldn't fetch" && pS3path
   end try
end s3.fetch

-----

function s3.info pS3path
   if char 1 of pS3path is "/" then delete char 1 of pS3path
   
   try
      if pS3path is empty then
         put s3.listAllMyBuckets() into tResult
      else
         set the itemdelimiter to "/"
         if item 2 of pS3path is empty then
            put s3.listBucket(pS3path) into tResult
         else
            put s3.listObject(pS3path) into tResult
            if tResult begins with "error:" then return tResult
            combine tResult by cr and "="
         end if
      end if
      return tResult
   catch tError
      return "libRevS3 error: couldn't get info for" && pS3path
   end try
end s3.info


-----

function s3.delete pS3Path
   if pS3path is empty then return "libRevS3 error: no object specified"
   
   try
      put s3.deleteObject(pS3path) into tArray
      if tArray is an array then
         return tArray["curlerror"] & comma & tArray["Code"]
      else
         return empty
      end if
   catch tError
      return "libRevS3 error: couldn't delete" && pS3path
   end try
end s3.delete

-----

function s3.fs pS3path, pWhat, pFullPaths, pDetailed
   if char 1 of pS3path is "/" then delete char -1 of pS3path
   if pS3path is empty then return s3.listAllMyBuckets()
   
   set the itemdelimiter to "/"
   put item 1 of pS3path into tBucket
   if tBucket is empty then return empty
   put item 2 to -1 of pS3path into tPrefix
   if (tPrefix is not empty) and (char -1 of tPrefix is not "/") then \
         put "/" after tPrefix
   put s3.listBucket(tBucket, "array", tPrefix, "/") into tRes
   
   put tBucket into tRes["bucketname"]
   switch pWhat
      case "files"
      case "f"
         put fsfiles(tRes, pFullPaths, pDetailed) into tReturn
         break
      case "folders"
      case "d"
         put fsfolders(tRes, pFullPaths) into tReturn
         break
      case "fd"
      default
         put fsfiles(tRes, pFullPaths, pDetailed) into tReturn["files"]
         put fsfolders(tRes, pFullPaths) into tReturn["folders"]
         break
   end switch
   return tReturn
end s3.fs

-----

function s3.bucketWalk pFo
   put s3.fs(pFo) into tArray
   repeat for each line L in tArray["files"]
      put pFo & "/" & L & cr after tList
   end repeat
   repeat for each line L in tArray["folders"]
      put pFo & "/" & L into nFo
      put s3.bucketWalk(nFo) & cr after tList
   end repeat
   return tList
end s3.bucketWalk


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> interface array
-------------------------------

on s3a.request tRequest
   
end s3a.request

function s3a.request.curl tRequest
   switch tRequest["action"]
      case "copyObject"
         
         break
      case "listObject"
         
         break
   end switch
end s3a.request.curl

function s3a.copyObject pArray
   put "PUT" into tQarray["httpMethod"]
   put pArray["dest"] into tQarray["s3path"]
   put pArray["source"] into tQarray["x-amz-copy-source"]
   
   put "COPY" into tQarray["x-amz-metadata-directive"]
   get pArray["metaCopyReplace"]
   if it is not empty then put it into tQarray["x-amz-metadata-directive"]
   
   get pArray["ifmatch"]
   if it is not empty then put it into tQarray["x-amz-copy-source-if-match"]
   
   get pArray["ifnomatch"]
   if it is not empty then
      put it into tQarray["x-amz-copy-source-if-none-match"]
      delete variable tQarray["x-amz-copy-source-if-match"]
   end if
   
   get pArray["ifmodified"]
   if it is not empty then \
         put it into tQarray["x-amz-copy-source-if-modified-since"]
   
   get pArray["ifunmodified"]
   if it is not empty then
      put it into tQarray["x-amz-copy-source-if-unmodified-since"]
      delete variable tQarray["x-amz-copy-source-if-modified-since"]
   end if
   
   repeat for each key k in pArray
      if k begins with "x-amz-meta-" then put pArray[k] into tQarray[k]
   end repeat
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3a.copyObject

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> interface advanced
-------------------------------

function s3.putData.curl pS3path, pData, pCannedAcl, pMetaTags
   
   put md5.b64(pData) into tQarray["Content-MD5"]
   put getContentType(pObject)  into tQarray["Content-Type"]
   put length(pData) into tQarray["Content-Length"]
   
   put the tempname into tQarray["inputfile"]
   writeBinFile tQarray["inputfile"], pData
   put pS3path into tQarray["s3path"]
   
   put "PUT" into tQarray["httpMethod"]
   put s3.cannedAcl(pCannedAcl) into tQarray["x-amz-acl"]
   
   makeMetaTags tQarray, pMetaTags
   
   put s3.curl(tQarray) into tCurl
   curl.setDeleteInputfile tCurl, true
   return tCurl
   
end s3.putData.curl

-----

function s3.putData pS3path, pData, pCannedAcl, pMetaTags
   put s3.putData.curl(pS3path, pData, pCannedAcl, pMetaTags) into tCurl
   put curl.runTilDone(tCurl) into tRes
   if "200 OK" is not in tRes then
      return tRes
   else
      return empty
   end if
end s3.putData

-----

function s3.getData.curl pS3path, pRange
   put pS3path into tQarray["s3path"]
   put "GET" into tQarray["httpMethod"]
   get s3.checkRange(pRange)
   if it is not empty then put "bytes=" & it into tQarray["Range"]
   return s3.curl(tQarray)
end s3.getData.curl

-----

function s3.getData pS3path, pRange
   put s3.getData.curl(pS3path, pRange) into tCurl
   put curl.runTilDone(tCurl) into tRes
   return s3.response(tRes)
end s3.getData

-----

function s3.putFile.curl pS3path, pFile, pCannedAcl, pMetaTags
   put getBigFileInfo(pFile, true) into tInfo
   
   put tInfo["md5.b64"] into tQarray["Content-MD5"]
   put tInfo["ContentType"] into tQarray["Content-Type"]
   put tInfo["size"] into tQarray["Content-Length"]
   put tInfo["fullPathName"] into tQarray["inputFile"]
   makeMetaTags tQarray, pMetaTags
   
   put pS3path into tQarray["s3path"]
   put "PUT" into tQarray["httpMethod"]
   put s3.cannedAcl(pCannedAcl) into tQarray["x-amz-acl"]
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.putFile.curl

-----

function s3.putFile pS3path, pFile, pCannedAcl, pFormat, pMetaTags
   put s3.putFile.curl(pS3path, pFile, pCannedAcl, pMetaTags) into tCurl
   put curl.runTilDone(tCurl) into tRes
   --if "<?xml" is in tRes then return s3xml.simpleResponse(tRes)
   return s3.response(tRes)
end s3.putFile

-----

function s3.putFileConfig pS3path, pFileInfo, pCannedAcl, pMetaTags
   put pFileInfo["md5.b64"] into tQarray["Content-MD5"]
   put pFileInfo["ContentType"] into tQarray["Content-Type"]
   put pFileInfo["size"] into tQarray["Content-Length"]
   put pFileInfo["fullPathName"] into tQarray["inputFile"]
   makeMetaTags tQarray, pMetaTags
   
   put pS3path into tQarray["s3path"]
   put "PUT" into tQarray["httpMethod"]
   put s3.cannedAcl(pCannedAcl) into tQarray["x-amz-acl"]
   
   put s3.curl(tQarray) into tCurl
   put curl.portableConfig(tCurl) into tConfig
   curl.cleanup tCurl
   
   repeat for each item i in \
         "configfile,outputfile,process,deleteoutputfile,status"
      delete variable tConfig[i]
   end repeat
   
   return tConfig
end s3.putFileConfig

-----

function s3.postFile.curl pS3path, pFile, pExpiry, pAcl
   if (pExpiry is not an integer) or (pExpiry < 1) then \
         put the seconds + 30 into pExpiry
   set the itemdelimiter to "/"
   put item 1 of pS3path into tBucket
   
   put item 2 to -1 of pS3path into tFD["key"]
   put s3.cannedAcl(pAcl) into tFD["acl"]
   put "201" into tFD["success_action_status"]
   put getContentType(pFile) into tFD["Content-Type"]
   put getAwsAccessKey() into tFD["AWSAccessKeyId"]
   put postFilePolicy(tBucket, tFD, pExpiry) into tFD["Policy"]
   put hmacSha1.b64(tFD["Policy"], getAwsSecretkey()) into tFD["Signature"]
   put pFile into tFD["file"]
   
   put curl.new() into tCurl
   curl.setUrl tCurl, "http://" & tBucket & ".s3.amazonaws.com"
   curl.setMultiPartFormData tCurl, tFD
   
   return tCurl
end s3.postFile.curl

-----

function s3.postFile pS3path, pFile, pExpiry, pCannedAcl
   put s3.postFile.curl(pS3path, pFile, pExpiry, pCannedAcl) into tCurl
   put curl.runTilDone(tCurl) into tRes
   return s3.response(tRes)
end s3.postFile

-----

function s3.getFile.curl pS3path, pFile, pRange
   put pS3path into tQarray["s3path"]
   put pFile into tQarray["outputfile"]
   put "GET" into tQarray["httpMethod"]
   get s3.checkRange(pRange)
   if it is not empty then put "bytes=" & it into tQarray["Range"]
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.getFile.curl

-----

function s3.getFile pS3path, pFile, pRange
   put s3.getFile.curl(pS3path, pFile, pRange) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return s3.response(tResponse)
end s3.getFile

-----

function s3.deleteObject.curl pS3path
   put pS3path into tQarray["s3path"]
   put "DELETE" into tQarray["httpMethod"]
   
   return s3.curl(tQarray)
end s3.deleteObject.curl

-----

function s3.deleteObject pS3path
   put s3.deleteObject.curl(pS3path) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return s3.response(tResponse)
end s3.deleteObject

-----

function s3.deleteBucket pBucket
   put s3.deleteObject.curl(pBucket) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return s3.response(tResponse)
end s3.deleteBucket

-----

function s3.listObject pS3path
   put s3.listObject.curl(pS3path) into tCurl
   --put curl.runTilDone(tCurl) into tResponse
   --if tResponse begins with "error:" then return s3.simpleError(tResponse)
   
   curl.execute tCurl
   wait until curl.done(tCurl) with messages
   put curl.response(tCurl) into tResponse
   put curl.error(tCurl) into tError
   curl.cleanup tCurl
   
   put httpHeadersToArray(word 1 to -1 of tResponse) into tArray
   put pS3path into tArray["objectKey"]
   return tArray
end s3.listObject

function s3.listObject.curl pS3path
   put pS3path into tQarray["s3path"]
   put "HEAD" into tQarray["httpMethod"]
   
   return s3.curl(tQarray)
end s3.listObject.curl

-----

function s3.copyObject.curl pSourceS3path, pDestS3path, pCannedAcl, \
      pCopyMeta, pMetaTags
   put pDestS3path into tQarray["s3path"]
   
   if char 1 of pSourceS3path is not "/" then put "/" before pSourceS3path
   
   put urlencode(utf8encode(pSourceS3path)) into tQarray["x-amz-copy-source"]
   
   if pCopyMeta then
      put "COPY" into tQarray["x-amz-metadata-directive"]
   else
      put "REPLACE" into tQarray["x-amz-metadata-directive"]
   end if
   
   if (pMetaTags is not empty) or (keys(pMetaTags) is not empty) then
      makeMetaTags tQarray, pMetaTags
      put "REPLACE" into tQarray["x-amz-metadata-directive"]
   end if
   
   put s3.cannedAcl(pCannedAcl) into tQarray["x-amz-acl"]
   
   put "PUT" into tQarray["httpMethod"]
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.copyObject.curl

-----

function s3.copyObject pSourceS3path, pDestS3path, pCannedAcl, \
      pCopyMeta, pMetaTags
   put s3.copyObject.curl(pSourceS3path, pDestS3Path, pCannedAcl, pCopyMeta, \
         pMetaTags) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   return s3.response(tResponse)
end s3.copyObject

-----

function s3.createBucket.curl pBucket, pCannedAcl, pLocation
   if not bucketNameGood(pBucket) then return "error: bad bucket name"
   put pBucket into tQarray["bucket"]
   put "PUT" into tQarray["httpMethod"]
   put s3.cannedAcl(pCannedAcl) into tQarray["x-amz-acl"]
   
   if pLocation is "EU" then
      put "<CreateBucketConfiguration><LocationConstraint>EU" & \
            "</LocationConstraint></CreateBucketConfiguration>" into pLocXml
      put length(pLocXml) into tQarray["Content-Length"]
   end if
   
   put s3.pathStyleCurl(tQarray) into tCurl
   if pLocation is "EU" then curl.setPutData tCurl, pLocXml
   
   return tCurl
end s3.createBucket.curl

-----

function s3.createBucket pBucket, pCannedAcl, pLocation
   if not bucketNameGood(pBucket) then return "error: bad bucket name"
   put s3.createBucket.curl(pBucket, pCannedAcl, pLocation) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return s3.response(tResponse)
   --if tResponse begins with "error:" then return s3.simpleError(tResponse)
   --return empty
end s3.createBucket

-----

function s3.bucketExists pBucket
   put "http://" & pBucket & ".s3.amazonaws.com/" into tUrl
   put url tUrl into tRes
   return "NoSuchBucket" is not in tRes
end s3.bucketExists

-----

function s3.listBucket pBucket, pFormat, pPrefix, pDelimiter, pMarker, pMaxkeys
   put false into sCancel
   put "GET" into tQarray["httpMethod"]
   put pBucket into tQarray["bucket"]
   
   put true into theresMore
   repeat while theresMore and not sCancel and \
         (tResponseArray["request"]["status"] is not "error")
      add 1 to requestCount
      put makeSubResource(pPrefix, pDelimiter, pMarker, pMaxKeys) \
            into tQarray["subresource"]
      
      put s3.curl(tQarray) into tCurl
      put curl.runTilDone(tCurl) into tResponse
      
      if tResponse begins with "error:" then return s3.simpleError(tResponse)
      
      put s3xml.listBucket(tResponse) into tResponseArray
      put tResponseArray["request"]["IsTruncated"] into theresMore
      put tResponseArray["request"]["nextMarker"] into pMarker
      
      
      if pFormat is "xml" then
         put linerize(tResponse) into tXmlArray[requestCount]
      else
         repeat for each key k in tResponseArray["objects"]
            put tResponseArray["objects"][k] into tResArray["objects"][k]
         end repeat
         if tResponseArray["prefixes"] is not empty then \
               put tResponseArray["prefixes"] & cr after tResArray["prefixes"]
      end if
      
   end repeat
   
   switch pFormat
      case "xml"
         return tXmlArray
         break
      case "array"
      case "complete"
         return tResArray
         break
      case "list"
      default
         get keys(tResArray["objects"])
         sort lines of it
         return it
         break
   end switch
end s3.listBucket

-----

function s3.listBucket.curl pBucket, pPrefix, pDelimiter, pMarker, pMaxkeys
   put "GET" into tQarray["httpMethod"]
   put pBucket into tQarray["bucket"]
   put makeSubResource(pPrefix, pDelimiter, pMarker, pMaxkeys) \
         into tQarray["subresource"]
   
   return s3.curl(tQarray)
end s3.listBucket.curl

-----

function s3.listAllMyBuckets pFormat
   put "GET" into tQarray["httpMethod"]
   put s3.curl(tQarray) into tCurl
   
   --put curl.runTilDone(tCurl) into tResponse
   --if tResponse begins with "error:" then return s3.simpleError(tResponse)
   --put s3xml.listAllMyBuckets(tResponse) into tArray
   
   curl.execute tCurl
   wait until curl.done(tCurl) with messages
   put curl.response(tCurl) into tResponse
   put curl.error(tCurl) into tError
   curl.cleanup tCurl
   
   
   
   switch pFormat
      case "raw"
      case "xml"
         if tResponse is empty then put tError into tResponse
         return tResponse
         break
      case "array"
      case "complete"
         put s3.response(tError & tResponse) into tArray
         return tArray
         break
      case "list"
      default
         put s3.response(tError & tResponse) into tArray
         if tArray["status"] is "error" then
            return tArray["curlerror"] & comma & tArray["Code"]
         else
            put the keys of tArray["buckets"] into tList
            sort lines of tList
            return tList
         end if
         break 
   end switch
end s3.listAllMyBuckets


-----|-----|-----

function s3.getAcl.curl pS3path
   put "GET" into tQarray["httpMethod"]
   put pS3path into tQarray["s3path"]
   put  "acl" into tQarray["subresource"]
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.getAcl.curl

-----

function s3.getAcl pS3path, pFormat
   put s3.getAcl.curl(pS3path) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if pFormat is "xml" then
      return linerize(tResponse)
   else
      put s3.response(tResponse) into tArray
      return tArray
   end if
end s3.getAcl

-----|-----|-----

function s3.setAcl.curl pS3path, pAcl
   put pS3path into tQarray["s3path"]
   put "PUT" into tQarray["httpMethod"]
   put length(pAcl) into tQarray["Content-Length"]
   put "acl" into tQarray["subresource"]
   
   put s3.curl(tQarray) into tCurl
   curl.setPutData tCurl, pAcl
   return tCurl
end s3.setAcl.curl

-----

function s3.setAcl pS3path, pAcl
   put s3.setAcl.curl (pS3path, pAcl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return tResponse
end s3.setAcl

-----|-----|-----

function s3.addGrant pGrantee, pPermission, pType
   
end s3.addGrant

-----|-----|-----

function s3.getLogging.curl pBucket
   put pBucket into tQarray["bucket"]
   put "GET" into tQarray["httpMethod"]
   put  "logging" into tQarray["subresource"]
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.getLogging.curl

-----

function s3.getLogging pBucket
   put s3.getLogging.curl(pBucket) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return s3.response(tResponse)
end s3.getLogging

-----|-----|-----

function s3.setLogging.curl pBucket, pLogging
   put pBucket into tQarray["bucket"]
   put "PUT" into tQarray["httpMethod"]
   put "logging" into tQarray["subresource"]
   put length(pLogging) into tQarray["Content-Length"]
   
   put s3.curl(tQarray) into tCurl
   curl.setPutData tCurl, pLogging
   return tCurl
end s3.setLogging.curl

-----

function s3.setLogging pBucket, pLogging
   put s3.setLogging.curl(pBucket, pLogging) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   return tResponse
end s3.setLogging

-----|-----|-----

function s3.getLocation.curl pBucket
   put pBucket into tQarray["bucket"]
   put "GET" into tQarray["httpMethod"]
   put "location" into tQarray["subresource"]
   
   put s3.curl(tQarray) into tCurl
   return tCurl
end s3.getLocation.curl

-----

function s3.getLocation pBucket
   set the itemdelimiter to "/"
   delete item 2 to -1 of pBucket
   put s3.getLocation.curl(pBucket) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   put s3.response(tResponse) into tArray
   if tArray["status"] is "ok" then
      return tArray["location"]
   else
      return tArray["curlerror"] & comma & tArray["Code"]
   end if
end s3.getLocation

-----|-----|-----

-- tExpiry is the time that the url expires in seconds since mdnight, 01/01/1970 GMT

function s3.authenticatedUrl pS3path, pExpiry
   switch pExpiry
      case "hour"
         put 3600 + the seconds into tExpiry
         break
      case "day"
         put 86400 + the seconds into tExpiry
         break
      case "week"
         put 604800 + the seconds into tExpiry
         break
      case "month"
         put 2592000 + the seconds into tExpiry
         break
      case "year"
         put 31536000 + the seconds into tExpiry
         break
      default
         if pExpiry is an integer then put pExpiry + the seconds into tExpiry
         break    
   end switch
   if tExpiry is not an integer or tExpiry < 0 then return "invalid expiry"
   
   put "/" & pS3path into tUri
   put "GET" & cr & cr & cr & tExpiry & cr & tUri into stringToSign
   
   put hmacSha1.b64(stringToSign, getAwsSecretkey()) into tSignature
   
   put makeVHurl(pS3path) into tUrl
   put "?AWSAccessKeyId=" & getAwsAccessKey() after tUrl
   put "&Expires=" & tExpiry & "&Signature=" & tSignature after tUrl
   return tUrl
end s3.authenticatedUrl

-----

function s3.torrent pS3path, pDest
   if char -8 to -1 of pDest is not ".torrent" then put ".torrent" after pDest
   set the itemdelimiter to "/"
   put "http://" & item 1 of pS3path & "." & kS3url & "/" & \
         item 2 to -1 of pS3path & "?torrent" into tUrl
   
   put curl.new() into tCurl
   curl.setUrl tCurl, tUrl
   if pDest is not empty then curl.setOutputFile tCurl, pDest
   put curl.runTilDone(tCurl) into tResponse
   return tResponse
end s3.torrent


-----

function s3.getBucketInfo pBucket
   put s3.getAcl.curl(pBucket) into tAclCurl
   curl.execute tAclCurl
   wait 10 millisecs with messages
   put s3.getLogging.curl(pBucket) into tLogCurl
   curl.execute tLogCurl
   wait 10 millisecs with messages
   put s3.getLocation.curl(pBucket) into tLocCurl
   curl.execute tLocCurl
   wait 10 millisecs with messages
   
   put 0 into numDone
   repeat until numDone >= 3
      if the optionkey is down then exit repeat
      if curl.done(tAclCurl) then
         put curl.response(tAclCurl) into tArray["acl"]
         add 1 to numDone
      end if
      
      if curl.done(tLogCurl) then
         put curl.response(tLogCurl) into tArray["logging"]
         add 1 to numDone
      end if
      
      if curl.done(tLocCurl) then
         put curl.response(tLocCurl) into tArray["location"]
         add 1 to numDone
      end if
      wait 50 millisecs with messages
   end repeat
   
   curl.cleanup tAclCurl
   curl.cleanup tLogCurl
   curl.cleanup tLocCurl
   
   put s3xml.getAcl(tArray["acl"]) into tArray["acl"]
   put s3xml.getLogging(tArray["logging"]) into tArray["logging"]
   if "EU" is in tArray["location"] then
      put "EU" into tArray["location"]
   else
      put "US" into tArray["location"]
   end if
   
   return tArray
end s3.getBucketInfo

-------------

on s3.emptyBucket pBucket
   
   repeat
      put empty into tObjectList
      put s3.listBucket(pBucket,,,,, 100) into tObjects
      if tObjects is empty then
         exit repeat
      else
         repeat for each line L in tObjects
            put pBucket & "/" & L & cr after tObjectList
         end repeat
         s3.multiDelete tObjectList
         wait until s3.multiDeleteDone() with messages
      end if
   end repeat
   
end s3.emptyBucket

-----

function s3.BucketNameStrictCheck pName
   get length(pName)
   if it < 3 or it > 63 then return false
   if not matchtext(pName,"^[a-z0-9 .+-]+$") then return false
   if char 1 of pName is "." then return false
   if "-." is in pName then return false
   if ".-" is in pName then return false
   return true
end s3.BucketNameStrictCheck


---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> multiDelete
----------------

local sDeleteObjects
local sDeleteErrors
local sDeleteState
local sDeleteCurls

-----

# takes a newline delimited list of full s3 object keys (ie. including bucket
# name) and deletes them as simultaneously as curl.maxCurls allows

on s3.multiDelete pObjectList
   put pObjectList into sDeleteObjects
   put empty into sDeleteErrors
   put empty into sDeleteCurls
   
   put "running" into sDeleteState["status"]
   put the number of lines in sDeleteObjects into sDeleteState["numItems"]
   put 0 into sDeleteState["numDone"]
   put false into sCancel
   send "s3priv_doMultiDelete" to me in 2 millisecs
end s3.multiDelete

-----

on s3priv_doMultiDelete
   repeat for each line L in sDeleteObjects
      if sCancel then
         doDeleteCancel
         exit repeat
      else
         put s3.deleteObject.curl(L) into tCurl
         put L into sDeleteCurls[tCurl]
         curl.execute tCurl
         if "s3priv_checkMultiDelete" is not in the pendingmessages then \
               send "s3priv_checkMultiDelete" to me in 10 millisecs
         wait 10 millisecs with messages
      end if
   end repeat
end s3priv_doMultiDelete

-----

on s3priv_checkMultiDelete
   if sCancel then
      doDeleteCancel
   else
      repeat for each key tCurl in sDeleteCurls
         if curl.done(tCurl) then
            get curl.response(tCurl)
            if "204 No Content" is not in it then \
                  put it into sDeleteErrors[sDeleteCurls[tCurl]]
            curl.cleanup tCurl
            delete variable sDeleteCurls[tCurl]
            add 1 to sDeleteState["numDone"]
         end if
      end repeat
      
      if (sDeleteState["numDone"] < sDeleteState["numItems"]) then
         send "s3priv_checkMultiDelete" to me in 50 millisecs
      else
         put "done" into sDeleteState["status"]
         finishMultiDelete
      end if
   end if
end s3priv_checkMultiDelete

-----

private command doDeleteCancel
   cancelMessages "s3checkMultiDelete"
   repeat for each key tCurl in sDeleteCurls
      curl.cancel tCurl
      curl.cleanup tCurl
   end repeat
   put "cancelled" into sDeleteState["status"]
end doDeleteCancel

-----

private command finishMultiDelete
   put empty into sDeleteObjects
   put empty into sDeleteCurls
end finishMultiDelete

-----

on s3.multiDeleteCancel
   put true into sCancel
end s3.multiDeleteCancel

function s3.multiDeleteStatus
   return sDeleteState
end s3.multiDeleteStatus

function s3.multiDeleteDone
   return sDeleteState["status"] is in "cancelled,error,done"
end s3.multiDeleteDone

function s3.multiDeleteErrors
   return sDeleteErrors
end s3.multiDeleteErrors

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> multiGet
------------------

local sGetObjects
local sGetData
local sGetState
local sGetCurls

on s3.multiGet pObjectList
   put pObjectList into sGetObjects
   put empty into sGetCurls
   put false into sCancel
   
   put "running" into sGetState["status"]
   put the number of lines in sGetObjects into sGetState["numItems"]
   put 0 into sGetState["numDone"]
   send "s3priv_doMultiGet" to me in 2 millisecs
end s3.multiGet

-----

on s3priv_doMultiGet
   repeat for each line L in sGetObjects
      if sCancel then
         doGetCancel
         exit repeat
      else
         wait 10 millisecs with messages
         put s3.getData.curl(L) into tCurl
         put L into sGetCurls[tCurl]
         curl.execute tCurl
         if "s3priv_checkMultiGet" is not in the pendingmessages then \
               send "s3priv_checkMultiGet" to me in 10 millisecs
      end if
   end repeat
end s3priv_doMultiGet

-----

on s3priv_checkMultiGet
   if sCancel then
      doGetCancel
   else
      repeat for each key tCurl in sGetCurls
         if curl.done(tCurl) then
            put curl.response(tCurl) into sGetData[sGetCurls[tCurl]]
            curl.cleanup tCurl
            put empty into sGetCurls[tCurl]
            add 1 to sGetState["numDone"]
         end if
      end repeat
      
      if (sGetState["numDone"] < sGetState["numItems"]) then
         send "s3priv_checkMultiGet" to me in 100 millisecs
      else
         put "done" into sGetState["status"]
         finishMultiGet
      end if
   end if
end s3priv_checkMultiGet

-----

private command doGetCancel
   cancelMessages "s3checkMultiGet"
   repeat for each key tCurl in sGetCurls
      curl.cancel tCurl
      curl.cleanup tCurl
   end repeat
   put "cancelled" into sGetState["status"]
end doGetCancel

-----

private command finishMultiGet
   put empty into sGetObjects
   put empty into sGetCurls
end finishMultiGet

-----

on s3.multiGetCancel
   put true into sCancel
end s3.multiGetCancel

function s3.multiGetStatus
   return sGetState
end s3.multiGetStatus

function s3.multiGetDone
   return sGetState["status"] is in "cancelled,error,done"
end s3.multiGetDone

function s3.multiGetData
   return sGetData
end s3.multiGetData

on s3.multiGetCleanup
   finishMultiGet
   put empty into sGetData
   put empty into sGetState
end s3.multiGetCleanup

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> multiPut
------------------

local sPutData
local sPutState
local sPutCurls


on s3.multiPut pPutArray
   put pPutArray into sPutData
   put empty into sPutCurls
   put false into sCancel
   
   put "running" into sPutState["status"]
   put the number of lines in keys(sPutData) into sGetState["numItems"]
   put 0 into sGetState["numDone"]
   send "s3priv_doMultiPut" to me in 2 millisecs
end s3.multiPut

-----

on s3priv_doMultiPut
   repeat for each line L in keys(sPutData)
      if sCancel then
         doPutCancel
         exit repeat
      else
         wait 10 millisecs with messages
         put s3.putData.curl(L, sPutData[L]) into tCurl
         put L into sGetCurls[tCurl]
         curl.execute tCurl
         if "s3priv_checkMultiPut" is not in the pendingmessages then \
               send "s3priv_checkMultiPut" to me in 10 millisecs
      end if
   end repeat
end s3priv_doMultiPut

-----

on s3priv_checkMultiPut
   
end s3priv_checkMultiPut

-----

private command doPutCancel
   
end doPutCancel

-----

private command finishMultiPut
   
end finishMultiPut

-----

on s3.multiPutCancel
   put true into sCancel
end s3.multiPutCancel

function s3.multiPutStatus
   return sPutState
end s3.multiPutStatus

function s3.multiPutDone
   return sPutState["status"] is in "cancelled,error,done"
end s3.multiPutDone

function s3.multiPutErrors
   
end s3.multiPutErrors

on s3.multiPutCleanup
   
end s3.multiPutCleanup

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> multiCopy
# the manifest should be a numerically indexxed array in which each element is
# an array of <source><destination>
------------------

local sCopyManifest
local sCopyCurls
local sCopyState


on s3.multiCopy pCopyList
   put pCopyList into sCopyManifest
   put empty into sCopyCurls
   put false into sCancel
   
   put "running" into sCopyState["status"]
   put the number of lines in keys(sCopyManifest) into sCopyState["numItems"]
   put 0 into sCopyState["numDone"]
   send "doMultiCopy" to me in 2 millisecs
end s3.multiCopy

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> internals
------------------

private function i.vhUrl pBucket
   if sUseHttps then
      put "https://" into tUrl
   else
      put "http://" into tUrl
   end if
   
   if pBucket is not empty then put pBucket & "." after tUrl
   put kS3url & "/" after tUrl
   return tUrl
end i.vhUrl

private function s3BaseUrl vh
   if sUseHttps then
      return "https://" & kS3url
   else
      return "http://" & kS3url
   end if
end s3BaseUrl

-----

private function s3.curl pArray
   ### all params must be utf-8
   repeat for each key k in pArray
      put utf8encode(pArray[k]) into pArray[k]
   end repeat
   
   ### need to separate out bucket and object for the authentication and url
   if pArray["s3path"] is not empty then
      set the itemdelimiter to "/"
      put item 1 of pArray["s3path"] into pArray["bucket"]
      put urlencode(item 2 to -1 of pArray["s3path"]) into pArray["object"]
      set the itemdelimiter to comma
   end if
   put the internet date into pArray["Date"]
   
   put authString.s3(pArray) into pArray["Authorization"]
   
   ### make the 'virtual host' style url ie. http://myBucket.s3.amazonaws.com
   put i.vhUrl(pArray["bucket"]) into tUrl
   if pArray["object"] is not empty then put pArray["object"] after tUrl
   if pArray["subresource"] is not empty then put "?" & pArray["subresource"] \
         after tUrl
   put 0 into tCurl
   
   ### get a curl instance
   repeat  until tCurl > 0 or sCancel
      put curl.new() into tCurl
      if tCurl = 0 then wait 50 millisecs with messages
   end repeat
   
   if sCancel then
      if tCurl > 0 then curl.cleanup tCurl
      return 0
   end if
   
   curl.setUrl tCurl, tUrl
   curl.setMethod tCurl, pArray["httpMethod"]
   
   if pArray["inputFile"] is not empty then \
         curl.setInputFile tCurl, pArray["inputFile"]
   if pArray["outputFile"] is not empty then \
         curl.setOutputFile tCurl, pArray["outputFile"]
   
   ### discard elements that are not wanted as http headers
   repeat for each item i in \
         "s3path,bucket,object,httpmethod,subresource,inputfile,outputfile"
      delete variable pArray[i]
   end repeat
   
   if pArray["httpMethod"] is "PUT" then put "100-Continue" into pArray["Expect"]
   curl.setHeaders tCurl, pArray
   return tCurl
end s3.curl

-----

-- seems to be necessary until I can figure out how to stop curl putting the tempfile name into the url
-- for setting bucket configs when creating buckets...

private function s3.pathStyleCurl pArray
   repeat for each key k in pArray
      put utf8encode(pArray[k]) into pArray[k]
   end repeat
   
   put the internet date into pArray["Date"]
   put "/" into pArray["uri"]
   if pArray["bucket"] is not empty then put pArray["bucket"] after pArray["uri"]
   if pArray["object"] is not empty then \
         put "/" & pArray["object"] after pArray["uri"]
   if pArray["subresource"] is in "acl,logging,location" then \
         put "?" & pArray["subresource"] after pArray["uri"]
   
   put authString.s3(pArray) into pArray["Authorization"]
   
   put 0 into tCurl
   repeat  until tCurl > 0 or sCancel
      put curl.new() into tCurl
      if tCurl = 0 then wait 50 millisecs with messages
   end repeat
   
   if sCancel then
      if tCurl > 0 then curl.cleanup tCurl
      return 0
   end if
   
   curl.setUrl tCurl, s3BaseUrl() & pArray["uri"]
   curl.setMethod tCurl, pArray["httpMethod"]
   
   get pArray["inputFile"]
   if it is not empty then curl.setInputFile tCurl, it
   get pArray["outputFile"]
   if it is not empty then curl.setOutputFile tCurl, it
   
   repeat for each item i in \
         "uri,bucket,object,httpmethod,subresource,inputfile,outputfile"
      delete variable pArray[i]
   end repeat
   if pArray["httpMethod"] is "PUT" then put "100-Continue" into pArray["Expect"]
   curl.setHeaders tCurl, pArray
   return tCurl
end s3.pathStyleCurl

-----

private function makeVHurl pS3path
   set the itemdelimiter to "/"
   put item 1 of pS3path into tBucket
   put item 2 to -1 of pS3path into tObject
   
   put s3BaseUrl() into tUrl
   if tBucket is not empty then replace "//" with "//" & tBucket & "." in tUrl
   put "/" after tUrl
   if tObject is not empty then put tObject after tUrl
   return tUrl
end makeVHurl


-----

private function makeSubResource pPrefix, pDelimiter, pMarker, pMaxkeys
   if pPrefix is not empty then \
         put "prefix=" & urlencode(pPrefix) & "&" after tSubRes
   if pMarker is not empty then \
         put "marker=" & urlencode(pMarker) & "&" after tSubRes
   if pMaxkeys is not empty then put "max-keys=" & pMaxkeys & "&" after tSubRes
   if pDelimiter is not empty then put "delimiter=" & pDelimiter after tSubRes
   if char -1 of tSubRes is "&" then delete char -1 of tSubRes
   return tSubRes
end makeSubResource

-----

private command makeMetaTags @pQarray, pTags
   if pTags is empty and keys(pTags) is empty then exit makeMetaTags
   if pTags is not an array then split pTags by cr and "="
   repeat for each line L in the keys of pTags
      if char 1 to 11 of L is not "x-amz-meta-" then
         put "x-amz-meta-" & L into tKey
      else
         put L into tKey
      end if
      put utf8encode(pTags[L]) into pQarray[tKey]
   end repeat
end makeMetaTags

-----

private function authString.s3 pArray
   put pArray["httpMethod"] & cr into tStringToSign
   put pArray["Content-MD5"] & cr after tStringToSign
   put pArray["Content-Type"] & cr after tStringToSign
   if pArray["x-amz-date"] is empty then
      put pArray["Date"] & cr after tStringToSign
   else
      put cr after tStringToSign
   end if
   
   put the keys of pArray into tXkeys
   filter tXkeys with "x-amz-*"
   sort lines of tXkeys
   repeat for each line L in tXkeys
      put tolower(L) & ":" & pArray[L] & cr after tStringToSign
   end repeat
   
   put "/" after tStringToSign
   if pArray["bucket"] is not empty then put pArray["bucket"] after tStringToSign
   if pArray["object"] is empty and pArray["bucket"] is not empty and \
         pArray["httpMethod"] is not "PUT" then put "/" after tStringToSign
   if pArray["object"] is not empty then \
         put "/" & pArray["object"] after tStringToSign
   if pArray["subresource"] is in "acl,logging,location" then \
         put "?" & pArray["subresource"] after tStringToSign
   
   -- put tStringToSign
   -- wait 5 seconds
   -- put length(tStringToSign)
   
   return "AWS" && getAwsAccessKey() & ":" & \
         hmacSha1.b64(tStringToSign, getAwsSecretkey())
end authString.s3 

-----

private function s3.cannedAcl pCannedAcl
   if pCannedAcl is not among the items of \
         "private,public-read,public-read-write,authenticated-read" then
      put "private" into pCannedAcl
   end if
   return pCannedAcl
end s3.cannedAcl

-----

private command splitPath @pArray
   set the itemdelimiter to "/"
   put item 1 of pArray["s3path"] into pArray["bucket"]
   put item 2 of pArray["s3path"] into pArray["object"]
   delete variable pArray["s3Path"]
end splitPath

private function splitS3path pPath
   if char 1 of pPath is "/" then delete char 1 of pPath
   set the itemdelimiter to "/"
   return item 1 of pPath & comma & item 2 to -1 of pPath
end splitS3path

private function s3.simpleError pErrorData
   if line 1 of pErrorData begins with "error" then \
         put line 1 of pErrorData into tError
   get lineoffset("<?xml", pErrorData)
   if it > 0 then
      put s3xml.simpleResponse(line it to -1 of pErrorData) into tS3Error
      put " - " & tS3Error["Code"] after tError
   end if
   return tError
end s3.simpleError

-----

private function s3.checkRange pRange
   set the itemdelimiter to "-"
   if item 1 of pRange is not a number then return empty
   if item 2 of pRange is not a number then return empty
   if item 3 of pRange is not empty then return empty
   return pRange
end s3.checkRange

-----

private function bucketNameGood pName
   get length(pName)
   if it < 3 or it > 63 then return false
   if not matchtext(pName,"^[a-z0-9 .+-]+$") then return false
   if char 1 of pName is "." then return false
   if "-." is in pName then return false
   if ".-" is in pName then return false
   return true
end bucketNameGood

-----

private function i.makeMultiData pFileData
   repeat for each line L in pFileData
      put item 2 of L into tArray[item 1 of L]["file"]
      --put "private" into tArray[item 1 of L]["acl"]
   end repeat
   return tArray
end i.makeMultiData

-----

private function postFilePolicy pBucket, pFormData, pExpiry
   delete variable pFormData["AWSAccessKeyId"]
   put zDate(pExpiry) into tArray["expiration"]
   put pBucket into tArray["conditions"][1]["bucket"]
   
   put 1 into c
   repeat for each key k in pFormData
      add 1 to c
      put pFormData[k] into tArray["conditions"][c][k]
   end repeat
   put arrayToJson(tArray) into tJson
   replace "201" with q("201") in tJson
   
   return b64e(tJson)
end postFilePolicy

-----

private function fsfiles @pArray, pFullPaths, pDetailed
   set the itemdelimiter to "/"
   repeat for each key k in pArray["objects"]
      if pFullPaths then
         put pArray["bucketname"] & "/" & k after tList
      else
         put item -1 of k after tList
      end if
      if pDetailed then
         put comma & pArray["objects"][k]["size"] after tList
         put comma & pArray["objects"][k]["modified-seconds"] after tList
         put comma & pArray["objects"][k]["md5"] after tList
         --put comma & pArray["objects"][k]["ownerid"] after tList
      end if
      put cr after tList
   end repeat
   delete char -1 of tList
   return tList
end fsfiles

-----

private function fsfolders @pArray, pFullPaths
   set the itemdelimiter to "/"
   repeat for each line L in pArray["prefixes"]
      if pFullPaths then
         put pArray["bucketname"] & "/" & L after tList
      else
         put item -1 of L after tList
      end if
      put cr after tList
   end repeat
   delete char -1 of tList
   return tList
end fsfolders

---===---===---===---===---===---===---===---===---===---===---===---===---===---


private function s3DateToSeconds pDate
   replace "GMT" with "+0000" in pDate
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

-----

private function luHeaders pArray
   ### all params must be utf-8
   repeat for each key k in pArray
      put utf8encode(pArray[k]) into pArray[k]
   end repeat
   
   ### need to separate out bucket and object for the authentication and url
   if pArray["s3path"] is not empty then
      set the itemdelimiter to "/"
      put item 1 of pArray["s3path"] into pArray["bucket"]
      put urlencode(item 2 to -1 of pArray["s3path"]) into pArray["object"]
      set the itemdelimiter to comma
   end if
   put the internet date into pArray["Date"]
   
   put authString.s3(pArray) into pArray["Authorization"]
   
   ### make the 'virtual host' style url ie. http://myBucket.s3.amazonaws.com
   put i.vhUrl(pArray["bucket"]) into tUrl
   if pArray["object"] is not empty then put pArray["object"] after tUrl
   if pArray["subresource"] is not empty then \
         put "?" & pArray["subresource"] after tUrl
   
   repeat for each item i in "bucket,object,s3path,httpmethod"
      delete variable pArray[i]
   end repeat
   repeat for each key k in pArray
      put k & ":" && pArray[k] & cr after tHeads
   end repeat
   set the httpheaders to tHeads
   put url tUrl into tRes
   return tRes
   
   
end luHeaders

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> s3xml etc
-------------------

function s3.response pXml
   local xmlAnyway = false
   get offset("<?xml", pXml)
   if it = 0 then return pXml
   if it > 1 then
      put char 1 to it -1 of pXml into tNonXml
      delete char 1 to it -1 of pXml
   end if
   put revCreateXMLTree(pXML,true,true,false) into tTree
   put revXmlRootNode(tTree) into tRoot
   switch tRoot
      case "Error"
         put s3xml.errorResponseA(tTree, tRoot) into tArray
         break
      case "ListAllMyBucketsResult"
         put s3xml.listAllMyBucketsA(tTree, tRoot) into tArray
         break
      case "ListBucketResult"
         put s3xml.listBucketA(tTree, tRoot) into tArray
         break
      case "postResponse"
         put s3xml.postResponse(tTree, tRoot) into tArray
         break
      case "CopyObjectResult"
         put s3xml.copyObjectA(tTree, tRoot) into tArray
         break
      case "AccessControlPolicy"
         put s3xml.getAclA(tTree, tRoot) into tArray
         break
      case "BucketLoggingStatus"
         put s3xml.getLoggingA(tTree, tRoot) into tArray
         break
      case "LocationConstraint"
         put s3xml.getLocation(tTree, tRoot) into tArray
         break
      default -- assume that we have a non-s3 xml document
         put true into xmlAnyway
         break
   end switch
   
   revDeleteXmlTree tTree
   if xmlAnyway then
      return pXml
   else
      if tArray["status"] is not "error" then put "ok" into tArray["status"]
      if tNonXml is not empty then \
            put word 2 to -1 of tNonXml into tArray["curlerror"]
      return tArray
   end if
end s3.response

-----

private function s3xml.simpleResponse pXml
   get offset("<?xml", pXml)
   if it > 1 then delete char 1 to it -1 of pXml
   put revCreateXMLTree(pXML,true,true,false) into tTree
   if "<Error>" is in pXml then
      put s3xml.errorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put "ok" into tArray["status"]
   end if
   
   revDeleteXmlTree tTree
   return tArray
end s3xml.simpleResponse

-----

private function s3xml.errorResponseA pTree, pRoot
   put revXmlFirstChild(pTree,  pRoot) into tNode
   set the itemdelimiter to "/"
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode) into tArray[item -1 of tNode]
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   put "error" into tArray["status"]
   return tArray
end s3xml.errorResponseA


private function s3xml.errorResponse pTree
   put revXmlRootNode(pTree) into tRootNode
   put revXmlFirstChild(pTree,  tRootNode) into tNode
   set the itemdelimiter to "/"
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode) into tArray[item -1 of tNode]
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end s3xml.errorResponse

-----

private function s3xml.listBucketA pTree, pRootNode
   set the itemdelimiter to "/"
   put revXmlFirstChild(pTree, pRootNode) into tNode
   
   repeat while tNode is not empty and "xmlerr" is not in tNode
      if "Contents" is in tNode then
         put s3xml.listBucketContentNode(pTree, pNode) into tContent
         put tContent["key"] into tObjectName
         delete variable tContent["key"]
         
         put tObjectName into tArray["nextMarker"]
         put tContent into tArray["objects"][tObjectName]
      else if "CommonPrefixes" is in tNode then
         put char 1 to - 2 of revXmlNodeContents(pTree, pNode & "/Prefix") & cr \
               after tArray["prefixes"]
      else
         put revXmlNodeContents(pTree, pNode) \
               into tArray["request"][item -1 of tNode]
      end if
      put revXmlNextSibling(pTree,  pNode) into tNode
   end repeat 
   
   if tArray["prefixes"] is not empty then delete char -1 of tArray["prefixes"]
   return tArray
   
end s3xml.listBucketA

private function s3xml.listBucket pXml
   put revCreateXMLTree(pXML,true,true,false) into tTree
   if "<Error>" is in pXml then
      put s3xml.errorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      set the itemdelimiter to "/"
      put revXmlRootNode(tTree) into tRootNode
      put revXmlFirstChild(tTree, tRootNode) into tNode
      
      repeat while tNode is not empty and "xmlerr" is not in tNode
         if "Contents" is in tNode then
            put s3xml.listBucketContentNode(tTree, tNode) into tContent
            put tContent["key"] into tObjectName
            delete variable tContent["key"]
            
            put tObjectName into tArray["request"]["nextMarker"]
            put tContent into tArray["objects"][tObjectName]
         else if "CommonPrefixes" is in tNode then
            put char 1 to - 2 of revXmlNodeContents(tTree, tNode & "/Prefix") \
                  & cr after tArray["prefixes"]
         else
            put revXmlNodeContents(tTree, tNode) \
                  into tArray["request"][item -1 of tNode]
         end if
         put revXmlNextSibling(tTree,  tNode) into tNode
      end repeat 
      
      if tArray["prefixes"] is not empty then \
            delete char -1 of tArray["prefixes"]
      put "ok" into tArray["request"]["status"]
   end if
   
   
   revDeleteXmlTree tTree
   return tArray
end s3xml.listBucket

-----

private function s3xml.listBucketContentNode pTree, pNode
   put revXmlNodeContents(pTree, pNode & "/LastModified") \
         into tArray["modified-date"]
   put s3DateToSecondsB(tArray["modified-date"]) into tArray["modified-seconds"]
   get revXmlNodeContents(pTree, pNode & "/ETag")
   put char 2 to -2 of it into tArray["md5"]
   put revXmlNodeContents(pTree, pNode & "/Size") into tArray["size"]
   put revXmlNodeContents(pTree, pNode & "/StorageClass") \
         into tArray["storageclass"]
   put s3xml.owner(pTree, pNode & "/Owner") into tOwner
   union tArray with tOwner
   put utf8decode(revXmlNodeContents(pTree, pNode & "/Key")) into tArray["key"]
   
   return tArray
end s3xml.listBucketContentNode

-----

private function s3xml.owner pTree, pNode
   put revXmlNodeContents(pTree, pNode & "/ID") into tArray["ownerid"]
   put revXmlNodeContents(pTree, pNode & "/DisplayName") \
         into tArray["ownerdisplayname"]
   return tArray
end s3xml.owner

private function s3xml.CanonicalUser pTree, pNode
   put revXmlNodeContents(pTree, pNode & "/ID") into tArray["id"]
   put revXmlNodeContents(pTree, pNode & "/DisplayName") \
         into tArray["displayname"]
   return tArray
end s3xml.CanonicalUser

-----

private function s3xml.listAllMyBucketsA pTree, pRoot
   put s3xml.CanonicalUser(pTree, pRoot & "/Owner") into tArray["owner"]
   
   put pRoot & "/Buckets" into tNode
   put revXmlFirstChild(pTree, tNode) into tNode
   repeat while tNode is not empty and "xmlerr" is  not in tNode
      put revXmlNodeContents(pTree, tNode & "/Name") into tName
      put revXmlNodeContents(pTree, tNode & "/CreationDate") \
            into tArray["buckets"][tName]
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end s3xml.listAllMyBucketsA

private function s3xml.listAllMyBuckets pXml
   put revCreateXMLTree(pXML,false,true,false) into tTree
   if "<Error>" is in pXml then
      put s3xml.errorResponse(tTree) into tArray
      put "error" into tArray["status"]
      revDeleteXmlTree tTree
      return tArray
   end if
   
   put "ok" into tArray["status"]
   put revXmlRootNode(tTree) into tNode
   put s3xml.CanonicalUser(tTree, tNode & "/Owner") into tArray["owner"]
   
   put "/Buckets" after tNode
   put revXmlFirstChild(tTree, tNode) into tNode
   repeat while tNode is not empty and "xmlerr" is  not in tNode
      put revXmlNodeContents(tTree, tNode & "/Name") into tName
      put revXmlNodeContents(tTree, tNode & "/CreationDate") \
            into tArray["buckets"][tName]
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end s3xml.listAllMyBuckets


-----

private function s3xml.getLoggingA pTree, pRoot
   get revXMLChildNames(pTree, pRoot, return,,false)
   put ("LoggingEnabled" is in it) into tArray["enabled"]
   if tArray["enabled"] then
      put pRoot & "/LoggingEnabled" into tNode
      put revXmlNodeContents(pTree, tNode & "/TargetBucket") \
            into tArray["targetbucket"]
      put revXmlNodeContents(pTree, tNode & "/TargetPrefix") \
            into tArray["targetprefix"]
   end if
   return tArray
end s3xml.getLoggingA

private function s3xml.getLogging pXml
   put revCreateXMLTree(pXML,false,true,false) into tTree
   put revXmlRootNode(tTree) into tNode
   get revXMLChildNames(tTree, tNode, return,,false)
   put ("LoggingEnabled" is in it) into tArray["enabled"]
   if tArray["enabled"] then
      put "/LoggingEnabled" after tNode
      put revXmlNodeContents(tTree, tNode & "/TargetBucket") \
            into tArray["targetbucket"]
      put revXmlNodeContents(tTree, tNode & "/TargetPrefix") \
            into tArray["targetprefix"]
   end if
   revDeleteXmlTree tTree
   return tArray
end s3xml.getLogging

-----

private function s3xml.getAclA pTree, pRoot
   put s3xml.CanonicalUser(pTree, pRoot & "/Owner") into tArray["owner"]
   
   put pRoot & "/AccessControlList" into tNode
   put revXmlFirstChild(pTree, tNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      add 1 to grantCount
      put s3xml.grant(pTree, tNode) into tArray["grants"][grantCount]
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   
   return tArray
end s3xml.getAclA

private function s3xml.getAcl pXml
   put revCreateXMLTree(pXML,false,true,false) into tTree
   put revXmlRootNode(tTree) into tNode
   put s3xml.CanonicalUser(tTree, tNode & "/Owner") into tArray["owner"]
   
   put "/AccessControlList" after tNode
   put revXmlFirstChild(tTree, tNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      add 1 to grantCount
      put s3xml.grant(tTree, tNode) into tArray["grants"][grantCount]
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   revDeleteXmlTree tTree
   return tArray
end s3xml.getAcl

-----

private function s3xml.grant pTree, pNode
   put revXmlAttribute(pTree, pNode & "/Grantee", "type") into tArray["type"]
   
   switch tArray["type"]
      case "CanonicalUser"
         put s3xml.CanonicalUser(pTree, pNode & "/Grantee") into tTempArray
         union tArray with tTempArray
         break
      case "Group"
         put revXmlNodeContents(pTree, pNode & "/Grantee/Uri") into tArray["uri"]
         break
      case "AmazonCustomerByEmail"
         put revXmlNodeContents(pTree, pNode & "/Grantee/EmailAddress") \
               into tArray["emailaddress"]
         break
   end switch
   put revXmlNodeContents(pTree, pNode & "/Permission") into tArray["permission"]
   return tArray
end s3xml.grant

-----

private function s3xml.getLocation pTree, pRoot
   put revXmlNodeContents(pTree, pRoot) into tArray["location"]
   if tArray["location"] is empty then put "US" into tArray["location"]
   return tArray
end s3xml.getLocation

-----

private function s3xml.copyObject pXml
   put revCreateXMLTree(pXML,false,true,false) into tTree
   if "<Error>" is in pXml then
      put s3xml.errorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put revXmlNodeContents(tTree, "CopyObjectResult/LastModified") \
            into tArray["lastmodified"]
      put revXmlNodeContents(tTree, "CopyObjectResult/ETag") into tArray["md5"]
      replace quote with empty in tArray["md5"]
      put "ok" into tArray["status"]
   end if
   return tArray
end s3xml.copyObject

private function s3xml.copyObjectA pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/LastModified") \
         into tArray["lastmodified"]
   put revXmlNodeContents(pTree, pRoot & "/ETag") into tArray["md5"]
   replace quote with empty in tArray["md5"]
   put "ok" into tArray["status"]
   return tArray
end s3xml.copyObjectA

-----

private function s3xml.postResponse pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/Bucket") into tArray["bucket"]
   put urldecode(revXmlNodeContents(pTree, pRoot & "/Location")) \
         into tArray["url"]
   put revXmlNodeContents(pTree, pRoot & "/Key") into tArray["key"]
   put char 2 to -2 of revXmlNodeContents(pTree, pRoot & "/ETag") \
         into tArray["md5"]
   return tArray
end s3xml.postResponse

-----

private function httpHeadersToArray pHeaders
   put word 1 to -1 of of line 1 of pHeaders into tArray["responseCode"]
   delete line 1 of pHeaders
   set the itemdelimiter to ":"
   repeat for each line L in pHeaders
      put word 1 to -1 of item 2 to -1 of L into tValue
      switch item 1 of L
         case "Last-Modified"
            put s3DateToSeconds(tValue) into tArray["modified-seconds"]
            put tValue into tArray["modified-date"]
            break
         case "Etag"
            put tValue into tArray["md5"]
            replace quote with empty in tArray["md5"]
            break
         case "Content-Type"
            put tValue into tArray["type"]
            break
         case "Content-Length"
            put tValue into tArray["size"]
            break
         case "x-amz-meta-" is in L
            put tValue into tArray[char 12 to -1 of item 1 of L]
            break
         default
            put tValue into tArray[item 1 of L]
            break
      end switch
   end repeat
   return tArray
end httpHeadersToArray

-----

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> Acls
-----------

function makeAcl pArray
   put "<AccessControlPolicy>" into tAcl
   put "<Owner>" after tAcl
   put "<ID>" & pArray["owner"]["id"] & "</ID>" after tAcl
   put "<DisplayName>" & pArray["owner"]["displayname"] & "</DisplayName>" \
         after tAcl
   put "</Owner>" after tAcl
   
   put "<AccessControlList>" after tAcl
   repeat with n = 1 to the number of lines in keys(pArray["grants"]
      put "<Grant>" after tAcl
      switch pArray["grants"][n]["type"]
         case "CanonicalUser"
            put "<Grantee xsi:type=" & q("CanonicalUser")  & ">" after tAcl
            put "<ID>" & pArray["grants"][n]["id"] & "</ID>" after tAcl
            put "<DisplayName>" &  pArray["grants"][n]["displayname"] & \
                  "</DisplayName>" after tAcl
            break
         case "Group"
            put "<Grantee xsi:type=" & q("Group")  & ">" after tAcl
            put "<URI>" & pArray["grants"][n]["uri"] & "</URI>" after tAcl
            break
      end switch
      put "</Grantee>" after tAcl
      put "<Permission>" & pArray["grants"][n]["permission"] & "</Permission>" \
            after tAcl
      put "</Grant>" after tAcl
   end repeat
   put "</AccessControlList></AccessControlPolicy>" after tAcl
   return tAcl
end makeAcl

---===---===---===---===---===---===---===---===---===---===---===---===---===---
