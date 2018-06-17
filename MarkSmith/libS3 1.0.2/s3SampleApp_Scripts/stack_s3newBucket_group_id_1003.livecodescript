Script "stack_s3newBucket_group_id_1003"

/*
# Name: group "newBucket" of card id 1002 of stack "s3newBucket" of stack "s3SampleApp"
# ID: group id 1003 of card id 1002 of stack "s3newBucket" of stack "s3SampleApp"
*/


--> all handlers


on createBucket
   put fld "bucketName" of me into tBucket
   if char 1 of tBucket is not "/" then put "/" before tBucket
   put the label of btn "ACL" into tAcl
   s3.createBucket tBucket, tAcl
   if the result is not empty then
      put the result
   else
       put s3.listAllMyBuckets() into fld "bucketList" of stack "s3SampleApp"
   end if
   dismiss
end createBucket

on dismiss
   lock screen
   put empty into fld "bucketName" of me
   set the menuhistory of btn "ACL" to 1
   close this stack
end dismiss
