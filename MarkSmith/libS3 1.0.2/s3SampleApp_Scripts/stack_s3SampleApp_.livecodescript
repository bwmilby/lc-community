Script "stack_s3SampleApp_"

/*
# Name: stack "s3SampleApp"
# ID: stack "s3SampleApp"
*/


--> all handlers



on login
   if  fld "AccessKey" of me is empty or fld "SecretKey" of me is empty then exit login
   s3.setKeys fld "AccessKey" of me , fld "SecretKey" of me
   put s3.listAllMyBuckets() into fld "bucketList" of me
end login
