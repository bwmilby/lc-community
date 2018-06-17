Script "stack_libRevCurl_"

/*
# Name: stack "libRevCurl"
# ID: stack "libRevCurl"
*/


---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
# libRevCurl
# version: 1.0.0b
# date: 20081017
---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
----------------------
--> script locals
----------------------

local sCurlPool
local sMaxCurls = 32
local sTimeout = 10000
local sUpdateInterval = 75
local sLibVersion = 1.0
local sCurlVersion
local sStrictSSL = false
local sCurlPath = "/usr/bin/curl"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- debug
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# nodoc
function curl.show pCurl
   repeat for each key k in sCurlPool[pCurl]
      put k & cr & sCurlPool[pCurl][k] & cr & "---------------------" & cr after tList
   end repeat
   return tList
end curl.show


---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
--> session interface
----------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# set the path to the curl executable
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setCurlPath pPath
   if there is a file pPath then put pPath into sCurlPath
end curl.setCurlPath


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# set how often (in millisecs) we read from the running curl processes to update their status
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setUpdateInterval pInterval
   if pInterval is an integer and pInterval >= 50 then put pInterval into sUpdateInterval
end curl.setUpdateInterval


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# set how many instances can be open simultaneously
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setMaxCurls pNum
   if pNum is an integer and pNum > 0 then put pNum into sMaxCurls
end curl.setMaxCurls


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# sets curl's timeout
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setTimeout pMillisecs
   if pMillisecs is an integer and pMillisecs >= 2000 then put pMillisecs into sTimeout
end curl.setTimeout


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# returns the version of the library and the version of curl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.version
   return "libRevCurl version:" && sLibVersion & cr & shell(sCurlPath && "-V")
end curl.version


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# if set true, will allow https connections where the certifcate is not recognised - useful for servers with self-signed certs.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setStrictSsl pBool
   put pBool into sStrictSSL
end curl.setStrictSsl


---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
--> instance interface
-----------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple blocking http GET
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.get pUrl
   put curl.new() into tCurl
   curl.setUrl tCurl, pUrl
   return curl.runTilDone(tCurl)
end curl.get


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple blocking http POST
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.post pUrl, pPostData
   put curl.new() into tCurl
   curl.setUrl tCurl, pUrl
   curl.setPostData tCurl, pPostData
   curl.setMethod tCurl, "POST"
   return curl.runTilDone(tCurl)
end curl.post


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple blocking http HEAD
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.head pUrl
   put curl.new() into tCurl
   curl.setUrl tCurl, pUrl
   curl.setMethod tCurl, "HEAD"
   return curl.runTilDone(tCurl)
end curl.head


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple blocking http OPTIONS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.options pUrl
   put curl.new() into tCurl
   curl.setUrl tCurl, pUrl
   curl.setMethod tCurl, "OPTIONS"
   
   curl.execute tCurl
   wait until curl.done(tCurl) with messages
   
   get curl.error(tCurl)
   if it is not empty then
      put it into tResponse
   else
      put curl.responseHeaders(tCurl, true) into tResponse
   end if
   curl.cleanup tCurl
   
   if tResponse["Allow"] is empty then
      return "OPTIONS method not supported on this server"
   else
      return tResponse["Allow"]
   end if
end curl.options


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple blocking http TRACE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.trace pUrl
   put curl.new() into tCurl
   curl.setUrl tCurl, pUrl
   curl.setMethod tCurl, "TRACE"
   curl.execute tCurl
   wait until curl.done(tCurl) with messages
   
   get curl.error(tCurl)
   if it is not empty then
      put it into tResponse
   else
      put curl.response(tCurl) into tResponse
      put curl.tracedump(tCurl) after tResponse
   end if
   curl.cleanup tCurl
   
   return tResponse
end curl.trace


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# simple execution of an instance - no callbacks or progress indication, simply runs and return the response
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

function curl.runTilDone pCurl
   
   try
      curl.execute pCurl
      wait until curl.done(pCurl) with messages
       
      switch curl.status(pCurl)
         case "error"
            put curl.error(pCurl) & cr & curl.response(pCurl)  into tResponse
            break
         case "cancelled"
            put "cancelled" into tResponse
            break
         default
            put curl.response(pCurl) into tResponse  
      end switch
   catch tError
      put "libRevCurl error: runTilDone" into tResponse
   end try
    
   curl.cleanup pCurl
   return tResponse
