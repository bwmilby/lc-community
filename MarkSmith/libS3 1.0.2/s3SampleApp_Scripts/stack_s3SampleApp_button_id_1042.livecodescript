Script "stack_s3SampleApp_button_id_1042"

/*
# Name: button "downloadFile" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1042 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   answer folder "Download to:"
   if it is empty then exit to top
   put it into tDestFile
   put value(the selectedline of fld "bucketList") into tBucket
   put value(the selectedline of fld "objectList") into tKey
   set the itemdelimiter to "/"
   put "/" & item -1 of tKey after tDestFile
   
    
   s3.setStatusCallback "tmUpdateGauge", the long id of grp "p1"
   
   send "tmUpdateGauge 0,0,0" to grp "p1"
   show grp "p1"
   s3.downloadFile tBucket, tKey, tDestFile
   if the result is not empty then put the result
   hide grp "p1"
end mouseUp

