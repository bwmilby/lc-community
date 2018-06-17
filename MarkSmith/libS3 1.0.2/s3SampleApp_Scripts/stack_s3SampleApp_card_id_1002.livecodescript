Script "stack_s3SampleApp_card_id_1002"

/*
# Name: card id 1002 of stack "s3SampleApp"
# ID: card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on openStack
   if the target is me then
      start using stack "libS3"
      login
   end if
   pass openStack
end openStack
