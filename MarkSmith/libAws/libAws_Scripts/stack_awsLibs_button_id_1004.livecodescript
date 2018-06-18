Script "stack_awsLibs_button_id_1004"

/*
# Name: button "ec2" of card id 1002 of stack "awsLibs"
# ID: button id 1004 of card id 1002 of stack "awsLibs"
*/


---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
/*
ec2 library
version: 1.0.0b
date: 20081018
author: Mark Smith
*/
---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---

constant kApiVersion = "2008-12-01"
constant kCWVersion = "2009-05-15"
local sDefaultKeypair = "pstam-keypair"
local sRegion
local sRunInstance

--> endpoints

function ec2.getEndPoint
   switch sRegion
      case "US"
         return "us-east-1.ec2.amazonaws.com"
         break
      case "EU"
         return "eu-west-1.ec2.amazonaws.com"
         break
      default
         return "ec2.amazonaws.com"
         break
   end switch
end ec2.getEndPoint

on ec2.setRegion pRegion
   if pRegion is "US" then
      put "US" into sRegion
   else if pRegion is "EU" then
      put "EU" into sRegion
   else
      put empty into sRegion
   end if
end ec2.setRegion

function ec2.getRegion
   return sRegion
end ec2.getRegion

on ec2.switchRegion
   if sRegion is "US" or sRegion is empty then
      put "EU" into sRegion
   else
      put "US" into sRegion
   end if
end ec2.switchRegion

function cw.getEndPoint
   switch sRegion
      case "US"
         return "us-east-1.monitoring.amazonaws.com"
         break
      case "EU"
         return "eu-west-1.monitoring.amazonaws.com"
         break
      default
         return "monitoring.amazonaws.com"
         break
   end switch
   
end cw.getEndPoint

-----

function ec2.libVersion
   return "libVersion : 1.0.0b" & cr & "apiVersion :" && kApiVersion
end ec2.libVersion

--------------------------------
--> instance actions
--------------------------------

function ec2.describeInstances pFormat
   put "DescribeInstances" into tQarray["Action"]
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeInstances(tResponse) into tArray
   return tArray
end ec2.describeInstances

-----

on ec2.instance.init pArray
   put empty into sRunInstance
   put "RunInstances" into sRunInstance["Action"]
   put sDefaultKeyPair into sRunInstance["KeyName"]
   put 1 into sRunInstance["MinCount"]
   put 1 into sRunInstance["MaxCount"]
   put "default" into sRunInstance["SecurityGroup.1"]
   put "m1.small" into sRunInstance["InstanceType"]
   
   repeat for each line L in the keys of pArray
      if L is among the items of "KeyName,MinCount,MaxCount,InstanceType" then \
            put pArray[L] into sRunInstance[L]
      if "SecurityGroup" is in L then put pArray[L] into sRunInstance[L]
   end repeat
end ec2.instance.init

on ec2.instance.setImage pImageId
   put pImageId into sRunInstance["ImageId"]
end ec2.instance.setImage

on ec2.instance.setKernel pKernelId
   put pKernelId into sRunInstance["KernelId"]
end ec2.instance.setKernel

on ec2.instance.setRamdisk pRamdiskId
   put pRamdiskId into sRunInstance["ramdiskId"]
end ec2.instance.setRamdisk

on ec2.instance.setKeypair pkeyPair
   put pkeyPair into sRunInstance["KeyName"]
end ec2.instance.setKeypair

on ec2.instance.setAvailabilityZone pZone
   if pZone is not empty then put pZone into \
         sRunInstance["Placement.AvailabilityZone"]
end ec2.instance.setAvailabilityZone

on ec2.instance.setMinMax pMin, pMax
   if pMin is an integer then put pMin into sRunInstance["MinCount"]
   if pMax is not an integer or pMax < pMin then
      put sRunInstance["MinCount"] into sRunInstance["MaxCount"]
   else
      put pMax into sRunInstance["MaxCount"]
   end if
end ec2.instance.setMinMax

on ec2.instance.setSecurityGroups pGroups
   if comma is in pGroups then replace comma with cr in pGroups
   repeat for each line L in pGroups
      add 1 to n
      put L into sRunInstance["SecurityGroup." & n]
   end repeat
end ec2.instance.setSecurityGroups

on ec2.instance.setInstanceType pType
   if pType is in "m1.small,m1.large,m1.xlarge,c1.medium,c1.xlarge" then
      put pType into sRunInstance["InstanceType"]
   end if
end ec2.instance.setInstanceType

on ec2.instance.setBlockDeviceMappings pBlockDeviceList
   set the itemdelimiter to "="
   repeat for each line L in pBlockDeviceList
      add 1 to n
      put item 1 of L into \
            sRunInstance["BlockDeviceMapping." & n & ".VirtualName"]
      put item 2 of L into \
            sRunInstance["BlockDeviceMapping." & n & ".DeviceName"]
   end repeat
end ec2.instance.setBlockDeviceMappings

-----

on ec2.instance.setUserData pUserData
   put base64encode(pUserData) into sRunInstance["UserData"]
end ec2.instance.setUserData

-----

function ec2.instance.run
   put ec2.send(sRunInstance) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   return xmlRunInstances(tResponse)
end ec2.instance.run

-----

