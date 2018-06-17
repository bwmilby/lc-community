Script "stack_awsLibs_button_id_1011"

/*
# Name: button "stop using" of card id 1002 of stack "awsLibs"
# ID: button id 1011 of card id 1002 of stack "awsLibs"
*/


--> all handlers

on mouseUp
   remove script of btn "s3" from back
   remove script of btn "ec2" from back
   remove script of btn "sdb" from back
   remove script of btn "sqs" from back
   remove script of btn "bin-crypt" from back
   remove script of btn "curl" from back
   remove script of btn "common" from back
end mouseUp
