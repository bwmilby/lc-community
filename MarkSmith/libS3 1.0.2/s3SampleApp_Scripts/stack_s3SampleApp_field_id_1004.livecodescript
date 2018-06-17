Script "stack_s3SampleApp_field_id_1004"

/*
# Name: field "bucketList" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: field id 1004 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on selectionChanged
   put line (the hilitedline of me) of me  into tBucket
   put s3.listBucket(tBucket) into tData
   put tData into fld "objectList"
   
   -- replace cr with "<p>" in tData
   -- set the htmltext of fld "objectList" to tData
    
end selectionChanged
