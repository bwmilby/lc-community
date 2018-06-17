Script "stack_s3SampleApp_field_id_1006"

/*
# Name: field "objectList" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: field id 1006 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   put line (the hilitedline of me) of me into tKey
   put line (the hilitedline of fld "bucketList") of fld "bucketList" into tBucket
   put s3.listObjectArray(tBucket, tKey) into tob
   
   put "bucket:" & tab & tBucket & cr into tList
   put "key:" & tab & tKey & cr after tList
   
   convert tob["modified"] from seconds to internet date
   repeat for each item i in "modified,md5,size,type"
   put i & ":" & tab & tob[i] & cr after tList
   end repeat
   delete char -1 of tList
   
  
   put tList into fld "info" of stack "objectInfo"
   popup stack "objectInfo"
end mouseUp
