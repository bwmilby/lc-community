Script "stack_MasterLibrary_button_id_23563"

/*
# Name: button "Copy to Clipboard" of card "Source" of stack "MasterLibrary"
# ID: button id 23563 of card id 23555 of stack "MasterLibrary"
*/


on mouseUp
   put fld "script" into it
   set the clipboardData["text"] to it
end mouseUp
