Script "stack_s3SampleApp_button_id_1049"

/*
# Name: button "deleteFile" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1049 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   put value(the selectedline of fld "objectList") into tKey
   put value(the selectedline of fld "bucketList") into tBucket
   
   answer "Really delete" && tBucket & "/" & tKey & "?" with "Cancel" and "Yes"
   if it is "Yes" then
       
      s3.deleteObject tBucket, tKey
      put s3.listBucket(tBucket) into fld "objectList"
      
   end if
   
    
end mouseUp
