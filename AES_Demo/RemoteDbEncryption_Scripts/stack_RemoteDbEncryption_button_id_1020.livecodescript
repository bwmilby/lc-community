Script "stack_RemoteDbEncryption_button_id_1020"

/*
# Name: button "More Web Info" of card "phpScript" of stack "RemoteDbEncryption"
# ID: button id 1020 of card id 1009 of stack "RemoteDbEncryption"
*/


on mouseup
   local tURL
   
   put "https://en.wikipedia.org/wiki/Advanced_Encryption_Standard" into tURL
   launch url tURL
end mouseup