end curl.runTilDone

-----

# nodoc
on curl.freeRun pCurl
   curl.execute pCurl
   wait until curl.done(pCurl) with messages
   curl.cleanup pCurl
end curl.freeRun


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- creates and initializes a new instance with defaults - see initCurl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.new pUrl
   put 0 into tCurl
   repeat with tCurl = 1 to sMaxCurls
      if sCurlPool[tCurl]["status"] is empty then
         initCurl tCurl
      end if
   end repeat
   if tCurl > 0 and pUrl is not empty then put pUrl into sCurlPool[tCurl]["url"]
       
   return tCurl
end curl.new


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- set the max number of redirects for this instance. -1 = no limit
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setMaxRedirects pCurl, pNum
   if pNum is an integer and pNum >= -1 then put pNum into sCurlPool[pCurl]["maxRedirects"]
end curl.setMaxRedirects


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- set the max transfer speed in kilobytes/second
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setMaxSpeed pCurl, pKps
   if pKps is an integer and pKps >= 1 then put pKps into sCurlPool[pCurl]["maxspeed"]
end curl.setMaxSpeed


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- set http method
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setMethod pCurl,pMethod
   if pMethod is in "GET,POST,HEAD,PUT,DELETE,TRACE,OPTIONS" then
      put pMethod into sCurlPool[pCurl]["method"]
   end if
end curl.setMethod


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- set the http headers. Input can be an array, or a return-delimited list. Additive.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setHeaders pCurl, pHeaders
   if pHeaders is an array then
      repeat for each line L in the keys of pHeaders
         put "-H =" && q(L & ":" && pHeaders[L]) & cr after sCurlPool[pCurl]["headers"]
      end repeat
   else
      repeat for each line L in pHeaders
         put "-H =" && q(L) & cr after sCurlPool[pCurl]["headers"]
      end repeat
   end if
end curl.setHeaders


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add cookies to the headers, so can equally be handled by curl.setHeaders
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setCookies pCurl, pCookies
   repeat for each line L in pCookies
      put "-H =" && q("Cookie:" && L) & cr after sCurlPool[pCur]["headers"]
   end repeat
end curl.setCookies


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- set the full url - must include "http://" or "https://"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setUrl pCurl, pUrl
   put pUrl into sCurlPool[pCurl]["url"]
end curl.setUrl


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- the full path to a file to be uploaded using http PUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setInputFile pCurl, pFile
   put pFile into sCurlPool[pCurl]["inputfile"]
end curl.setInputFile


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- option to delete input file once uploaded. Default is "false"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setDeleteInputfile pCurl, pBool
   if pBool is "true" or pBool is "false" then put pBool into sCurlPool[pCurl]["deleteInputfile"]
end curl.setDeleteInputfile


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- the full path for the target of a download
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setOutputFile pCurl, pFile
   put pFile into sCurlPool[pCurl]["outputfile"]
   put false into sCurlPool[pCurl]["deleteoutputfile"]
end curl.setOutputFile


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sets the data (ie. not a file) to uploaded using http PUT. ( writes data to a tempfile, uploads, and deletes tempfile )
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setPutData pCurl, pData
   put the tempname into tFile
   writeBinFile tFile, pData
   put tFile into sCurlPool[pCurl]["inputfile"]
   put true into sCurlPool[pCurl]["deleteInputfile"]
   put "PUT" into sCurlPool[pCurl]["method"]
