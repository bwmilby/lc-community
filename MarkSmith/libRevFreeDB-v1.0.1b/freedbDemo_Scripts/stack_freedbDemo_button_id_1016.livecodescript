Script "stack_freedbDemo_button_id_1016"

/*
# Name: button "eject" of card id 1002 of stack "freedbDemo"
# ID: button id 1016 of card id 1002 of stack "freedbDemo"
*/


--> all handlers

on mouseUp
   put the cdPath of this stack into tCDpath
   ejectDisc tCDpath
end mouseUp