function ec2.RunInstancesA pArray
   if pArray["ImageId"] is empty then return "error: no image id"
   if pArray["KeyName"] is empty then return "error: no keypair"
   get pArray["MinCount"]
   if it is not a number or it < 1 or it > 10 then put 1 into pArray["MinCount"]
   get pArray["MaxCount"]
   if it is not a number or it < pArray["MinCount"] or it > 10 then \
         put pArray["MinCount"] into pArray["MaxCount"]
   if pArray["SecurityGroup.1"] is empty then return "error: no security group"
   if pArray["InstanceType"] is not in \
         "m1.small,m1.large,m1.xlarge,c1.medium,c1.xlarge" then
      return "error: invalid instance type"
   end if
   
   put ec2.send(pArray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   return xmlRunInstances(tResponse)
   
end ec2.RunInstancesA

-----

function ec2.runInstances pImageId, pMinCount, pMaxCount, \
      pKeyPair, pType, pFormat
   
   if pKeyPair is empty then put sDefaultKeypair into pKeyPair
   if pMinCount is not an integer then put 1 into pMinCount
   if pMaxCount is not an integer then put 1 into pMaxCount
   
   put "RunInstances" into tQarray["Action"]
   put pAmi into tQarray["ImageId"]
   put pMinCount into tQarray["MinCount"]
   put pMaxCount into tQarray["MaxCount"]
   if pKeyPair is not empty then put pKeyPair into tQarray["KeyName"]
   
   if pType is in "m1.small,m1.large,m1.xlarge,c1.medium,c1.xlarge" then
      put pType into tQarray["InstanceType"]
   else
      put "m1.small" into tQarray["InstanceType"]
   end if
   
   put ec2.send(sRunInstance) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   return xmlRunInstances(tResponse)
   
end ec2.runInstances

-----

function ec2.rebootInstances pInstanceList, pFormat
   put "RebootInstances" into tQarray["Action"]
   
   repeat with n = 1 to the number of lines in pInstanceList
      put line n of pInstanceList into tQarray["InstanceId." & n]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.rebootInstances

-----

function ec2.terminateInstances pInstanceList, pFormat
   put "TerminateInstances" into tQarray["Action"]
   
   repeat with n = 1 to the number of lines in pInstanceList
      put line n of pInstanceList into tQarray["InstanceId." & n]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlTerminateInstances(tResponse) into tArray
   if pFormat is "list" then
      return the keys of tArray
   else
      return tArray
   end if
   
end ec2.terminateInstances

----------------------------
--> image actions
----------------------------

function ec2.describeImages pImages, pOwners, pExecutableBy, pFormat
   
   put "DescribeImages" into tQarray["Action"]
   
   put 0 into n
   repeat for each line L in pImages
      add 1 to n
      put L into tQarray["ImageId." & n]
   end repeat
   
   put 0 into n
   repeat for each line L in pOwners
      add 1 to n
      put L into tQarray["Owner." & n]
   end repeat
   
   put 0 into n
   repeat for each line L in pExecutableBy
      add 1 to n
      put L into tQarray["ExecutableBy." & n]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeImages(tResponse) into tArray
   
   if pFormat is "list" then
      put the keys of tArray into tempArray
      split tempArray by cr and comma
      return the keys of tempArray
   else
      return tArray
   end if
end ec2.describeImages

-----

function ec2.registerImage pS3Location
   put "RegisterImage" into tQarray["Action"]
   put pS3location into tQarray["ImageLocation"]
   
   put ec2.send(tQarray) into tResponse
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   return xmlSimpleResponse(tResponse, "imageId")
end ec2.registerImage

-----

function ec2.deregisterImage pImageId
   put "DeregisterImage" into tQarray["Action"]
   put pImageId into tQarray["ImageId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   return "<return>true" is in tResponse
end ec2.deregisterImage

-----

function ec2.describeImageAttribute pImageId, pAttribute, pFormat
   put "DescribeImageAttribute" into tQarray["Action"]
   put pImageId into tQarray["ImageId"]
   put pAttribute into tQarray["Attribute"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeImageAttribute(tResponse) into tArray
   return tArray
end ec2.describeImageAttribute

-----

function ec2.modifyImageAttribute pImageId
   return "error:  modifyImageAttribute not implemented"
end ec2.modifyImageAttribute

-----

function ec2.resetImageAttribute pImageId, pFormat
   put "ResetImageAttribute" into tQarray["Action"]
   put pImageId into tQarray["ImageId"]
   put "launchPermission" into tQarray["Attribute"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.resetImageAttribute

------------------------------
--> elasticIp actions
------------------------------

function ec2.describeAddresses pFormat
   put "DescribeAddresses" into tQarray["Action"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeAddresses(tResponse) into tArray
   if pFormat is "list" then combine tArray by cr and "="
   return tArray
end ec2.describeAddresses

-----

function ec2.allocateAddress pFormat
   put "AllocateAddress" into tQarray["Action"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return xmlSimpleResponse(tResponse, "publicIp")
end ec2.allocateAddress

-----

function ec2.releaseAddress pAddress, pFormat
   put "ReleaseAddress" into tQarray["Action"]
   put pAddress into tQarray["PublicIp"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.releaseAddress

-----

function ec2.associateAddress pInstance, pAddress, pFormat
   put "AssociateAddress" into tQarray["Action"]
   put pInstance into tQarray["InstanceId"]
   put pAddress into tQarray["PublicIp"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.associateAddress

-----

function ec2.disassociateAddress pAddress, pFormat
   put "DisassociateAddress" into tQarray["Action"]
   put pAddress into tQarray["PublicIp"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.disassociateAddress

----------------------------------------
--> securityGroup actions
----------------------------------------

function ec2.describeGroups pGrpNames, pFormat
   put "DescribeSecurityGroups" into tQarray["Action"]
   
   repeat for each line L in pGrpNames
      add 1 to n
      put L into tQarray["GroupName." & n]
   end repeat
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return linerize(tResponse)
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   put xmlDescribeSecurityGroups(tResponse) into tArray
   return tArray
end ec2.describeGroups

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

function ec2.authorizeGroup pGrpName, pFromPort, pToPort, \
         pProtocol, pCidrIp, pFormat
   
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

-----------------------------------
--> ebs volume actions
-----------------------------------

function ec2.describeVolumes pVolumeIds
   put "DescribeVolumes" into tQarray["Action"]
   if pVolumeIds is not empty then
      repeat for each line L in pVolumeIds
         add 1 to c
         put L into tQarray["VolumeId" & "." & c]
      end repeat
   end if
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   return tResponse
   put xmlDescribeVolumes(tResponse) into tArray
   return tArray
   
end ec2.describeVolumes

-----

function ec2.createVolume pSize, pZone, pSnapshot, pFormat
   put "CreateVolume" into tQarray["Action"]
   put pZone into tQarray["AvailabilityZone"]
   put pSize into tQarray["Size"]
   if pSnapshot is not empty then put pSnapshot into tQarray["SnapshotId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   put xmlCreateVolume(tResponse) into tArray
   return tArray
end ec2.createVolume

-----

function ec2.attachVolume pVolumeId, pInstanceId, pDevice
   put "AttachVolume" into tQarray["Action"]
   put pVolumeId into tQarray["VolumeId"]
   put pInstanceId  into tQarray["InstanceId"]
   if pDevice is empty then put "/dev/sdh" into pDevice
   put pDevice into tQarray["Device"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return tResponse
   put xmlAttchVolume(tResponse) into tArray
   return tArray
end ec2.attachVolume

-----

function ec2.detachVolume pVolumeId, pInstanceId, pDevice, pForce
   put "DetachVolume" into tQarray["Action"]
   put pVolumeId into tQarray["VolumeId"]
   put pInstanceId  into tQarray["InstanceId"]
   if pDevice is empty then put "/dev/sdh" into pDevice
   put pDevice into tQarray["Device"]
   if pForce then put true into tQarray["Force"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return tResponse
   put xmlDetachVolume(tResponse) into tArray
   return tArray
end ec2.detachVolume

-----

function ec2.deleteVolume pVolumeId
   put "DeleteVolume" into tQarray["Action"]
   put pVolumeId into tQarray["VolumeId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return tResponse
   put xmlDeleteVolume(tResponse) into tArray
   return tArray
end ec2.deleteVolume

-----------------------------------
--> snapshot actions
-----------------------------------

function ec2.describeSnapshots pSnapshotIds
   put "DescribeSnapshots" into tQarray["Action"]
   if pSnapshotIds is not empty then
      replace comma with cr in pSnapshots
      repeat for each line L in pSnapshotIds
         add 1 to c
         put L into tQarray["SnapshotId" & "." & c]
      end repeat
   end if
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then return "error:" && xmlError(tResponse)
   put xmlDescribeSnapshots(tResponse) into tArray
   return tArray
end ec2.describeSnapshots

-----

function ec2.createSnapshot pVolumeId
   put "CreateSnapshot" into tQarray["Action"]
   put pVolumeId into tQarray["VolumeId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   put xmlCreateSnapshot(tResponse) into tArray
   return tArray
end ec2.createSnapshot

-----

function ec2.deleteSnapshot pSnapshotId
   put "DeleteSnapshot" into tQarray["Action"]
   put pSnapshotId into tQarray["SnapshotId"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   put xmlDeleteSnapshot(tResponse) into tArray
   return tArray
end ec2.deleteSnapshot

------------------------------
--> keypair actions
------------------------------

function ec2.createKeypair pName, pFormat
   put "CreateKeyPair" into tQarray["Action"]
   put pName into tQarray["KeyName"]
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlAllChildren(tResponse, "Code")
   
   put xmlCreateKeyPair(tResponse) into tArray
   return tArray
end ec2.createKeypair

-----

function ec2.deleteKeypair pName, pFormat
   put "DeleteKeyPair" into tQarray["Action"]
   put pName into tQarray["KeyName"]
   
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   return "<return>true" is in tResponse
end ec2.deleteKeypair

-----

function ec2.describeKeypairs pFormat
   put "DescribeKeyPairs" into tQarray["Action"]
   put ec2.send(tQarray) into tResponse
   
   if "curl" is in word 1 of tResponse then return "error:" && tResponse
   if pFormat is "xml" then return tResponse
   if "<errors>" is in tResponse then \
         return "error:" && xmlError(tResponse, "Code")
   
   put xmlDescribeKeyPairs(tResponse) into tArray
   if pFormat is "list" then return the keys of tArray
   return tArray
end ec2.describeKeypairs

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

-=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
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


-=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=---
-------------------------
--> internals
-------------------------

private function ec2.send pQarray
   put ec2.makePostData(pQarray) into tPostData
   return curl.post("https://" & ec2.getEndPoint(), tPostData)
end ec2.send

-----

private function ec2.makePostData pQarray
   put getAwsAccessKey() into pQarray["AWSAccessKeyId"]
   put zDate() into pQarray["Timestamp"]
   put kApiVersion into pQarray["Version"]
   put "2" into pQarray["SignatureVersion"]
   put "HmacSHA256" into pQarray["SignatureMethod"]
   
   put ec2.type2Auth(pQarray) into pQarray["Signature"]
   
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then \
            put L & "=" & urlencode(pQarray[L]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
   
   return tQueryString
end ec2.makePostData

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
         put L & "=" & urlencode(pQarray[L]) & "&" after tQueryString
   end repeat
   delete char -1 of tQueryString
end cw.makePostData


-----

private function ec2.type0Auth pQarray
   put pQarray["Action"] & pQarray["Timestamp"] into tStringToSign
   return hmacSha1.b64(tStringToSign, getAwsSecretkey())
end ec2.type0Auth

-----

private function ec2.type1Auth pQarray
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      if pQarray[L] is not empty then put L & pQarray[L] after tStringToSign
   end repeat
   
   put hmacSha1.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end ec2.type1Auth

-----

private function ec2.type2Auth pQarray
   put "POST" & cr & ec2.getEndPoint() & cr & "/" & cr into tStringToSign
   
   set the casesensitive to true
   put the keys of pQarray into tKeys
   sort lines of tKeys
   repeat for each line L in tKeys
      put pcEncode(L) & "=" & pcEncode(pQarray[L]) & "&" after tStringToSign
   end repeat
   delete char -1 of tStringToSign
   
   put hmacSha256.b64(tStringToSign, getAwsSecretkey()) into tAuthstring
   return tAuthstring
end ec2.type2Auth

--=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=--
--=----=----=----=----=----=----=----=----=----=----=----=----=----=----=----=--
------------------------------
--> xml responses
------------------------------




private function xmlDescribeInstances pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "/DescribeInstancesResponse/reservationSet" into tRootNode
   
   put revXmlFirstChild(tTree, tRootNode) into tReservationNode
   
   repeat until tReservationNode is empty or "xmlerr" is in tReservationNode
      put reservationInfoType(tTree, tReservationNode) into tReservationInfo
      
      put revXmlFirstChild(tTree, tReservationNode & "/instancesSet") into tNode
      repeat while tNode is not empty
         put revXmlNodeContents(tTree, tNode & "/instanceId") into tKey
         put runningInstanceType(tTree, tNode) into tInstance
         put tReservationInfo after tInstance
         
         filter tInstance without empty
         put tInstance into tArray[tKey]
         put revXmlNextSibling(tTree, tNode) into tNode
      end repeat
      put revXmlNextSibling(tTree, tReservationNode) into tReservationNode
   end repeat
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeInstances

-----

private function xmlRunInstances pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "/RunInstancesResponse" into tRootNode
   
   put reservationInfoType(tTree, tRootNode, "array") into tArray
   
   put revXmlFirstChild(tTree, tRootNode & "/instancesSet") into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(tTree, tNode & "/instanceId") into tKey
      put runningInstanceType(tTree, tNode) into tInstance
      
      filter tInstance without empty
      put tInstance into tArray[tKey] 
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlRunInstances

-----

private function xmlTerminateInstances pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "/TerminateInstancesResponse" into tRootNode
   
   put revXmlFirstChild(tTree, tRootNode & "/instancesSet") into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(tTree, tNode & "/instanceId") into tKey
      put terminateInstanceType(tTree, tNode) into tInstance
      
      filter tInstance without empty
      put tInstance into tArray[tKey] 
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlTerminateInstances

-----

private function runningInstanceType tTree, tNode, pFormat
   put empty into tInstance
   addToList tInstance, "instanceId", \
         revXmlNodeContents(tTree, tNode & "/instanceId")
   addToList tInstance, "imageId", \
         revXmlNodeContents(tTree, tNode & "/imageId")
   addToList tInstance, "state", \
         instanceStateType(tTree, tNode & "/instanceState", "csv")
   addToList tInstance, "privateDns", \
         revXmlNodeContents(tTree, tNode & "/privateDnsName")
   addToList tInstance, "publicDns", \
         revXmlNodeContents(tTree, tNode & "/dnsName")
   addToList tInstance, "keypair", \
         revXmlNodeContents(tTree, tNode & "/keyName")
   addToList tInstance, "type", \
         revXmlNodeContents(tTree, tNode & "/instanceType")
   addToList tInstance, "launchtime", \
         revXmlNodeContents(tTree, tNode & "/launchTime")
   addToList tInstance, "reason", \
         revXmlNodeContents(tTree, tNode & "/reason")
   addToList tInstance, "availabilityzone", \
         revXmlNodeContents(tTree, tNode & "/placement/availabilityZone")
   addToList tInstance, "launchIndex", \
         revXmlNodeContents(tTree, tNode & "/amiLaunchIndex")
   addToList tInstance, "kernelId", \
         revXmlNodeContents(tTree, tNode & "/kernelId")
   addToList tInstance, "ramdiskId", \
         revXmlNodeContents(tTree, tNode & "/ramdiskId") 
   
   put revXmlFirstChild(tTree, tNode & "/productCodesSet") into tPCnode
   repeat while tPCnode is not empty and "xmlerr" is not in tPCnode
      get revXmlNodeContents(tTree, tPCnode & "/productCode")
      if it is not empty then put it & comma after pcList
      put revXmlNextSibling(tTree, tPCNode) into tPCNode
   end repeat
   addToList tInstance, "productcodes", char 1 to -2 of pcList
   
   if pFormat is "array" then split tInstance by cr and "="
   return tInstance
end runningInstanceType

-----

private function terminateInstanceType tTree, tNode, pFormat
   put empty into tInstance
   addToList tInstance, "instanceId", \
         revXmlNodeContents(tTree, tNode & "/instanceId")
   addToList tInstance, "shutDownState", \
         instanceStateType(tTree, tNode & "/shutdownState", "csv")
   addToList tInstance, "previousState", \
         instanceStateType(tTree, tNode & "/previousState", "csv")
   
   if pFormat is "array" then split tInstance by cr and "="
   return tInstance
end terminateInstanceType

-----

private function instanceStateType pTree, pNode, pFormat
   put empty into tList
   addToList tList, "code", revXmlNodeContents(pTree, pNode & "/code")
   addToList tList, "name", revXmlNodeContents(pTree, pNode & "/name")
   delete char -1 of tList
   
   if pFormat is "array" then split tList by cr and "="
   if pFormat is "csv" then
      replace "code=" with empty in tList
      replace "name=" with empty in tList
      replace cr with comma in tList
   end if
   return tList
end instanceStateType

-----

private function reservationInfoType pTree, pNode, pFormat
   
   
   addToList tReservationInfo, "reservationId", \
         revXmlNodeContents(pTree, pNode & "/reservationId")
   addToList tReservationInfo, "ownerId", \
         revXmlNodeContents(pTree, pNode & "/ownerId")
   addToList tReservationInfo, "securitygroups", \
         groupSetType(pTree, pNode & "/groupSet")
   
   if pFormat is "array" then split tReservationInfo by cr and "="
   return tReservationInfo
end reservationInfoType

-----

private function groupSetType pTree, pParentNode
   put revXmlFirstChild(pTree, pParentNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode & "/groupId") & comma after tGroupList
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return char 1 to -2 of tGroupList
end groupSetType

-----

private function BlockDeviceMappingItemType pTree, pNode, pFormat
   put empty into tItem
   addToList tItem, "virtualName", \
         revXmlNodeContents(pTree, pNode & "/virtualName")
   addToList tItem, "deviceName", \
         revXmlNodeContents(pTree, pNode & "/deviceName")
   
   if pFormat is "array" then split tItem by cr and "="
   return tItem
end BlockDeviceMappingItemType

-----

private function productCodesSet pTree, pParentNode
   put revXmlFirstChild(pTree, pParentNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode & "/productCode") & comma after tPClist
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return char 1 to -2 of tPClist
end productCodesSet

-----

private function xmlDescribeImages pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put revXmlFirstChild(tTree, "/DescribeImagesResponse/imagesSet/") into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      
      put DescribeImagesResponseItemType(tTree, tNode, array) into tItem
      put tItem["imageId"] into tKey
      combine tItem by cr and "="
      put tItem into tArray[tKey]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeImages

-----

private function xmlDescribeImageAttribute pXml
   return linerize(pXml)
end xmlDescribeImageAttribute

-----

private function DescribeImagesResponseItemType pTree, pNode, pFormat
   put empty into tItem
   addToList tItem, "imageId", \
         revXmlNodeContents(pTree, pNode & "/imageId")
   addToList tItem, "imageState", \
         revXmlNodeContents(pTree, pNode & "/imageState")
   addToList tItem, "imageOwnerId", \
         revXmlNodeContents(pTree, pNode & "/imageOwnerId")
   addToList tItem, "imageLocation",\
         revXmlNodeContents(pTree, pNode & "/imageLocation")
   
   addToList tItem, "isPublic", \
         revXmlNodeContents(pTree, pNode & "/isPublic")
   addToList tItem, "architecture", \
         revXmlNodeContents(pTree, pNode & "/architecture")
   addToList tItem, "imageType", \
         revXmlNodeContents(pTree, pNode & "/imageType")
   addToList tItem, "kernelId", \
         revXmlNodeContents(pTree, pNode & "/kernelId")
   addToList tItem, "ramdiskId", \
         revXmlNodeContents(pTree, pNode & "/ramdiskId")
   addToList tItem, "productCodes", \
         productCodesSet(pTree, pNode & "/productCodesSet")
   if pFormat is "array" then split tItem by cr and "="
   return tItem
end DescribeImagesResponseItemType

-----

private function xmlCreateKeyPair pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put revXmlNodeContents(tTree, "CreateKeyPairResponse/keyName") into \
         tArray["name"]
   put revXmlNodeContents(tTree, "CreateKeyPairResponse/keyFingerprint") into \
         tArray["fingerprint"]
   put revXmlNodeContents(tTree, "CreateKeyPairResponse/keyMaterial") into \
         tArray["material"]
   
   revDeleteXmlTree tTree
   return tArray
end xmlCreateKeyPair

-----

private function xmlDescribeKeyPairs pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "/DescribeKeyPairsResponse/keySet" into tParent
   put revXmlFirstChild(tTree, tParent) into tNode
   
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put describeKeyPairsResponseItem(tTree, tNode, "array") into tempArray
      put tempArray["keyFingerprint"] into tArray[tempArray["keyName"]]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeKeyPairs

-----

private function describeKeyPairsResponseItem pTree, pNode, pFormat
   put empty into tList
   addToList tList, "keyName", \
         revXmlNodeContents(pTree, pNode & "/keyName")
   addToList tList, "keyFingerprint", \
         revXmlNodeContents(pTree, pNode & "/keyFingerprint")
   
   if pFormat is "array" then split tList by cr and "="
   return tList
end describeKeyPairsResponseItem

-----

private function xmlCreateVolume pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put xmlVolumeSetType(tTree, "CreateVolumeResponse") into tArray
   
   revDeleteXmlTree tTree
   return tArray
end xmlCreateVolume

-----

private function xmlDescribeVolumes pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "DescribeVolumesResponse/volumeSet" into tStartNode
   put revXmlFirstChild(tTree, tStartNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      
      put revXmlNodeContents(tTree, tNode & "/volumeId") into tVol
      put xmlVolumeSetType(tTree, tNode) into tArray[tVol]
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeVolumes

-----

private function xmlVolumeSetType pTree, pNode
   put xmlAllNodeContents(pTree, pNode) into tArray
   get xmlAllNodeContents(pTree, pNode & "/attachmentSet/item")
   if it is an array then put it into tArray["attachment"]
   return tArray
end xmlVolumeSetType

-----

private function xmlAttachVolume pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "AttachVolumeResponse" into tNode
   put xmlAllNodeContents(tTree, tNode) into tArray
   revDeleteXmlTree tTree
   return tArray
end xmlAttachVolume

-----

private function xmlDetachVolume pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "DetachVolumeResponse" into tNode
   put xmlAllNodeContents(tTree, tNode) into tArray
   revDeleteXmlTree tTree
   return tArray
end xmlDetachVolume

-----

private function xmlDeleteVolume pXml
   return xmlSimpleReturn(pXml)
end xmlDeleteVolume

-----

private function xmlCreateSnapshot pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put xmlAllNodeContents(tTree, "createSnapshotResponse") into tArray
   revDeleteXmlTree tTree
   return tArray
end xmlCreateSnapshot

-----

private function xmlDeleteSnapshot pXml
   return xmlSimpleReturn(pXml)
end xmlDeleteSnapshot

-----

private function xmlDescribeSnapshots pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put revXmlFirstChild(tTree, "DescribeSnapshotsResponse") into tNode
   if "item" is in tNode then
      repeat until tNode is empty or "xmlerr" is in tNode
         put revXmlNodeContents(tTree, tNode & "/snapshotId") into tSnap
         put xmlAllNodeContents(tTree, tNode) into tArray[tSnap]
         put revXmlNextSibling(tTree, tNode) into tNode
      end repeat
   else
      put revXmlNodeContents(tTree, "DescribeSnapshotsResponse/snapshotId") \
            into tSnap
      put xmlAllNodeContents(tTree, "DescribeSnapshotsResponse") \
            into tArray[tSnap]
   end if
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeSnapshots

-----

private function xmlDescribeAddresses pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "/DescribeAddressesResponse/addressesSet" into tParent
   put revXmlFirstChild(tTree, tParent) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(tTree, tNode & "/publicIp") into tAddress
      put revXmlNodeContents(tTree, tNode & "/instanceId") into tArray[tAddress]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeAddresses

-----

private function xmlDescribeSecurityGroups pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "/DescribeSecurityGroupsResponse/securityGroupInfo" into tParent
   put revXmlFirstChild(tTree, tParent) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put SecurityGroupItemType(tTree, tNode, "array") into tempArray
      put tempArray["groupName"] into tKey
      combine tempArray by cr and "="
      put tempArray into tArray[tKey]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   revDeleteXmlTree tTree
   
   return tArray
end xmlDescribeSecurityGroups

function xmlDescSGs pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "/DescribeSecurityGroupsResponse/securityGroupInfo" into tParent
   put revXmlFirstChild(tTree, tParent) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(tTree, tNode & "/groupName") into tName
      put xmlAllNodeContents(tTree, tNode) into tArray[tName]
      
      
      
      -- put SecurityGroupItemType(tTree, tNode, "array") into tempArray
      -- put tempArray["groupName"] into tKey
      -- combine tempArray by cr and "="
      -- put tempArray into tArray[tKey]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   revDeleteXmlTree tTree
   
   return tArray
end xmlDescSGs

-----

private function SecurityGroupItemType pTree, pNode, pFormat
   put empty into tList
   addToList tList, "ownerId", \
         revXmlNodeContents(pTree, pNode & "/ownerId")
   addToList tList, "groupName", \
         revXmlNodeContents(pTree, pNode & "/groupName")
   addToList tList, "groupDescription", \
         revXmlNodeContents(pTree, pNode & "/groupDescription")
   -- addToList tList, "ipPermissions", ipPermissionType(pTree, pNode & "/ipPermissions", "csv")
   get ipPermissionType(pTree, pNode & "/ipPermissions") 
   put it after tList
   
   if pFormat is "array" then split tList by cr and "="
   return tList
end SecurityGroupItemType

-----

private function ipPermissionType pTree, pNode
   put empty into tPermission
   
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      add 1 to c
      put "ipPermissions." & c & "=" after tPermission
      put revXmlNodeContents(pTree, tNode & "/ipProtocol") & comma \
            after tPermission
      put revXmlNodeContents(pTree, tNode & "/fromPort") & comma \
            after tPermission
      put revXmlNodeContents(pTree, tNode & "/toPort") & comma \
            after tPermission
      get securityGroupPairType(pTree, tNode & "/groups")
      if it is not empty then
         put it after tPermission
      else
         put ipRangesType(pTree, tNode & "/ipRanges") after tPermission
      end if
      put cr after tPermission
      
      -- addToList tList, "ipProtocol", revXmlNodeContents(pTree, tNode & "/ipProtocol")
      -- addToList tList, "fromPort", revXmlNodeContents(pTree, tNode & "/fromPort")
      -- addToList tList, "toPort", revXmlNodeContents(pTree, tNode & "/toPort")
      -- addToList tList, "ipRanges", ipRangesType(pTree, tNode & "/ipRanges")
      -- addToList tList, "groups", securityGroupPairType(pTree, tNode & "/groups")
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return char 1 to - 2 of tPermission
end ipPermissionType

-----

private function ipRangesType pTree, pNode
   put empty into tList
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode & "/cidrIp") & "|" after tList
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   delete char -1 of tList
   return tList
end ipRangesType

-----

private function securityGroupPairType pTree, pNode
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(pTree, tNode & "/userId") & ":"  after tList
      put revXmlNodeContents(pTree, tNode & "/groupName") & "|" after tList
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   delete char -1 of tList
   return tList
end securityGroupPairType

-----

private function xmlDescribeRegions pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "/DescribeRegionsResponse/regionInfo" into tParent
   
   put revXmlFirstChild(tTree, tParent) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put revXmlNodeContents(tTree, tNode & "/regionName") into tName
      put revXmlNodeContents(tTree, tNode & "/regionEndpoint") into tArray[tName]
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeRegions

-- private function regionItemType pTree, pNode
-- put empty into tItem
-- put revXmlNodeContents(pTree, pNode & "/regionName") into tArray["regionName"]
-- put revXmlNodeContents(pTree, pNode & "/regionUrl") into tArray["regionUrl"]
-- 
-- return tArray
-- end regionItemType

-----

private function xmlDescribeAvailabilityZones pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put "/DescribeAvailabilityZonesResponse/availabilityZoneInfo" into tParent
   
   put revXmlFirstChild(tTree, tParent) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      put AvailabilityZoneItemType(tTree, tNode, "array") into tempArray
      put tempArray["zoneState"] into tArray[tempArray["zoneName"]]
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   return tArray
end xmlDescribeAvailabilityZones

-----

private function AvailabilityZoneItemType pTree, pNode, pFormat
   put empty into tItem
   addToList tItem, "zoneName", revXmlNodeContents(pTree, pNode & "/zoneName")
   addToList tItem, "zoneState", revXmlNodeContents(pTree, pNode & "/zoneState")
   
   if pFormat is "array" then split tItem by cr and "="
   return tItem
end AvailabilityZoneItemType

-----

private function xmlGetConsoleOutput pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   
   put "/GetConsoleOutputResponse" into tNode
   
   put revXmlNodeContents(tTree, tNode & "/InstanceId") \
         into tArray["instanceid"]
   put revXmlNodeContents(tTree, tNode & "/timestamp") \
         into tArray["timestamp"]
   put base64decode(revXmlNodeContents(tTree, tNode & "/output")) \
         into tArray["output"]
   
   revDeleteXmlTree tTree
   return tArray
end xmlGetConsoleOutput

-----

private function xmlError pXml
   return xmlSimpleResponse(pXml, "Code") & " : " & \
         xmlSimpleResponse(pXml, "Message")
end xmlError


-----

private function xmlAllChildren pXml, pName
   replace "><" with "<" & cr & "<" in pXml
   set the itemdelimiter to "<"
   replace ">" with "<" in pXml
   repeat for each line L in pXml
      if "<" & pName is in l then put item 3 of L & cr after tList
   end repeat
   delete char -1 of tList
   return xmlEntities(tList)
end xmlAllChildren

-----

private function xmlSimpleResponse pXML, pElementName
   put offset("<" & pElementName & ">", pXml) + length(pElementName) + 2 \
         into startChar
   put offset("</" & pElementName, pXml) - 1 into endChar
   return xmlEntities(char startChar to endChar of pXml)
end xmlSimpleResponse

private function xmlSimpleReturn pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put revXmlRootNode(tTree) & "/return" into tNode
   put revXmlNodeContents(tTree, tNode) into tReturn
   revDeleteXmlTree tTree
   return tReturn
end xmlSimpleReturn

-----

private function xmlAllNodeContents pTree, pNode
   set the itemdelimiter to "/"
   put revXmlFirstChild(pTree, pNode) into tNode
   repeat until tNode is empty or "xmlerr" is in tNode
      --if revXmlNumberOfChildren(pTree, tNode, ,0) = 0 then
      get revXmlNodeContents(pTree, tNode)
      if it is not empty then put it into tArray[item -1 of tNode]
      --end if
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end xmlAllNodeContents

-----

private function xmlEntities pXmlContent
   replace "&quot;" with quote in pXmlContent
   replace "&apos;" with "'" in pXmlContent
   replace "&lt;" with "<" in pXmlContent
   replace "&gt;" with ">" in pXmlContent
   replace "&amp;" with "&" in pXmlContent
   return pXmlContent
end xmlEntities

-----

private command addToList @pList, pLabel, pData
   if pData is not empty and "xmlerr" is not in pData then \
         put pLabel & "=" & pData & cr after pList
end addToList

-----

function xmlListMetrics pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put responseMetadata(tTree) into tArray["responsemetadata"]
   put "ListMetricsResponse/ListMetricsResult" into tStartNode
   put revXmlFirstChild(tTree, tStartNode) into tNode
   repeat while tNode is not empty and "xmlerr" is not in tNode
      
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
end xmlListMetrics

-----

function xmlGetMetricStatistics pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put responseMetadata(tTree) into tArray["responsemetadata"]
   put "GetMetricStatisticsResponse/GetMetricStatisticsResult/Label" \
         into tLabelNode
   put revXmlNodeContents(tTree, tLabelNode) into tLabel
   put "GetMetricStatisticsResponse/GetMetricStatisticsResult/DataPoints" \
         into tStartNode
   
   put revXmlFirstChild(tTree, tStartNode) into tNode
   repeat while (tNode is not empty) and ("xmlerr" is not in tNode)
      put nodeCont(tTree, tNode & "/TimeStamp") into tTime
      put nodeCont(tTree, tNode & "/Unit") into tArray[tTime]["unit"]
      put nodeCont(tTree, tNode & "/Samples") into tArray[tTime]["samples"]
      put nodeCont(tTree, tNode & "/Average") into tArray[tTime]["average"]
      
      put revXmlNextSibling(tTree, tNode) into tNode
   end repeat
   
   revDeleteXmlTree tTree
   
   return tArray
end xmlGetMetricStatistics

private function nodeCont pTree, pNode
   return revXmlNodeContents(pTree, pNode)
end nodeCont

-----

private function responseMetadata pTree
   put revXmlRootNode(pTree) into tNode
   put revXmlNodeContents(pTree, tNode & "/ResponseMetadata/RequestId") \
         into tMetadata
   return tMetadata
end responseMetadata

-----

private function xmlMonitorInstances pXml
   put revCreateXmlTree(pXml, true, true, false) into tTree
   put revXmlRootNode(tTree) & "/InstancesSet" into tNode
   put xmlMonitorInstancesSet(tTree, tNode) into tArray
   revDeleteXmlTree tTree
   return tArray
end xmlMonitorInstances

-----

private function xmlMonitorInstancesSet pTree, pNode
   put revXmlFirstChild(pTree, pNode) into tNode
   
   repeat while (tNode is not empty) and ("xmlerr" is not in tNode)
      put revXmlNodeContents(pTree, tNode & "/InstanceId") into tID
      put revXmlNodeContents(pTree, tNode & "/monitoring/state") \
            into tArray[tID]["monitoring"]
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
   return tArray
end xmlMonitorInstancesSet

-----

--> new xml

function ec2xml.response pXml
   get offset("<?xml", pXml)
   if it = 0 then return empty
   if it > 1 then delete char 1 to it -1 of pXml
   put revCreateXMLTree(pXML,true,true,false) into tTree
   put revXmlRootNode(tTree) into tRoot
   put "xml" & tRoot into tAction
   
   do ("put" && tAction & "(" & tTree & comma & tRoot & ") into tArray")
   
   if tArray["status"] is not "error" then put "ok" into tArray["status"]
   
   revDeleteXmlTree tTree
   return tArray
end ec2xml.response

-----

private function xmlDescribeAddressesResponse pTree, pRoot
   put pRoot & "/addressesSet" into tSetNode
   put revXmlFirstChild(pTree, tSetNode) into tNode
   
   repeat until (tNode is empty) or (tNode contains "xmlerr")
      put revXmlNodeContents(pTree, tNode & "/publicIp") into tAddress
      put revXmlNodeContents(pTree, tNode & "/instanceId") into tInstance
      if "xmlerr" is in tInstance then put empty into tInstance
      put tInstance into tArray["ipaddress"]
      
      put revXmlNextSibling(pTree, tNode) into tNode
   end repeat
end xmlDescribeAddressesResponse

-----

private function xmlAllocateAddressResponse pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/publicIp") into tArray["ipaddress"]
   put revXmlNodeContents(pTree, pRoot & "/requestId") into tArray["requestid"]
   
   return tArray
end xmlAllocateAddressResponse

-----

private function xmlAssociateAddressResponse pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/publicIp") into tArray["ipaddress"]
   put revXmlNodeContents(pTree, pRoot & "/requestId") into tArray["requestid"]
   put revXmlNodeContents(pTree, pRoot & "/return") into tArray["success"]
   
   return tArray
end xmlAssociateAddressResponse

-----

private function xmlDisassociateAddressResponse pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/requestId") into tArray["requestid"]
   put revXmlNodeContents(pTree, pRoot & "/return") into tArray["success"]
   
   return tArray
end xmlDisassociateAddressResponse

------

private function xmlReleaseAddressResponse pTree, pRoot
   put revXmlNodeContents(pTree, pRoot & "/requestId") into tArray["requestid"]
   put revXmlNodeContents(pTree, pRoot & "/return") into tArray["success"]
   
   return tArray
end xmlReleaseAddressResponse

---===---===---===---===---===---===---===---===---===---===---===---===---===---
---===---===---===---===---===---===---===---===---===---===---===---===---===---