end curl.setPutData


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sets the data to be uploaded using http POST. The data can be a "GET"- style query string, an array (which will be
-- turned into a query string, a file, or just a string of bytes.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setPostData pCurl, pData
   if pData is an array then
      repeat for each line L in the keys of pData
         put urlencode(L) & "=" & urlencode(pData[L]) & "&" after tPostData
      end repeat
      delete char -1 of tPostData
   else
      if char 1 to 5 of pData is "file:" and there is a file (char 6 to -1 of pData) then
         put "@" & char 6 to -1 of pData into tPostData
      else
         put pData into tPostData
      end if
      -- if there is a file pData then
      -- put "@" & pData into tPostData
      -- else
      -- put pData into tPostData
      -- end if
   end if
   
   put tPostData into sCurlPool[pCurl]["postdata"]
   put "POST" into sCurlPool[pCurl]["method"]
   put empty into sCurlPool[pCurl]["inputfile"]
   put empty into sCurlPool[pCurl]["multipartformdata"]
end curl.setPostData

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- similar to setPostData, but forces the mimetype to be "multipart/form"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setMultiPartFormData pCurl, pFormData, pKeyOrder
   if pFormData is not an array then split pFormData by cr and "="
   if the keys of pFormData is empty then exit curl.setMultiPartFormData
   if there is a file pFormData["file"] then put "@" before pFormData["file"]
   
   if pKeyOrder is not empty then
      repeat for each item i in pKeyOrder
         if pFormData[i] is not empty then put i & "=" & pFormData[i] & cr after tForm
      end repeat
      put word 1 to -1 of tForm into pFormData
   else
       
      if sCurlPool[pCurl]["multipartformdata"] is not empty then
         put sCurlPool[pCurl]["multipartformdata"] into tMultiPartFormData
         split tMultiPartFormData by cr and "="
         union pFormData with tMultiPartFormData
      end if
      put keys(pFormData) into tKeys
      sort lines of tkeys numeric by item 2 of each
       
      repeat for each line k in tKeys
         if k is "file" then next repeat
         put item 1 of k & "=" & pFormData[k] & cr after tForm
      end repeat
      if pFormData["file"] is not empty then put "file=" & pFormData["file"] after tForm
      put word 1 to -1 of tForm into pFormData
   end if
    
   put pFormData into sCurlPool[pCurl]["multipartformdata"]
   put "POST" into sCurlPool[pCurl]["method"]
   put empty into sCurlPool[pCurl]["inputfile"]
   put empty into sCurlPool[pCurl]["postdata"]
end curl.setMultiPartFormData


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setHttpProxy pCurl, pHost, pPort
   put "-x =" && pHost into tProxy
   if pPort is not empty then put ":" & pPort after tProxy
   put tProxy into line 1 of sCurlPool[pCurl]["proxydata"]
end curl.setHttpProxy


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setSocks4Proxy pCurl, pHost, pPort
   put "--sock4 =" && pHost into tProxy
   if pPort is not empty then put ":" & pPort after tProxy
   put tProxy into line 1 of sCurlPool[pCurl]["proxydata"]
end curl.setSocks4Proxy


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setProxyUser pCurl, pUser, pPassword
   put "-U =" && pUser & ":" & pPassword into line 2 of sCurlPool[pCurl]["proxydata"]
end curl.setProxyUser


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setUserPassword pCurl,pUser, pPassword
      put "-u =" && pUser & ":" & pPassword into sCurlPool[pCurl]["user:password"]
end curl.setUserPassword


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setTraceDump pCurl, pFile
   if pFile is not empty then
      put pFile into sCurlPool[pCurl]["tracedumpfile"]
      put false into sCurlPool[pCurl]["deletetracedumpfile"]
   else
      put tempDir() & "/curltracedumpfile-" & pCurl into sCurlPool[pCurl]["tracedumpfile"]
      put true into sCurlPool[pCurl]["deletetracedumpfile"]
   end if
end curl.setTraceDump

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- tell curl to continue downloading from from the specified byte offset, or figure it out for itself
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.continue pCurl, pOffset
   if pOffset is not an integer or pOffset < 1 then put "-" into pOffset
   put pOffset into sCurlPool[pCurl]["continueat"]
end curl.continue


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- create the config file for curl, execute the given instance, and start the updating loop - curly.checkCurl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.execute pCurl
   writeBinFile sCurlPool[pCurl]["configfile"], createConfig(pCurl) 
    
   set the hideconsolewindows to true
   put the millisecs into sCurlPool[pCurl]["startms"]
   open process sCurlPool[pCurl]["process"] for binary read
    
   put "running" into sCurlPool[pCurl]["status"]
   if "curly.checkCurl" is not in the pendingmessages then curly.checkCurl
end curl.execute


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns true if the given instance has completed, false otherwise
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.done pCurl
   return sCurlPool[pCurl]["status"] is in "done,cancelled,error"
end curl.done


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns a new instance with the exact same settings as the given instance
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.copy pCurl
   put curl.new() into tCopy
   if tCopy = 0 then return 0
   else
      put sCurlPool[pCurl] into sCurlPool[tCopy]
   end if
   return tCopy
end curl.copy


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns a description of any error that may have ocurred on the given instance.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.error pCurl
   return sCurlPool[pCurl]["error"]
end curl.error


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the status and progress of the given instance, separated by a comma eg "running,53"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.info pCurl
   return sCurlPool[pCurl]["status"] & comma & sCurlPool[pCurl]["perc"]
end curl.info

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the status of the given instance
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.status pCurl
   return sCurlPool[pCurl]["status"]
end curl.status

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
# returns the progress of the given instance as a percentage eg. "67"  - synonymous with curl.progress()
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.prog pCurl
   return sCurlPool[pCurl]["perc"]
end curl.prog

# returns the progress of the given instance as a percentage eg. "67" - synonymous with curl.prog()
function curl.progress pCurl
   return sCurlPool[pCurl]["perc"]
end curl.progress

function curl.size pCurl
   return sCurlPool[pCurl]["size"]
end curl.size



--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the url of the given instance
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.url pCurl
   return sCurlPool[pCurl]["url"]
end curl.url


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the config file to be used by the given instance, exactly as it will be passed to curl.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.config pCurl
   return createConfig(pCurl)
end curl.config

function curl.configFtp pCurl
   return createConfigFtp(pCurl)
end curl.configFtp

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns all the current values of the given instance as an array
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.portableConfig pCurl
   put sCurlPool[pCurl] into tPortableConfig
   return tPortableConfig
end curl.portableConfig


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- sets the values for the given instance from an array - see above
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.setFromPortable pCurl, pConfig
   repeat for each key k in pConfig
      put pConfig[k] into sCurlPool[pCurl][k]
   end repeat
end curl.setFromPortable


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the http headers sent by the server in response to a request. Usually empty until execution complete
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.responseHeaders pCurl, asArray
   if asArray then
      put line 2 to -1 of sCurlPool[pCurl]["responseHeaders"] into tHeaders
      replace ": " with "|" in tHeaders
      split tHeaders by cr and "|"
      put word 2 to -1 of line 1 of sCurlPool[pCurl]["responseHeaders"] into tHeaders["response-code"]
      return tHeaders
   else
      return sCurlPool[pCurl]["responseHeaders"]
   end if
end curl.responseHeaders


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the body of the servers response to a request. 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.response pCurl
   return sCurlPool[pCurl]["response"]
end curl.response

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the http headers sent to the server
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.requestHeaders pCurl
   return sCurlPool[pCurl]["requestHeaders"]
end curl.requestHeaders


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns any cookies found in the http headers returned by the server
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.cookies pCurl
   return sCurlPool[pCurl]["cookies"]
end curl.cookies


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- returns the tracedump data if there is any
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.tracedump pCurl
   if there is a file sCurlPool[pCurl]["tracedumpfile"] then return readBinFile(sCurlPool[pCurl]["tracedumpfile"])
end curl.tracedump


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- cleans up after the given instance has completed, and returns the instance id to the pool.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.cleanup pCurl
   if there is a file sCurlPool[pCurl]["configfile"] then delete file sCurlPool[pCurl]["configfile"]
   
   if sCurlPool[pCurl]["process"] is in the openprocesses then close process sCurlPool[pCurl]["process"]
   
   if sCurlPool[pCurl]["deleteinputfile"] then
      if there is a file sCurlPool[pCurl]["inputfile"] then delete file sCurlPool[pCurl]["inputfile"]
   end if
   
   if sCurlPool[pCurl]["deleteoutputfile"] then --or curl.status(pCurl) is "cancelled" then
      if there is a file sCurlPool[pCurl]["outputfile"] then delete file sCurlPool[pCurl]["outputfile"]
   end if
   
   if sCurlPool[pCurl]["deletetracedumpfile"] and there is a file sCurlPool[pCurl]["tracedumpfile"] then
      delete file sCurlPool[pCurl]["tracedumpfile"]
   end if
   
   delete variable sCurlPool[pCurl]
    
end curl.cleanup


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- stops the given instance while it's executing.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.cancel pCurl
   if sCurlPool[pCurl]["process"] is among the lines of the openprocesses then kill 9 process sCurlPool[pCurl]["process"]
   put "cancelled" into sCurlPool[pCurl]["status"]
end curl.cancel


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- immediately stops all instances and cleans up
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curl.KillAll
   cancelMessages "curly.checkcurl"
   repeat with n = 1 to sMaxCurls
      if sCurlPool[n]["process"] is in the openprocesses then kill 9 process sCurlPool[n]["process"]
      curl.cleanup n
   end repeat
   
   repeat for each line L in the pendingmessages
      if "curl.checkCurl" is in L then cancel item 1 of L
   end repeat
   
   put empty into sCurlPool
end curl.KillAll

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- return the number of curl instances currently exiting
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function curl.count
   return the number of lines in keys(sCurlPool)
end curl.count


------
--> ftp

function curl.NewFtp
   repeat with n = 1 to sMaxCurls
      if sCurlPool[n]["status"] is empty then
         initCurlFtp n
         return n
      end if
   end repeat
   return 0
end curl.NewFtp


---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---
--> internals
-----------------


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get the temp directory from the tempname() function
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private function tempDir
   put the tempname into tName
   set the itemdelimiter to "/"
   return item 1 to -2 of tName
end tempDir
 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- initialize the given instance to defaults
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command initCurl pCurl
   put "pending" into sCurlPool[pCurl]["status"]
   put 0 into sCurlPool[pCurl]["perc"]
   put tempDir() & "/" & "curlconfig-" & pCurl into tFile
   put tFile into sCurlPool[pCurl]["configfile"]
   put sCurlPath && "-K" && q(tFile) into sCurlPool[pCurl]["process"]
   
   put tempDir() & "/curlout-" & pCurl into sCurlPool[pCurl]["outputfile"]
   put true into sCurlPool[pCurl]["deleteoutputfile"]
   
   put "-H =" && q(userAgent()) & cr into sCurlPool[pCurl]["headers"]
   
   put "GET" into sCurlPool[pCurl]["method"]
   put false into sCurlPool[pCurl]["deleteInputfile"]
   put 5 into sCurlPool[pCurl]["maxRedirects"]
end initCurl

private command initCurlFtp pCurl
   put "pending" into sCurlPool[pCurl]["status"]
   put 0 into sCurlPool[pCurl]["perc"]
   put tempDir() & "/" & "curlconfig-" & pCurl into tFile
   put tFile into sCurlPool[pCurl]["configfile"]
   put sCurlPath && "-K" && q(tFile) into sCurlPool[pCurl]["process"]
   
   put tempDir() & "/curlout-" & pCurl into sCurlPool[pCurl]["outputfile"]
   put true into sCurlPool[pCurl]["deleteoutputfile"]
   
   -- put "-H =" && q(userAgent()) & cr into sCurlPool[pCurl]["headers"]
   -- 
   -- put "GET" into sCurlPool[pCurl]["method"]
   put false into sCurlPool[pCurl]["deleteInputfile"]
   put 5 into sCurlPool[pCurl]["maxRedirects"]
end initCurlFtp


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- create the "User-Agent" string
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private function userAgent
   if sCurlVersion is empty then put shell("curl -V") into sCurlVersion
   return "User-Agent: libRevCurl" && sLibVersion & "/" & line 1 of sCurlVersion
end userAgent


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- create the actual config file from the given instance for curl to execute
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private function createConfig pCurl
   put "url =" && q(sCurlPool[pCurl]["url"]) & cr & "-v" & cr into tConfig
   if "https:" is in sCurlPool[pCurl]["url"] and not sStrictSSL then put "-k" & cr after tConfig
   put "--progress-bar" & cr after tConfig
    
   put "--retry = 5" & cr after tConfig
   put "--retry-delay = 0.3" & cr after tConfig
   get sCurlPool[pCurl]["maxRedirects"]
   if it <> 0 then
      put "-L" & cr after tConfig
      put "--max-redirs = " & it & cr after tConfig
   end if
   get sCurlPool[pCurl]["maxspeed"]
   if it is an integer then put "--limit-rate =" && it & k & cr after tConfig
   
   get sCurlPool[pCurl]["continueat"]
   if it is not empty then put "--continue-at =" && it & cr after tConfig
   
   put "-X =" && q(sCurlPool[pCurl]["method"]) & cr after tConfig
    
   if sCurlPool[pCurl]["user:password"] is not empty then put sCurlPool[pCurl]["user:password"] & cr after tConfig
   if line 1 of sCurlPool[pCurl]["proxydata"] is not empty then put sCurlPool[pCurl]["proxydata"] & cr after tConfig
    
   switch sCurlPool[pCurl]["method"]
      case "HEAD"
         put "-I" & cr after tConfig
         break
      case "PUT"
         if sCurlPool[pCurl]["inputfile"] is not empty then put "-T =" && q(sCurlPool[pCurl]["inputfile"]) & cr after tConfig
         break
      case "POST"
         if  sCurlPool[pCurl]["multipartformdata"] is not empty then
         
            repeat for each line L in sCurlPool[pCurl]["multipartformdata"] 
               put "-F =" && q(L) & cr after tConfig
            end repeat
         else
            put "--data-binary =" && q(sCurlPool[pCurl]["postdata"]) & cr after tConfig
         end if
         break
   end switch
    
   put sCurlPool[pCurl]["headers"] & cr after tConfig
   
   if sCurlPool[pCurl]["tracedumpfile"] is not empty then
      put "--trace =" && q(sCurlPool[pCurl]["tracedumpfile"]) & cr after tConfig
   end if
    
   if sCurlPool[pCurl]["outputfile"] is not empty then
      put "-o =" && q(sCurlPool[pCurl]["outputfile"]) & cr after tConfig
   end if
    
   return tConfig
end createConfig


---------------

private function createConfigFtp pCurl
   put "url =" && q(sCurlPool[pCurl]["url"]) & cr & "-v" & cr into tConfig
   --if "https:" is in sCurlPool[pCurl]["url"] and not sStrictSSL then put "-k" & cr after tConfig
   put "--progress-bar" & cr after tConfig
    
   -- put "--retry = 5" & cr after tConfig
   -- put "--retry-delay = 0.3" & cr after tConfig
   -- get sCurlPool[pCurl]["maxRedirects"]
   -- if it <> 0 then
   -- put "-L" & cr after tConfig
   -- put "--max-redirs = " & it & cr after tConfig
   -- end if
   get sCurlPool[pCurl]["maxspeed"]
   if it is an integer then put "--limit-rate =" && it & k & cr after tConfig
   
   --put "-X =" && q(sCurlPool[pCurl]["method"]) & cr after tConfig
    
   if sCurlPool[pCurl]["user:password"] is not empty then put sCurlPool[pCurl]["user:password"] & cr after tConfig
   --if line 1 of sCurlPool[pCurl]["proxydata"] is not empty then put sCurlPool[pCurl]["proxydata"] & cr after tConfig
    
   -- switch sCurlPool[pCurl]["method"]
   -- case "HEAD"
   -- put "-I" & cr after tConfig
   -- break
   -- case "PUT"
   if sCurlPool[pCurl]["inputfile"] is not empty then put "-T =" && q(sCurlPool[pCurl]["inputfile"]) & cr after tConfig
   -- break
   -- case "POST"
   -- if  sCurlPool[pCurl]["multipartformdata"] is not empty then
   -- 
   -- repeat for each line L in sCurlPool[pCurl]["multipartformdata"] 
   -- put "-F =" && q(L) & cr after tConfig
   -- end repeat
   -- else
   -- put "--data-binary =" && q(sCurlPool[pCurl]["postdata"]) & cr after tConfig
   -- end if
   -- break
   -- end switch
    
   --put sCurlPool[pCurl]["headers"] & cr after tConfig
   
   -- if sCurlPool[pCurl]["tracedumpfile"] is not empty then
   -- put "--trace =" && q(sCurlPool[pCurl]["tracedumpfile"]) & cr after tConfig
   -- end if
    
   -- if sCurlPool[pCurl]["outputfile"] is not empty then
   -- put "-o =" && q(sCurlPool[pCurl]["outputfile"]) & cr after tConfig
   -- end if
    
   return tConfig
end createConfigFtp


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- check instances have not timed out, and update the progress of all current instances, 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
on curly.checkCurl
   put 0 into c
   repeat with n = 1 to sMaxCurls
      if sCurlPool[n]["status"] is not empty and sCurlPool[n]["status"] is not in "done,error,cancelled" then
          
         if the millisecs - sCurlPool[n]["startms"] > sTimeout then
            put "error: timeout" into sCurlPool[n]["error"]
            put "error" into sCurlPool[n]["status"]
            closeCurl n
            next repeat
         end if
          
         add 1 to c
         switch
            case "http://" is in sCurlPool[n]["url"]
            case "https://" is in sCurlPool[n]["url"]
               checkHttp n
               break
            case "ftp://" is in sCurlPool[n]["url"]
            case "ftps://" is in sCurlPool[n]["url"]
            case "sftp://" is in sCurlPool[n]["url"]
               checkFtp n
               break
         end switch
      end if
   end repeat
   if c > 0 then send "curly.CheckCurl" to me in sUpdateInterval millisecs
end curly.checkCurl


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- update the given instance by <read from process>
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command checkHttp pCurl
   read from process sCurlPool[pCurl]["process"] until empty
   put it into tRes
   if tRes is not empty then
      put the millisecs into sCurlPool[pCurl]["startms"]
      
      if "curl: (" is in tRes then
         get lineoffset("curl:",tRes)
         put "error:" && line it of tRes into sCurlPool[pCurl]["error"]
         put "error" into sCurlPool[pCurl]["status"]
         closeCurl pCurl
         exit checkHttp
      end if
      
      getProg pCurl, tRes
      if sCurlPool[pCurl]["responseHeaders"] is empty then getResponseHeaders pCurl, tRes
      if sCurlPool[pCurl]["requestHeaders"] is empty then getRequestHeaders pCurl, tRes
      
      get word 2 of sCurlPool[pCurl]["responseHeaders"]
      if it is a number and it >= 400 then
         put "error:" && word 2 to -1 of line 1 of sCurlPool[pCurl]["responseHeaders"] into sCurlPool[pCurl]["error"]
         put "error" into sCurlPool[pCurl]["status"]
         closeCurl pCurl
         exit checkHttp
      end if
       
      if "Closing connection" is in tRes then
         put "done" into sCurlPool[pCurl]["status"]
         closeCurl pCurl
      end if
       
   end if
end checkHttp


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- not tested
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command checkFtp pCurl
   read from process sCurlPool[pCurl]["process"] until empty
   put it into tRes
   if tRes is not empty then
      --put tRes & "--------dd---------" & cr after msg
      
      if "curl: (" is in tRes then
         get lineoffset("curl:",tRes)
         put line it of tRes into sCurlPool[pCurl]["error"]
         put "error" into sCurlPool[pCurl]["status"]
         closeCurl pCurl
         exit checkFtp
      end if
      
      getProg pCurl, tRes
      
      if "Closing connection" is in tRes then
      put tRes into sCurlPool[pCurl]["response"]
         put "done" into sCurlPool[pCurl]["status"]
      end if
   end if
end checkFtp


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- close the given instances process, if necessary, and put the various outputs where they need to go
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command closeCurl pCurl
   if sCurlPool[pCurl]["process"] is among the lines of the openprocesses then close process sCurlPool[pCurl]["process"]
   if sCurlPool[pCurl]["deleteoutputfile"] then put readBinFile(sCurlPool[pCurl]["outputfile"]) into sCurlPool[pCurl]["response"]
   --if curl.response(pCurl) is empty then put word 2 to -1 of line 1 of curl.responseHeaders(pCurl) into sCurlPool[pCurl]["response"]
   getCookies pCurl
   
end closeCurl


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- parse the percentage complete from curl output
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getProg pCurl, pText
   if "* Connection" is in pText then
      put 100  into sCurlPool[pCurl]["perc"]
   else
      get word -1 of pText 
      replace "%" with empty in it
      if it is a number then put round(it) into sCurlPool[pCurl]["perc"]
   end if
end getProg


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- parse the returned http headers form curl output
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getResponseHeaders pCurl, pText
   replace crlf with cr in pText
   replace "< " with cr & "< " in pText
   filter pText with "< *"
   replace "< " with empty in pText
   filter pText without empty
   if "100 Continue" is in pText then exit getResponseHeaders
   if pText is not empty then put pText  into sCurlPool[pCurl]["responseHeaders"]
   
   get lineoffset("Content-Length", sCurlPool[pCurl]["responseHeaders"])
   if it > 0 then put word -1 of line it of sCurlPool[pCurl]["responseHeaders"] into sCurlPool[pCurl]["size"]
end getResponseHeaders


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- parse the response body from curl output
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getResponseBody pCurl, pText
   get lineoffset("##", pText)
   if it = 0 then get lineoffset(" connection #", pText)
   if it > 0 then
      delete line 1 to it of pText
      if pText is not empty then 
         if char 1 of pText is cr then delete char 1 of pText
         repeat for each line L in pText
            if char 2 of L is space and char 1 of L is in "*{}#" then next repeat
            -- get char 1 to 2 of L
            -- if it = "* " or it = "} " or it = "{ " or it = "##" then next repeat
            put L & cr after  tResponse
         end repeat
         put char 1 to -2 of tResponse after sCurlPool[pCurl]["response"]
      end if
   end if
end getResponseBody


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- parse the sent http headers from curl output
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getRequestHeaders pCurl, pText
   replace crlf with cr in pText
   replace "> " with cr & "> " in pText
   filter pText with "> *"
   replace "> " with empty in pText
   filter pText without empty
   put pText  into sCurlPool[pCurl]["requestHeaders"]
   
   get lineoffset("Content-Length", sCurlPool[pCurl]["requestHeaders"])
   if it > 0 then put word -1 of line it of sCurlPool[pCurl]["requestHeaders"] into sCurlPool[pCurl]["size"]
end getRequestHeaders


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- parse any cookies from the returned http headers
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getCookies pCurl
   repeat for each line L in sCurlPool[pCurl]["responseHeaders"]
      if "Set-cookie" is in L then put word 2 to -1 of L & cr after tCookies
   end repeat
   put char 1 to -2 of tCookies into sCurlPool[pCurl]["cookies"]
end getCookies


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- temporary
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
private command getXml pCurl, pText
   get lineoffset("<?xml", pText)
   if it > 0 then 
      put line it to - 1 of pText into sCurlPool[pCurl]["xml"]
   end if
end getXml

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> multi curl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

local sMultiCurl
local sMultiCurlStatus
local sMultiCurlResults
local sMultiCurlCancel

on curl.multi.get pUrlArray
   put false into sMultiCurlCancel
   put 0 into sMultiCurlStatus["numurlsdone"]
   put the number of lines in keys(pUrlArray) into sMultiCurlStatus["numurls"]
   put "running" into sMultiCurlStatus["status"]
   repeat for each line L in keys(pUrlArray)
      if sMultiCurlCancel then
         killMultiCurl
      else
         repeat 10
            put curl.new() into tCurl
            if tCurl > 0 then
               put L into sMultiCurl[tCurl]
               curl.setUrl tCurl, L
               get pUrlArray[L]["headers"]
               if it is not empty then curl.setHeaders tCurl, it
               curl.execute tCurl
               if "curlyMultiCheck" is not in the pendingmessages then send "curlyMultiCheck" to me in 10 millisecs
               next repeat
            end if
         end repeat
         if tCurl = 0 then exit repeat
      end if
      wait 10 millisecs with messages
   end repeat
end curl.multi.get

on curlyMultiCheck
   if sMultiCurlCancel then
      killMultiCurl
   else
      repeat for each line L in keys(sMultiCurl)
         if curl.done(L) then
            put curl.response(L) into sMultiCurlResults[sMultiCurl[L]]
            curl.cleanup(L)
            delete variable sMultiCurl[L]
            add 1 to sMultiCurlStatus["numurlsdone"]
         end if
         if keys(sMultiCurl) is not empty then
            send "curlyMultiCheck" to me in 200 millisecs
         else
            put "done" into sMultiCurlStatus["status"]
         end if
      end repeat
   end if
end curlyMultiCheck

on killMultiCurl
   repeat for each line L in keys(sMultiCurl)
      curl.cancel(L)
      curl.cleanup L
   end repeat
   put "cancelled" into sMultiCurlStatus["status"]
   put empty into sMultiCurlResults
   put empty into sMultiCurl
end killMultiCurl

function curl.multi.prog
   return sMultiCurlStatus["status"] & comma & sMultiCurlStatus["numurlsdone"] & comma & sMultiCurlStatus["numurls"]
end curl.multi.prog

function curl.multi.done
   return sMultiCurlStatus["status"] is in "done,cancelled"
end curl.multi.done

function curl.multi.results
   return sMultiCurlResults
end curl.multi.results

on curl.multi.cancel
   put true into sMultiCurlCancel
end curl.multi.cancel
