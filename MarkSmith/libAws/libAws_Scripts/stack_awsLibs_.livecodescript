Script "stack_awsLibs_"

/*
# Name: stack "awsLibs"
# ID: stack "awsLibs"
*/


--> all handlers

on libraryStack
   if the target is me then
      insert the script of btn "bin-crypt" of me into back
      insert the script of btn "common" of me into back
      insert the script of btn "curl" of me into back
      insert the script of btn "s3" of me into back
      insert the script of btn "ec2" of me into back
      insert the script of btn "sdb" of me into back
      insert the script of btn "sqs" of me into back
      insert the script of btn "rds" of me into back
      insert the script of btn "json" of me into back
   else
      pass libraryStack
   end if
end libraryStack
