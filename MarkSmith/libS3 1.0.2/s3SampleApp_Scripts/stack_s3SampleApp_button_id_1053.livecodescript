Script "stack_s3SampleApp_button_id_1053"

/*
# Name: button "DeleteBucket" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1053 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   put value(the selectedline of fld "bucketList") into tBucket
   if the optionkey is not down then
      answer "Really delete bucket" && tBucket & "?" with "Cancel" and "Yes"
      if it is "Yes" then
         s3.deleteBucket tBucket
         if the result is not empty then put the result
         put s3.listAllMyBuckets() into fld "bucketList"
         put empty into fld "objectList"
      end if
   else
      answer "Really delete bucket" && tBucket && "and all it's contents?" with "Cancel" and "Yes"
      if it is "Yes" then
         s3.deleteBucketAndContents tBucket
         if the result is not empty then put the result
         put s3.listAllMyBuckets() into fld "bucketList"
         put empty into fld "objectList"
      end if
   end if
end mouseUp
