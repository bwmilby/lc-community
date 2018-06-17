Script "stack_s3SampleApp_button_id_1052"

/*
# Name: button "NewBucket" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1052 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
  set the loc of stack "s3NewBucket" to the loc of this stack
  palette stack "s3NewBucket"
   
end mouseUp
