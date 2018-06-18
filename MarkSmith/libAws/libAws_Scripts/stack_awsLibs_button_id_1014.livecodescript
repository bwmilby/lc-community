Script "stack_awsLibs_button_id_1014"

/*
# Name: button "sqs" of card id 1002 of stack "awsLibs"
# ID: button id 1014 of card id 1002 of stack "awsLibs"
*/



---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
amazon sqs library
version: 1.0.0b
date: 20081018
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> locals & constants

constant kApiVersion = "2009-02-01"
constant kUsEndpoint = "http://queue.amazonaws.com/"
constant kEuEndpoint = "http://eu-west-1.queue.amazonaws.com/"


--> interface
------------------

function sqs.createQueue pQname, pQlocation, pFormat
   put "CreateQueue" into tQarray["Action"]
   put pQname into tQarray["QueueName"]
   
   put sqs.curl(tQarray, pQlocation) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlCreateQueue(tResponse) into tArray
   if tArray["status"] is "ok" then
      return tArray["urls"]
   else
      combine tArray by cr and "="
      sort lines of tArray
      return tArray
   end if
end sqs.createQueue

-----

function sqs.listQueues pQprefix, pFormat
   if pQprefix is not empty then put pQprefix into tQarray["QueueNamePrefix"]
   put "ListQueues" into tQarray["Action"]
   
   put sqs.curl(tQarray) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlListQueues(tResponse) into tArray
   if tArray["status"] is "ok" then
      return tArray["urls"]
   else
      combine tArray by cr and "="
      sort lines of tArray
      return tArray
   end if
end sqs.listQueues

-----

