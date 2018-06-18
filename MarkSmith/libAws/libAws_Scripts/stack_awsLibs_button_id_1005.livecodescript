Script "stack_awsLibs_button_id_1005"

/*
# Name: button "sdb" of card id 1002 of stack "awsLibs"
# ID: button id 1005 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
sdb library
version: 1.0.0b
date: 20090601
author: mark smith
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> locals & constants

constant kApiVersion = "2009-04-15"
constant kEndPointUS = "sdb.amazonaws.com"
constant kEndPointEU = "sdb.eu-west-1.amazonaws.com"
local sRegion = "US"
local sCancel = false

on sdb.setRegion pRegion
   if pRegion is among the items of "US,EU" then
      put pRegion into sRegion
   else
      return "sdb.error: region not recognised:" && pRegion
   end if
end sdb.setRegion

function sdb.getRegion
   return sRegion
end sdb.getRegion

private function sdbGetEndPoint
   switch sRegion
      case "EU"
         return kEndPointEU
         break
      default
         return kEndPointUS
         break
   end switch
end sdbGetEndPoint

---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
--> interface
---------------------

function sdb.domainExists pDomain
   if not sdb.validDomainName(pDomain) then return "error: invalid domain name"
   put sdb.listDomains() into tDomains
   if "error:" is not in tDomains then
      return pDomain is among the lines of tDomains
   else
      return tDomains
   end if
end sdb.domainExists

-----

#### takes a domain name and attempts to create it.

function sdb.createDomain pDomain, pFormat
   if not sdb.validDomainName(pDomain) then return "error: invalid domain name"
   put "CreateDomain" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   return sdb.send(tQarray, pFormat)
end sdb.createDomain

-----

function sdb.validDomainName pName
   --allowed chars are: a-z, A-Z, 0-9, '_', '-', and '.'  must be between 3 and 255 chars
   get length(pName)
   if it < 3 or it > 255 then return false
   return matchtext(pName,"^[A-Za-z0-9 \-_.]+$")
end sdb.validDomainName

-----

function sdb.deleteDomain pDomain, pFormat
   if not sdb.validDomainName(pDomain) then return "error: invalid domain name"
   if pDomain is empty then return "error: no domain specified"
   
   put "DeleteDomain" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   return sdb.send(tQarray, pFormat)
end sdb.deletedomain

-----

function sdb.listDomains pFormat
   put "ListDomains" into tQarray["Action"]
   put 100 into tQarray["MaxNumberOfDomains"]
   return sdb.send(tQarray, pFormat)
end sdb.listDomains

-----

function sdb.domainMetadata pDomain, pFormat
   put "DomainMetadata" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   return sdb.send(tQarray, pFormat)
end sdb.domainMetadata

-----

function sdb.getAttributes pDomain, pItem, pAttributeNames, pFormat
   put sdb.getAttributes.curl(pDomain, pItem, pAttributeNames) into tCurl
   return sdb.send(tCurl, pFormat)
end sdb.getAttributes

-----

function sdb.getAttributes.curl pDomain, pItem, pAttributeNames
   put getAttributeList(pAttributeNames) into tQarray
   put "GetAttributes" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   put pItem into tQarray["ItemName"]
   return sdb.curl(tQarray)
end sdb.getAttributes.curl

-----

function sdb.putAttributes pDomain, pItem, pAttributes, pReplace, pFormat
   put sdb.putAttributes.curl(pDomain, pItem, pAttributes, pReplace) into tCurl
   return sdb.send(tCurl, pFormat)
end sdb.putAttributes

-----

function sdb.putAttributes.curl pDomain, pItem, pAttributes, pReplace
   put putAttributeList(pAttributes, pReplace) into tQarray
   
   put "PutAttributes" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   put pItem into tQarray["ItemName"]
   
   return sdb.curl(tQarray)
end sdb.putAttributes.curl

-----

function sdb.batchPutAttributes pDomain, pAttributeData, pReplace, pFormat
   put sdb.batchPutAttributes.curl(pDomain, pAttributeData) into tCurl
   return sdb.send(tCurl, pFormat)
end sdb.batchPutAttributes

-----

function sdb.batchPutAttributes.curl pDomain, pAttributeData, pReplace
   put batchPutAttributeList(pAttributeData, pReplace) into tQarray
   if "error" is in tQarray then return tQarray
   
   put "BatchPutAttributes" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   
   return sdb.curl(tQarray)
end sdb.batchPutAttributes.curl

-----

function sdb.deleteAttributes pDomain, pItem, pAttributes, pFormat
   put sdb.deleteAttributes.curl(pDomain, pItem, pAttributes) into tCurl
   return sdb.send(tCurl)
end sdb.deleteattributes

-----

function sdb.deleteAttributes.curl pDomain, pItem, pAttributes
   put deleteAttributeList(pAttributes) into tQarray
   put "DeleteAttributes" into tQarray["Action"]
   put pDomain into tQarray["DomainName"]
   put pItem into tQarray["ItemName"]
   
   return sdb.curl(tQarray)
end sdb.deleteAttributes.curl

-----

on sdb.deleteitem pDomain, pItem, pFormat
   get sdb.deleteAttributes(pDomain, pItem,,pFormat)
   if it is not empty then return it
end sdb.deleteitem

-----

function sdb.select pSelectExpression, pFormat, pNextToken
   put word 2 of pSelectExpression into tOutputType
   
   put sdb.select.curl(pSelectExpression, pNextToken) into tCurl
   
   put sdb.send(tCurl, pFormat) into tResponse
   
   if pFormat is among the items of "xml,complete" then
      return tResponse
   else
      switch tOutputType
         case "count(*)"
            return tResponse["Domain"]["Count"]
            break
         case "itemName()"
            return keys(tResponse)
            break
         default
            return tResponse
            break
      end switch
   end if
   
end sdb.select

function sdb.select.curl pSelectExpression, pNextToken
   put "Select" into tQarray["Action"]
   put pSelectExpression into tQarray["SelectExpression"]
   if pNextToken is not empty then put pNextToken into tQarray["NextToken"]
   
   return sdb.curl(tQarray)
end sdb.select.curl

-----

function sdb.selectAll pSelectExpression, pFormat
   put empty into tNextToken
   
end sdb.selectAll


-----

on sdb.Cancel
   put true into sCancel
end sdb.Cancel

-----
-=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
--> multi actions
------------------------

local sMultiGet

on sdb.multiGet pDomain, pItemList, pAttributes, pMaxCurls
   if not nzp(pMaxCurls) then put 8 into pMaxCurls
   put empty into sMultiGet
   put pDomain into sMultiGet["domain"]
   put pItemList into sMultiGet["itemlist"]
   put pAttributes into sMultiGet["attributes"]
   put "running" into sMultiGet["status"]
   put the number of lines in pItemList into sMultiGet["numitems"]
   put 0 into sMultiGet["numdone"]
   put pMaxCurls into sMultiGet["maxcurls"]
   
   send  "doSdbMultiGet" to me in 2 millisecs
end sdb.multiGet

-----

on doSdbMultiGet
   repeat for each line L in sMultiGet["itemlist"]
      if the optionkey is down then exit to top
      put sdb.getAttributes.curl(sMultiGet["domain"], L, sMultiGet["attributes"]) into tCurl
      curl.execute tCurl
      put tCurl into sMultiGet["queue"][L]["curl"]
      if "processSdbMultiQueue" is not in the pendingmessages then send "processSdbMultiQueue" to me in 2 millisecs
      wait while (the number of lines in keys(sMultiGet["queue"])) > (sMultiGet["maxcurls"] - 1) with messages
      wait 5 millisecs with messages
   end repeat
end doSdbMultiGet

-----

on processSdbMultiQueue
   repeat for each key k in sMultiGet["queue"]
      if curl.done(sMultiGet["queue"][k]["curl"]) then
         put curl.response(sMultiGet["queue"][k]["curl"]) into tResponse
         handleMultiGetResponse tResponse, k
         curl.cleanup sMultiGet["queue"][k]["curl"]
         delete variable sMultiGet["queue"][k]
         add 1 to sMultiGet["numdone"]
      end if
   end repeat
   if the number of lines in keys(sMultiGet["queue"]) > 0 then
      if "processSdbMultiQueue" is not in the pendingmessages then
         send "processSdbMultiQueue" to me in 50 millisecs
      end if
   else
      put "done" into sMultiGet["status"]
   end if
end processSdbMultiQueue

-----

private command handleMultiGetResponse pResponse, tItem
   if "curl" is in word 1 of pResponse then
      put sMultiGet["responses"][tItem]["error"]
   else
      put xmlGetAttributes(pResponse) into sMultiGet["responses"][tItem]
   end if
end handleMultiGetResponse

-----

function sdb.MultiGetStatus
   return sMultiGet
end sdb.MultiGetStatus

function sdb.MultiGet.done
   return sMultiGet["status"] is in "done,cancelled,error"
end sdb.MultiGet.done

-=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
--> sdb internals
------------------------

### p1 is either the query array, or the curl id

private function sdb.send p1, pFormat
   put false into sCancel
   
   if p1 is an array then
      put sdb.curl(p1) into tCurl
   else
      put p1 into tCurl
   end if
   -- put curl.config(tCurl) into tConf
   -- curl.cleanup tCurl
   -- return tConf
   
   try
      curl.execute tCurl
      wait until curl.done(tCurl) with messages
      put curl.response(tCurl) into tResponse
      put curl.error(tCurl) into tCurlErr
      curl.cleanup tCurl
   catch tError
      put tError into tCurlErr
   end try
   if tCurlErr is not empty then return tCurlErr
   
   get offset("<?xml", tResponse)
   if it > 0 then
      delete char 1 to it - 1 of tResponse
   else -- no xml!
      return tResponse
   end if
   
   if pFormat is "xml" then return tResponse
   
   put sdbXml(tResponse) into tArray
   if pFormat is "complete" then
      return tArray
   else
      return tArray["data"]
   end if
end sdb.send

-----

function sendLU p1, pFormat
   put sdb.makePostData(p1) into tPostData
   put "https://" & sdbGetEndPoint() into tUrl
   set the httpheaders to "Content-Type: application/x-www-form-urlencoded; charset=utf-8"
   
   libUrlSetSSLVerification false
   post tPostData to url tUrl
   put it into tResponse
   
   get offset("<?xml", tResponse)
   if it > 0 then
      delete char 1 to it - 1 of tResponse
   else -- no xml!
      return tResponse
   end if
   
   if pFormat is "xml" then return tResponse
   
   put sdbXml(tResponse) into tArray
   if pFormat is "complete" then
      return tArray
   else
      return tArray["data"]
   end if
end sendLU

private function sdb.curl pQarray
   put sdb.makePostData(pQarray) into tPostData
   
   put 0 into tCurl
   repeat 10
      put curl.new() into tCurl
      if tCurl = 0 then
         wait 50 millisecs with messages
      else
         exit repeat
      end if
   end repeat
   if curl = 0 then return 0
   
   curl.setUrl tCurl, "https://" & sdbGetEndPoint()
   curl.setPostData tCurl, tPostData
   curl.setMethod tCurl, "POST"
   curl.setHeaders tCurl, "Content-Type: application/x-www-form-urlencoded; charset=utf-8"
   
   return tCurl
end sdb.curl

-----

private function sdb.makePostData pQarray
   repeat for each key k in pQarray
      put utf8encode(pQarray[k]) into pQarray[k]
   end repeat
   
   put getAwsAccessKey() into pQarray["AWSAccessKeyId"]
   put zDate() into pQarray["Timestamp"]
   put kApiVersion into pQarray["Version"]
   put "2" into pQarray["SignatureVersion"]
   put "HmacSHA256" into pQarray["SignatureMethod"]
   put sdb.type2Auth(pQarray) into pQarray["Signature"]
   
   put keys(pQarray) into tKeys
   sort lines of tKeys
   repeat for each line k in tKeys
      if pQarray[k] is not empty then put pcEncode(k) & "=" & pcEncode(pQarray[k]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
   
   return tQueryString
end sdb.makePostData

-----

private function sdb.type0Auth pQarray
   put pQarray["Action"] & pQarray["Timestamp"] into tStringToSign
   return hmacSha1.b64(tStringToSign, getAwsSecretkey())
end sdb.type0Auth

-----

private function sdb.type1Auth pQarray
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then put L & pQarray[L] after tStringToSign
   end repeat
   
   put hmacSha1.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end sdb.type1Auth

-----

private function sdb.type2Auth pQarray
   put "POST" & cr & sdbGetEndPoint() & cr & "/" & cr into tStringToSign
   
   set the casesensitive to true
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      put pcEncode(L) & "=" & pcEncode(pQarray[L]) & "&" after tStringToSign
   end repeat
   delete char -1 of tStringToSign
   -- put tStringToSign
   -- exit to top
   
   put hmacSha256.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end sdb.type2Auth

-----

private function putAttributeList pAttributes, pReplace
   if pAttributes is not an array and pAttributes is empty then return empty
   if pAttributes is not an array then split pAttributes by cr and "="
   
   repeat for each key k in pAttributes
      if pAttributes[k] is not an array then
         if pAttributes[k] is not empty then
            add 1 to c
            put k into tAttributeArray["Attribute." & c & ".Name"]
            if pReplace then put "true" into tAttributeArray["Attribute." & c & ".Replace"]
            put pAttributes[k] into tAttributeArray["Attribute." & c & ".Value"]
         end if
      else
         repeat for each key k2 in pAttributes[k]
            if pAttributes[k][k2] is not empty then
               add 1 to c
               put k into tAttributeArray["Attribute." & c & ".Name"]
               if pReplace then put "true" into tAttributeArray["Attribute." & c & ".Replace"]
               put pAttributes[k][k2] into tAttributeArray["Attribute." & c & ".Value"]
            end if
         end repeat
      end if
   end repeat
   
   return tAttributeArray
end putAttributeList

-----
### takes an array formed: tArray[itemname][attributename] = attributevalue
private function batchPutAttributeList pAttributeData, pReplace
   if the number of lines in keys(pAttributeData) > 25 then return "error:too many items (max: 25)"
   put 0 into numAttributes
   
   
   put 0 into tItemCount
   repeat for each key tItem in pAttributeData
      add the number of lines in keys(pAttributeData[tItem] to numAttributes
      if numAttributes > 256 then return "error:too many attributes (max: 256)"
      
      put 0 into tAttributeCount
      put tItem into tQarray["Item." & tItemCount & ".ItemName"]
      
      repeat for each key tAttribute in pAttributeData[tItem]
         put "Item." & tItemCount & ".Attribute." & tAttributeCount & ".Name" into tKey
         put tAttribute into tQarray[tKey]
         
         put "Item." & tItemCount & ".Attribute." & tAttributeCount & ".Value" into tKey
         put pAttributeData[tItem][tAttribute] into tQarray[tKey]
         
         if pReplace then
            put "Item." & tItemCount & ".Attribute." & tAttributeCount & ".Replace" into tKey
            put "true" into tQarray[tKey]
         end if
         
         add 1 to tAttributeCount
      end repeat
      add 1 to tItemCount
   end repeat
   
   return tQarray
end batchPutAttributeList


-----

private function getAttributeList pAttributeNames
   if pAttributeNames is empty then return empty
   
   replace comma with cr in pAttributeNames
   repeat for each line L in pAttributeNames
      add 1 to c
      put L into tQarray["AttributeName." & c]
   end repeat
   return tQarray
end getAttributeList

-----

private function deleteAttributeList pAttributes
   if pAttributes is not an array and pAttributes is empty then return empty
   if pAttributes is not an array then split pAttributes by cr and "="
   
   repeat for each key k in pAttributes
      if pAttributes[k] is empty then
         add 1 to c
         put k into tAtts["Attribute." & c & ".Name"]
      else
         repeat for each line L in pAttributes[k]
            add 1 to c
            put k into tAtts["Attribute." & c & ".Name"]
            put L into tAtts["Attribute." & c & ".Value"]
         end repeat
      end if
   end repeat
   return tAtts
end deleteAttributeList

-----

private function q pStr
   return quote & pStr & quote
end q

-----

private function sq pStr
   return "'" & pStr & "'"
end sq

-----

private function bq pStr
   return "`" & pStr & "`"
end bq

-----

function sdb.encodenum pNum
   if pNum is not a number then return pNum
   return format("%020.8f", pNum + (2 ^ 31 -1))
end sdb.encodeNum

function sdb.decodeNum pNum
   if pNum is not a number then return pNum
   return pNum - (2 ^ 31 - 1)
end sdb.decodeNum

-=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
--> sdbxml
----------------

private function sdbXml pXml
   set the itemdelimiter to "/"
   put revCreateXmlTree(pXml,true,true,false) into tTree
   
   if "<Errors" is in pXml then
      put errorResponse(tTree) into tArray["responseMetadata"]
      put tArray["responseMetadata"]["errormessage"] into tArray["data"]
      put "error" into tArray["status"]
   else
      put responseMetadata(tTree) into tArray["responseMetadata"]
      put "ok" into tArray["status"]
      
      
      get getNextToken(tTree)
      if it is not empty then put it into tArray["nexttoken"]
      
      if (tArray["status"] is "ok") then
         put revXmlRootNode(tTree) into tRoot
         put item -1 of revXmlFirstChild(tTree, tRoot) into tAction
         if tAction ends with "Result" then
            try
               do "put" && tAction & "(" & tTree & ") into tArray[" & q(data) & "]"
            catch tErr
               put "unknown xml response" into tArray["responseMetadata"]["errormessage"]
               put "error" into tArray["status"]
            end try
         end if
      end if
      
   end if
   revDeleteXmlTree tTree
   return tArray
end sdbXml

-----

private function getNextToken pTree
   put revXmlFirstChild(pTree, revXmlRootNode(pTree)) & "/NextToken" into tNode
   put revXmlNodeContents(pTree, tNode) into tNextToken
   if "xmlerr" is in tNextToken then
      return empty
   else
      return tNextToken
   end if
end getNextToken

-----

private function ListDomainsResult pTree
   put revXmlFirstChild(pTree, "ListDomainsResponse/ListDomainsResult") into tNode
   repeat until (tNode is empty) or ("xmlerr" is in tNode)
      if "DomainName" is in tNode then put utf8decode(revXmlNodeContents(pTree, tNode)) & cr after tDomainList
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   delete char -1 of tDomainList
   
   return tDomainList
end ListDomainsResult

-----

private function DomainMetadataResult pTree
   put revXmlFirstChild(pTree, "DomainMetadataResponse/DomainMetadataResult") into tNode
   set the itemdelimiter to "/"
   repeat until (tNode is empty) or ("xmlerr" is in tNode)
      --put round(revXmlNodeContents(pTree, tNode)) into tArray[item -1 of tNode]
      put nodeCont(pTree, tNode) into tArray[item -1 of tNode]
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   
   return tArray
end DomainMetadataResult

-----

private function GetAttributesResult pTree
   put revXmlFirstChild(pTree, "GetAttributesResponse/GetAttributesResult") into tNode
   repeat until (tNode is empty) or ("xmlerr" is in tNode)
      put attributeElement(pTree, tNode & "/Name") into tName
      add 1 to tAttrCount[tName]
      put attributeElement(pTree, tNode & "/Value") into tArray[tName][tAttrCount[tName]]
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   
   ### unfold single valued attributes
   repeat for each key k in tAttrCount
      if tAttrCount[k] = 1 then put tArray[k][1] into tArray[k]
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end GetAttributesResult

-----

private function selectResult pTree
   put "SelectResponse/SelectResult" into tNode
   
   put revXmlFirstChild(pTree, tNode) into tItemNode
   
   repeat until (tItemNode is empty) or ("xmlerr" is in tItemNode)
      if "/Item" is in tItemNode then
         -- get the name of the item
         put attributeElement(pTree, tItemNode & "/Name") into tName
         
         put xmlSelectItemAttributes(pTree, tItemNode) into tArray[tName]
      end if
      put revXmlNextSibling(pTree, tItemNode) into tItemNode
   end repeat
   
   return tArray
end selectResult

-----

private function CreateDomainResult pTree
   return empty
end CreateDomainResult

private function DeleteDomainResult pTree
   return empty
end DeleteDomainResult

private function PutAttributesResult pTree
   return empty
end PutAttributesResult

private function BatchPutAttributesResult pTree
   return empty
end BatchPutAttributesResult

private function DeleteAttributesResult pTree
   return empty
end DeleteAttributesResult

-----

private function xmlMakeTree pXml
   put offset("<?xml", pXml) into tOff
   
   switch
      case tOff = 0
         put "error" into tArray["status"]
         put pXml into tArray["nonxmlresponse"]
         break
      case tOff > 1
         put char 1 to tOff - 1 of pXml into tArray["nonxmlresponse"]
      case tOff = 1
         put revCreateXmlTree(char tOff to -1 of pXml, true, true, false) into tTree
         if "<Errors" is in pXml then
            put errorResponse(tTree) into tArray["responseMetadata"]
            put "error" into tArray["status"]
            revDeleteXmlTree tTree
         else
            put responseMetadata(tTree) into tArray["responseMetadata"]
            put "ok" into tArray["status"]
            put tTree into tArray["treeID"]
         end if
         break
   end switch
   
   return tArray
end xmlMakeTree

------

private function xmlSimpleResponse pXml
   put revCreateXmlTree(tXml, true, true, false) into tTree
   
   if "<Errors" is in pXml then
      put errorResponse(tTree) into tArray["responseMetadata"]
      put "error" into tArray["status"]
   else
      put responseMetadata(tTree) into tArray["responseMetadata"]
      put "ok" into tArray["status"]
   end if
   revDeleteXmlTree tTree
   return tArray
end xmlSimpleResponse

-----

private function responseMetadata pTree
   put revXmlRootNode(pTree) & "/ResponseMetadata" into tNode
   put revXmlNodeContents(pTree, tNode & "/RequestId") into tArray["requestid"]
   put revXmlNodeContents(pTree, tNode & "/BoxUsage") into tArray["boxusage"]
   return tArray
end responseMetadata

-----

private function errorResponse pTree
   try
      put revXmlNodeContents(pTree, "Response/Errors/Error/Code") into tArray["errorcode"]
      put revXmlNodeContents(pTree, "Response/Errors/Error/Message") into tArray["errormessage"]
      put revXmlNodeContents(pTree, "Response/Errors/Error/BoxUsage") into tArray["boxusage"]
      put revXmlNodeContents(pTree, "Response/RequestID") into tArray["requestid"]
      return tArray
   catch tError
      return tError
   end try
end errorResponse

-----


private function xmlListDomains pXml
   put xmlMakeTree(pXml) into tArray
   if tArray["status"] is "ok" then
      put tArray["treeID"] into tTree
      delete variable tArray["treeID"]
      
      put revXmlFirstChild(tTree, "ListDomainsResponse/ListDomainsResult") into tNode
      repeat until tNode is empty or "xmlerr" is in tNode
         put utf8decode(revXmlNodeContents(tTree, tNode)) & cr after tArray["domainlist"]
         put revXmlNextSibling(tTree, tNode) into tNode
      end repeat
      delete char -1 of tArray["domainlist"]
      
      revDeleteXmlTree tTree
   end if
   
   return tArray
end xmlListDomains

-----



private function xmlDomainMetadata pXml
   
   put xmlMakeTree(pXml) into tArray
   if tArray["status"] is "ok" then
      put tArray["treeID"] into tTree
      delete variable tArray["treeID"]
      
      put revXmlFirstChild(tTree, "DomainMetadataResponse/DomainMetadataResult") into tNode
      set the itemdelimiter to "/"
      repeat until tNode is empty or "xmlerr" is in tNode
         put round(revXmlNodeContents(tTree, tNode)) into tArray["domainMetaData"][item -1 of tNode]
         put revXmlNextSibling(tTree, tNode) into tNode
      end repeat
      
      revDeleteXmlTree tTree
   end if
   return tArray
end xmlDomainMetadata

-----



private function xmlGetAttributes pXml
   put xmlMakeTree(pXml) into tArray
   if tArray["status"] is "ok" then
      put tArray["treeID"] into tTree
      delete variable tArray["treeID"]
      
      put revXmlFirstChild(tTree, "GetAttributesResponse/GetAttributesResult") into tNode
      repeat until tNode is empty or "xmlerr" is in tNode
         put attributeElement(tTree, tNode & "/Name") into tName
         add 1 to tAttrCount[tName]
         put attributeElement(tTree, tNode & "/Value") into tArray["attributes"][tName][tAttrCount[tName]]
         
         put revXmlNextSibling(tTree, tNode) into tNode
      end repeat
      
      -- unfold single valued attributes
      repeat for each key k in tArray["attributes"]
         if the number of lines in keys(tArray["attributes"][k]) < 2 then
            put tArray["attributes"][k][1] into tArray["attributes"][k]
         end if
      end repeat
      
      revDeleteXmlTree tTree
   end if
   return tArray
end xmlGetAttributes

-----

private function xmlSelect pXml, pOutputType
   
   put xmlMakeTree(pXml) into tArray
   if tArray["status"] is "ok" then
      put tArray["treeID"] into tTree
      delete variable tArray["treeID"]
      
      put "SelectResponse/SelectResult" into tNode
      
      if "<NextToken" is in pXml then
         put revXmlNodeContents(tTree, tNode & "/NextToken") into tArray["NextToken"]
         replace crlf with empty in tArray["NextToken"]
         replace cr with empty in tArray["NextToken"]
      end if
      
      if "<Item" is in pXml then
         put revXmlFirstChild(tTree, tNode) into tItemNode
         
         if pOutputType is "count(*)" then
            put revXmlNodeContents(tTree, tItemNode & "/Attribute/Value") into tArray["itemcount"]
            
         else
            repeat until tItemNode  is empty or "xmlerr" is in tItemNode
               -- get the name of the item
               put attributeElement(tTree, tItemNode & "/Name") into tName
               if pOutputType is "itemName()" then
                  put tName & cr after tArray["itemlist"]
               else
                  -- get the attributes of the item
                  put xmlSelectItemAttributes(tTree, tItemNode) into tArray["items"][tName]
               end if
               put revXmlNextSibling(tTree, tItemNode) into tItemNode
            end repeat
         end if
      end if
      
      
      revDeleteXmlTree tTree
   end if
   
   return tArray
end xmlSelect

private function xmlSelectItemAttributes pTree, pNode
   
   put revXmlFirstChild(pTree, pNode) into tNode
   
   repeat until (tNode is empty) or ("xmlerr" is in tNode)
      if "Attribute" is in tNode then
         put attributeElement(pTree, tNode & "/Name") into tName
         
         put the number of lines in keys(tArray[tName]) + 1 into c
         put attributeElement(pTree, tNode & "/Value") into tArray[tName][c]
      end if
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   
   -- unfold single valued attributes
   repeat for each key k in tArray
      if the number of lines in keys(tArray[k]) < 2 then
         put tArray[k][1] into tArray[k]
      end if
   end repeat
   return tArray
end xmlSelectItemAttributes

-----

private function attributeElement pTree, pNode
   if "encoding=base64" is in revXmlAttributes(pTree, pNode, "=", cr) then
      put base64decode(revXmlNodeContents(pTree, pNode)) into tElement
   else
      put revXmlNodeContents(pTree, pNode) into tElement
   end if
   return utf8decode(tElement)
end attributeElement

-----

private function nodeCont pTree, pNode
   put revXmlNodeContents(pTree, pNode) into tContent
   if tContent is a number then
      return tContent + 0
   else
      return utf8decode(tContent)
   end if
end nodeCont

=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
---=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=
