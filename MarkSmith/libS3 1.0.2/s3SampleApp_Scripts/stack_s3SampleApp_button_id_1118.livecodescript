Script "stack_s3SampleApp_button_id_1118"

/*
# Name: button "check libS3 version" of group "login" of card id 1002 of stack "s3SampleApp"
# ID: button id 1118 of group id 1061 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   put s3.checkLatestVersion()
    
end mouseUp
