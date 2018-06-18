Script "stack_awsLibs_button_id_1031"

/*
# Name: button "rds" of card id 1002 of stack "awsLibs"
# ID: button id 1031 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
rds library
version: 1.0.0b
date: 20091027
author: Mark Smith
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---

constant kApiVersion = "2009-10-16"

--> endpoints

function rds.getEndPoint
   return "rds.amazonaws.com"
   -- switch sRegion
   -- case "US"
   -- return "us-east-1.ec2.amazonaws.com"
   -- break
   -- case "EU"
   -- return "eu-west-1.ec2.amazonaws.com"
   -- break
   -- default
   -- return "ec2.amazonaws.com"
   -- break
   -- end switch
end rds.getEndPoint

-- on rds.setRegion pRegion
-- if pRegion is "US" then
-- put "US" into sRegion
-- else if pRegion is "EU" then
-- put "EU" into sRegion
-- else
-- put empty into sRegion
-- end if
-- end rds.setRegion

-- function rds.getRegion
-- return sRegion
-- end rds.getRegion
-- on rds.switchRegion
-- if sRegion is "US" or sRegion is empty then
-- put "EU" into sRegion
-- else
-- put "US" into sRegion
-- end if
-- end rds.switchRegion
-- -----
-- function rds.libVersion
-- return "libVersion : 1.0.0b" & cr & "apiVersion :" && kApiVersion
-- end rds.libVersion

--------------------------------
--> instance actions
--------------------------------

function rds.createDBinstance pArray
   repeat for each item i in "id,storagesize,class,engine,username,password"
      
   end repeat
   repeat for each item i in "port,dbname,paramgroup,securitygroups,zone," & \
         "maintwindow,buretention,buwindow"
      
   end repeat
end rds.createDBinstance

----------------------------------------
--> securityGroup actions
----------------------------------------

function rds.describeSecurityGroups pGrpNames, pFormat
   --put "xml" into pFormat
   put "DescribeDBSecurityGroups" into tQarray["Action"]
   put 100 into tQarray["MaxRecords"]
   
   put rds.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   put xmlDescribeSecurityGroups(tResponse) into tArray
   return tArray
end rds.describeSecurityGroups

-----

function ec2.createGroup pName, pDescription
   put "CreateSecurityGroup" into tQarray["Action"]
   put pName into tQarray["GroupName"]
   put pDescription into tQarray["GroupDescription"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.createGroup

-----

function ec2.deleteGroup pGrpName
   put "DeleteSecurityGroup" into tQarray["Action"]
   put pGrpName into tQarray["GroupName"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.deleteGroup

-----

function ec2.authorizeGroup pGrpName, pFromPort, pToPort, pProtocol, \
      pCidrIp, pFormat
   
   put "AuthorizeSecurityGroupIngress" into tQarray["Action"]
   put pGrpName into tQarray["GroupName"]
   put pFromPort into tQarray["FromPort"]
   put pToPort into tQarray["ToPort"]
   put pProtocol into tQarray["IpProtocol"]
   if pCidrIp is empty then put "0.0.0.0/0" into tQarray["CidrIp"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.authorizeGroup

-----

function ec2.authorizeGroupByPair pGrpName, pProtocol, pSourceOwner, \
      pSourceGroup, pFormat
   
   put "AuthorizeSecurityGroupIngress" into tQarray["Action"]
   put pGrpName into tQarray["GroupName"]
   put pSourceOwner into tQarray["SourceSecurityGroupOwnerId"]
   put pSourceGroup into tQarray["SourceSecurityGroupName"]
   put pProtocol into tQarray["IpProtocol"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.authorizeGroupByPair

-----

function ec2.deauthorizeGroup pGrpName, pFromPort, pToPort, pProtocol, \
      pCidrIp, pFormat
   
   put "RevokeSecurityGroupIngress" into tQarray["Action"]
   put pGrpName into tQarray["GroupName"]
   put pFromPort into tQarray["FromPort"]
   put pToPort into tQarray["ToPort"]
   put pProtocol into tQarray["IpProtocol"]
   if pCidrIp is empty then put "0.0.0.0/0" into tQarray["CidrIp"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.deauthorizeGroup

-----
function ec2.deauthorizeGroupByPair pGrpName, pProtocol, pSourceOwner, \
      pSourceGroup, pFormat
   
   put "RevokeSecurityGroupIngress" into tQarray["Action"]
   put pGrpName into tQarray["GroupName"]
   put pSourceOwner into tQarray["SourceSecurityGroupOwnerId"]
   put pSourceGroup into tQarray["SourceSecurityGroupName"]
   put pProtocol into tQarray["IpProtocol"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.deauthorizeGroupByPair
----- 

private function makeGroupParams pGrpName, pFromPort, pToPort, pProtocol, \
      pCidrIp, pSourceOwnerId, pSourceGroup
   
   put pGrpName into tQarray["GroupName"]
   put pFromPort into tQarray["FromPort"]
   put pToPort into tQarray["ToPort"]
   put pProtocol into tQarray["IpProtocol"]
   if pSourceOwnerId is empty and pCidrIp is empty then \
         put "0.0.0.0/0" into tQarray["CidrIp"]
   if pCidrIp is empty then
      put pSourceOwnerId into tQarray["SourceSecurityGroupOwnerId"]
      put pSourceGroup into tQarray["SourceSecurityGroupName"]
   end if
   return tQarray
end makeGroupParams


------------------------------
--> other actions
------------------------------

function ec2.describeRegions pFormat, pRegions
   put "DescribeRegions" into tQarray["Action"]
   if pRegions is not empty then
      put 0 into c
      repeat for each line L in pRegions
         put L into tQarray["RegionName." & c]
         add 1 to c
      end repeat
   end if
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeRegions(tResponse) into tArray
   if pFormat is "list" then combine tArray by cr and "="
   return tArray
end ec2.describeRegions

-----

function ec2.describeAvailabilityZones pFormat
   put "DescribeAvailabilityZones" into tQarray["Action"]
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
       return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeAvailabilityZones(tResponse) into tArray
   if pFormat is "list" then combine tArray by cr and "="
   return tArray
end ec2.describeAvailabilityZones

-----

function ec2.getConsoleOutput pInstanceId, pFormat
   put "GetConsoleOutput" into tQarray["Action"]
   put pInstanceId into tQarray["InstanceId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlGetConsoleOutput(tResponse) into tArray
   return tArray
end ec2.getConsoleOutput

----=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=----
-------------------------
--> cloudWatch
-------------------------

function ec2.listMetrics pFormat
   put "ListMetrics" into tQarray["Action"]
   put cw.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlListMetrics(tResponse) into tArray
   return tArray
end ec2.listMetrics

-----

function ec2.getMetricStatistics
   put "GetMetricStatistics" into tQarray["Action"]
   
   
   put cw.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlGetMetricStatistics(tResponse) into tArray
   return tArray
end ec2.getMetricStatistics

-----

function ec2.monitorInstances pInstances, pFormat
   put "MonitorInstances" into tQarray["Action"]
   
   repeat for each line L in pInstances
      add 1 to count
      if L is not empty then put L into tQarray["InstanceId." & count]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlMonitorInstances(tResponse) into tArray
   return tArray
end ec2.monitorInstances

-----

function ec2.unmonitorInstances pInstances
   put "UnmonitorInstances" into tQarray["Action"]
   
   repeat for each line L in pInstances
      add 1 to count
      if L is not empty then put L into tQarray["InstanceId." & count]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlMonitorInstances(tResponse) into tArray
   return tArray
end ec2.unmonitorInstances


----=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=----
-------------------------
--> internals
-------------------------

-- uses libUrl
private function rds.sendB pQarray
   
end rds.sendB

-----

private function rds.send pQarray
   put rds.makePostData(pQarray) into tPostData
   return curl.post("https://" & rds.getEndPoint(), tPostData)
end rds.send

-----

private function rds.makePostData pQarray
   put getAwsAccessKey() into pQarray["AWSAccessKeyId"]
   put zDate() into pQarray["Timestamp"]
   put kApiVersion into pQarray["Version"]
   put "2" into pQarray["SignatureVersion"]
   put "HmacSHA256" into pQarray["SignatureMethod"]
   
   put rds.type2Auth(pQarray) into pQarray["Signature"]
   
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then \
            put L & "=" & pcEncode(pQarray[L]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
   
   return tQueryString
end rds.makePostData

-----

private function cw.send pQarray
   put cw.makePostData(pQarray) into tPostData
   return curl.post("https://" & cw.getEndPoint(), tPostData)
end cw.send

private function cw.makePostData pQarray
   put getAwsAccessKey() into pQarray["AWSAccessKeyId"]
   put zDate() into pQarray["Timestamp"]
   put kCWVersion into pQarray["Version"]
   put "2" into pQarray["SignatureVersion"]
   put "HmacSHA256" into pQarray["SignatureMethod"]
   
   put ec2.type2Auth(pQarray) into pQarray["Signature"]
   
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then \
            put L & "=" & URLEncode(pQarray[L]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
end cw.makePostData


-----

private function rds.type0Auth pQarray
   put pQarray["Action"] & pQarray["Timestamp"] into tStringToSign
   return hmacSha1.b64(tStringToSign, getAwsSecretkey())
end rds.type0Auth

-----

private function rds.type1Auth pQarray
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then put L & pQarray[L] after tStringToSign
   end repeat
   
   put hmacSha1.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end rds.type1Auth

-----

private function rds.type2Auth pQarray
   put "POST" & cr & rds.getEndPoint() & cr & "/" & cr into tStringToSign
   
   set the caseSensitive to true
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      put pcEncode(L) & "=" & pcEncode(pQarray[L]) & "&" after tStringToSign
   end repeat
   delete char -1 of tStringToSign
   
   put hmacSha256.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end rds.type2Auth

----=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=----
----=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=----
------------------------------
--> xml responses
------------------------------

function rds.xmlResponse pXml
   put revCreateXMLTree(pXml, true, true, false) into tTree
   put revXMLRootNode(tTree) into tRoot
   put xmlResponseMetaData(tTree, tRoot) into tArray["responsemetadata"]
   do "put xml" & tRoot & "(" & tTree & ") into tArray[" & q(response) & "]"
   revDeleteXMLTree tTree
   return tArray
end rds.xmlResponse

private function xmlResponseMetaData pTree, pRoot
   put revXMLNodeContents(pTree, pRoot & "/ResponseMetadata/RequestId") \
         into tArray["requestid"]
   return tArray
end xmlResponseMetaData

-----

private function xmlDescribeDBSecurityGroupsResponse pTree
   put "DescribeDBSecurityGroupsResponse/DescribeDBSecurityGroupsResult/" & \
         "DBSecurityGroups" into tNodeA
   -- put revXMLFirstChild(pTree, tNodeA) into tNode
   -- repeat while tNode is not empty and "xmlerr" is not in tNode
   -- put revXMLNodeContents(pTree, tNode & "/DBSecurityGroupName") into tName
   -- put xmlDBSecurityGroup(pTree, tNode) into tArray["dbsecuritygroups"][tName]
   -- put revXMLNextSibling(pTree, tNode) into tNode
   -- end repeat
   put xmlResponseToArray(pTree, tNodeA) into tArray
   return tArray
end xmlDescribeDBSecurityGroupsResponse

private function xmlDBSecurityGroup pTree, pNode
   put revXMLNodeContents(pTree, pNode & "/DBSecurityGroupDescription") \
         into tArray["description"]
   put revXMLNodeContents(pTree, pNode & "/DBSecurityGroupName") \
         into tArray["name"]
   put revXMLNodeContents(pTree, pNode & "/OwnerId") into tArray["ownerid"]
   
   put revXMLFirstChild(pTree, pNode & "/EC2SecurityGroups") into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXMLNodeContents(pTree, tNode & "/EC2SecurityGroupName") into tName
      put xmlEc2SecurityGroup(pTree, tNode) \
            into tArray["ec2securitygroups"][tName]
      put revXMLNextSibling(pTree, tNode) into tNode
   end repeat
   
   put revXMLFirstChild(pTree, pNode & "/IPRanges") into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      add 1 to c
      put xmlIpRange(pTree, tNode) into tArray["ipranges"][c]
      put revXMLNextSibling(pTree, tNode) into tNode
   end repeat
   
   return tArray
end xmlDBSecurityGroup

private function xmlEc2SecurityGroup pTree, pNode
   put revXMLNodeContents(pTree, pNode & "/EC2SecurityGroupName") \
         into tArray["name"]
   put revXMLNodeContents(pTree, pNode & "/EC2SecurityGroupOwnerId") \
         into tArray["ownerid"]
   put revXMLNodeContents(pTree, pNode & "/Status") into tArray["status"]
   return tArray
end xmlEc2SecurityGroup

private function xmlIpRange pTree, pNode
   put revXMLNodeContents(pTree, pNode & "/CIDRIP") into tArray["cidrip"]
   put revXMLNodeContents(pTree, pNode & "/Status") into tArray["status"]
   return tArray
end xmlIpRange

-----

private function xmlDescribeDBSnapshotsResponse pTree
   put "DescribeDBSnapshotsResponse/DescribeDBSnapshotsResult/DBSnapshots" \
         into tNodeA
   -- put revXMLFirstChild(pTree, tNodeA) into tNode
   -- repeat while tNode is not empty and "xmlerr" is not in tNode
   -- add 1 to c
   -- put xmlDBSnapshot(pTree, tNode) into tArray[c]
   -- put revXMLNextSibling(pTree, tNode) into tNode
   -- end repeat
   put xmlResponseToArray(pTree, tNodeA) into tArray
   return tArray
end xmlDescribeDBSnapshotsResponse

private function xmlDBSnapshot pTree, pNode
   set the itemDelimiter to "/"
   put revXMLFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put item -1 of tNode into tName
      put revXMLNodeContents(pTree, tNode) into tArray[tName]
      put revXMLNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end xmlDBSnapshot

-----

function xtoa pXml
   put revCreateXMLTree(pXml, true, true, false) into tTree
   put revXMLRootNode(tTree) into tRoot
   put xmlResponseMetaData(tTree, tRoot) into tArray["responsemetadata"]
   put xmlResponseToArray(tTree, tRoot) into tArray["response"]
   revDeleteXMLTree tTree
   return tArray
end xtoa



function xmlResponseToArray pTree, pNode, pName
   set the itemDelimiter to "/"
   put revXMLFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put item -1 of tNode into tName
      get offset("[", tName)
      if it > 0 then put char it + 1 to -2 of tName into tName
      
      if revXMLNumberOfChildren(pTree, tNode,,0) = 0 then
         put revXMLNodeContents(pTree, tNode) into tArray[tName]
      else
         put xmlResponseToArray(pTree, tNode) into tArray[tName]
      end if
      put revXMLNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end xmlResponseToArray

--=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=--
----=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=---=----
