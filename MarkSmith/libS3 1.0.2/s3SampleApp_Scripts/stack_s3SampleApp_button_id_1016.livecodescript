Script "stack_s3SampleApp_button_id_1016"

/*
# Name: button "uploadFile" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1016 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   answer file "Choose a file..."
   if it is empty then exit to top
   put it into tFile
    
   set the itemdelimiter to "/"
   put item -1 of tFile into tObject
    
   ask "name for object?" with tObject
   if it is empty then exit to top
   put it into tObject
    
   put line (the hilitedline of fld "bucketList") of fld "bucketList"  into tBucket
    
   s3.setStatusCallback "tmUpdateGauge", the long id of grp "p1"
   send "tmUpdateGauge 0,0,0" to grp "p1"
   show grp "p1"
   s3.uploadFile tBucket, tObject, tFile, "public-read"
   hide grp "p1"
   if the result is not empty then
      put the result
   else
      put s3.listBucket(tBucket) into fld "objectList"
   end if
   
end mouseUp