function sqs.deleteQueue pQurl, pFormat
   put "DeleteQueue" into tQarray["Action"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlDeleteQueue(tResponse) into tArray
   if tArray["status"] is "ok" then
      return empty
   else
      combine tArray by cr and "="
      sort lines of tArray
      return tArray
   end if
end sqs.deleteQueue

-----

function sqs.getQueueAttributes pQurl, pFormat
   put "GetQueueAttributes" into tQarray["Action"]
   put "All" into tQarray["AttributeName"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlGetQueueAttributes(tResponse) into tArray
   if pFormat is not "array" then
      combine tArray by cr and "="
      sort lines of tArray
   end if
   return tArray
end sqs.getQueueAttributes

-----

function sqs.setVisibilityTimeout pQurl, pTimeout, pFormat
   if pTimeout is not an integer or pTimeout < 0 or pTimeout > 7200 then
      return "error: timeout value must be an integer from 0 to 7200 inclusive"
   end if
   
   put "SetQueueAttributes" into tQarray["Action"]
   put "VisibilityTimeout" into tQarray["Attribute.Name"]
   put pTimeout into tQarray["Attribute.Value"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlSetQueueAttributes(tResponse) into tArray
   if pFormat is not "array" then
      combine tArray by cr and "="
      sort lines of tArray
   end if
   return tArray
end sqs.setVisibilityTimeout

-----
/*
As of early Novemmber '08, there is a bug in SQS that means we can't use chars > 127 or UTF8
in messages. So for now, either base64encode or urlencode messages if you need to send anything
other than ascii up to numtochar(127)
*/

function sqs.sendMessage pQurl, pMessage, pFormat
   get length(pMessage)
   if it < 1 or it > 8192 then \
         return "error: message must be from 1 to 8192 bytes"
   
   put "SendMessage" into tQarray["Action"]
   put pMessage into tQarray["MessageBody"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlSendMessage(tResponse) into tArray
   if tArray["md5ofmessage"] is not md5.hex(pMessage) then \
         put "md5 mismatch" into tArray["error"]
   
   if pFormat is not "array" then
      combine tArray by cr and "="
      sort lines of tArray
   end if
   return tArray
end sqs.sendMessage

-----

function sqs.receiveMessage pQurl, pNumMessages, pVisibilityTimeout, pFormat
   put "ReceiveMessage" into tQarray["Action"]
   
   get pNumMessages
   if it is an integer and it >= 1 and it <= 10 then \
         put it into tQarray["MaxNumberOfMessages"]
   
   get pVisibilityTimeout
   if it is an integer and it >=0 and it <= 7200 then \
         put it into tQarray["VisibilityTimeout"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlReceiveMessage(tResponse) into tArray
   if pFormat is not "array" then
      combine tArray by cr and "="
      sort lines of tArray
   end if
   return tArray
end sqs.receiveMessage

-----


function sqs.deleteMessage pQurl, pReceiptHandle
   put "DeleteMessage" into tQarray["Action"]
   put pReceiptHandle into tQarray["ReceiptHandle"]
   
   put sqs.curl(tQarray, pQurl) into tCurl
   put curl.runTilDone(tCurl) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   
   put xmlDeleteMessage(tResponse) into tArray
   if pFormat is not "array" then
      combine tArray by cr and "="
      sort lines of tArray
   end if
   return tArray
end sqs.deleteMessage

-----

on sqs.pushMessage pQurl, pMessage
   put sqs.sendMessage(pQurl, pMessage, "array") into tResponse
   if tResponse["status"] is "ok" then
      return empty
   else
      return tResponse["error"]
   end if
end sqs.pushMessage

-----

function sqs.popMessage pQurl, pFormat
   put sqs.receiveMessage(pQurl, 1, ,"array") into tMessage
   if tMessage["status"] is "ok" then
      get sqs.deleteMessage(pQurl, tMessage["receipthandle,1"])
      if pFormat is "array" then
         return tMessage
      else
         return tMessage["body,1"]
      end if
   else
      return "error:" && tMessage["code"]
   end if
end sqs.popMessage

-----

function sqs.addPermission pQurl, pLabel, pPermissions
   
end sqs.addPermission

function sqs.removePermission pQurl, pLabel
   
end sqs.removePermission

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> internals
------------------

private function sqs.send pQarray, pQurl
   put sqs.curl(pQarray, pQurl) into tCurl
   return curl.runTilDone(tCurl)
end sqs.send

-----

private function sqs.curl pQarray, pQurl
   if (pQurl is "US") or (pQurl is empty) then
      put kUsEndpoint into pQurl
   else if pQurl is "EU" then
      put kEuEndpoint into pQurl
   end if
   
   put sqs.makePostData(pQarray, pQurl) into tPostData
   
   put 0 into tCurl
   repeat until tCurl > 0
      put curl.new() into tCurl
      if tCurl = 0 then wait 50 millisecs with messages
   end repeat
   curl.setUrl tCurl, pQurl
   curl.setPostData tCurl, tPostData
   curl.setMethod tCurl, "POST"
   return tCurl
end sqs.curl

-----

private function sqs.makePostData pQarray, pQurl
   put getAwsAccessKey() into pQarray["AWSAccessKeyId"]
   put zDate() into pQarray["Timestamp"]
   put kApiVersion into pQarray["Version"]
   
   -- put "1" into pQarray["SignatureVersion"]
   -- put sqs.type1Auth(pQarray) into pQarray["Signature"]
   
   put "2" into pQarray["SignatureVersion"]
   put "HmacSHA256" into pQarray["SignatureMethod"]
   put sqs.type2Auth(pQarray, pQurl) into pQarray["Signature"]
   
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then \
            put L & "=" & urlencode(pQarray[L]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
   
   return tQueryString
end sqs.makePostData

-----

private function sqs.type1Auth pQarray
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then put L & pQarray[L] after tStringToSign
   end repeat
   
   put hmacSha1.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end sqs.type1Auth

-----

private function sqs.type2Auth pQarray, pQurl
   
   replace "http://queue.amazonaws.com" with empty in pQurl
   put "POST" & cr & "queue.amazonaws.com" & cr & pQurl & cr into tStringToSign
   
   set the casesensitive to true
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      put pcEncode(L) & "=" & pcEncode(pQarray[L]) & "&" after tStringToSign
   end repeat
   delete char -1 of tStringToSign
   
   put hmacSha256.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end sqs.type2Auth

-----

private function sqs.makePermissions pLabel, pPermissions
   
end sqs.makePermissions

---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> xml responses
--------------------------

private function getTree pXml
   get offset("<?xml", pXml) 
   put revCreateXMLTree(char it to -1 of pXML,true,true,false) into tTree
   if "<Error>" is in pXml then
      put sqs.xmlErrorResponse(tTree) into tArray
      put "error" into tArray["status"]
      revDeleteXmlTree tTree
      return tArray
   else
      return tTree
   end if
end getTree

-----

private function xmlListQueues pXml
   put getTree(pXml) into tTree
   if tTree["status"] is "error" then
      return tTree
   else
      put "ListQueuesResponse/ListQueuesResult" into tNode
      put xmlQueueList(tTree, tNode) into tArray
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlListQueues

-----

private function xmlCreateQueue pXml
   put getTree(pXml) into tTree
   if "<Error>" is in pXml then
      put sqs.xmlErrorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put "CreateQueueResponse/CreateQueueResult" into tNode
      put xmlQueueList(tTree, tNode) into tArray
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlCreateQueue


-----

private function xmlDeleteQueue pXml
   put getTree(pXml) into tTree
   if "<Error>" is in pXml then
      put sqs.xmlErrorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlDeleteQueue
-----

private function xmlQueueList pTree, pNode
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode) & cr after tList
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   put char 1 to -2 of tList into tArray["urls"]
   return tArray
end xmlQueueList

-----

private function xmlGetQueueAttributes pXml
   put getTree(pXml) into tTree
   if "<Error>" is in pXml then
      put sqs.xmlErrorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put "getQueueAttributesResponse/GetQueueAttributesResult" into tNode
      put xmlQueueAttributes(tTree, tNode) into tArray
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlGetQueueAttributes

-----

private function xmlQueueAttributes pTree, pNode
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode & "/Name") into tKey
      put revXmlNodeContents(pTree, tNode & "/Value") into tArray[tKey]
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end xmlQueueAttributes

-----

private function xmlSetQueueAttributes
   put getTree(pXml) into tTree
   if "<Error>" is in pXml then
      put sqs.xmlErrorResponse(tTree) into tArray
      put "error" into tArray["status"]
   else
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlSetQueueAttributes

-----

private function xmlSendMessage pXml
   put getTree(pXml) into tTree
   if tTree["status"] is "error" then
      return tTree
   else
      put "SendMessageResponse/SendMessageResult" into tNode
      put revXmlNodeContents(tTree, tNode & "/MessageId") \
            into tArray["messageid"]
      put revXmlNodeContents(tTree, tNode & "/MD5OfMessageBody") \
            into tArray["md5ofmessage"]
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlSendMessage

-----

private function xmlReceiveMessage pXml
   put getTree(pXml) into tTree
   if tTree["status"] is "error" then
      return tTree
   else
      put "ReceiveMessageResponse/ReceiveMessageResult" into tNode
      put xmlMessageList(tTree, tNode) into tArray
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlReceiveMessage

-----

private function xmlMessageList pTree, pNode
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      add 1 to c
      put xmlMessage(pTree, tNode, c) into tMessageArray
      if tArray is not an array then
         put tMessageArray into tArray
      else
         union tArray with tMessageArray
      end if
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   put c into tArray["numberofmessages"]
   return tArray
end xmlMessageList

-----

private function xmlMessage pTree, pNode, pMessageNum
   put revXmlNodeContents(pTree, pNode & "/MessageId") \
         into tArray["messageid", pMessageNum]
   put revXmlNodeContents(pTree, pNode & "/ReceiptHandle") \
         into tArray["receipthandle", pMessageNum]
   put revXmlNodeContents(pTree, pNode & "/MD5OfBody") \
         into tArray["md5ofbody", pMessageNum]
   put revXmlNodeContents(pTree, pNode & "/Body") \
         into tArray["body", pMessageNum]
   if tArray["md5ofbody",pMessageNum] <> md5.hex(tArray["body", pMessageNum]) \
         then put "md5 mismatch" into tArray["error", pMessageNum]
   return tArray
end xmlMessage

-----

private function xmlDeleteMessage pXml
   put getTree(pXml) into tTree
   if tTree["status"] is "error" then
      return tTree
   else
      put "ok" into tArray["status"]
   end if
   return tArray
   revDeleteXmlTree tTree
end xmlDeleteMessage

-----

private function sqs.xmlErrorResponse pTree
   put revXmlNodeContents(pTree, "ErrorResponse/Error/Type") \
         into tArray["type"]
   put revXmlNodeContents(pTree, "ErrorResponse/Error/Code") \
         into tArray["code"]
   put revXmlNodeContents(pTree, "ErrorResponse/Error/Message") \
         into tArray["message"]
   put revXmlNodeContents(pTree, "ErrorResponse/RequestID") \
         into tArray["requestid"]
   return tArray
end sqs.xmlErrorResponse

-----

private function xmlRequestId pTree, pNode
   return revXmlNodeContents(pTree, pNode & "/ResponseMetaData/RequestID")
end xmlRequestId
