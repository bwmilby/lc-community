Script "stack_freedbDemo_button_id_1010"

/*
# Name: button "playersp" of card id 1002 of stack "freedbDemo"
# ID: button id 1010 of card id 1002 of stack "freedbDemo"
*/


--> all handlers

on mouseUp
   if the filename of player "p1" is not empty then
      if  isPlaying() then
         stopTrack
      else
         startTrack
      end if
   end if 
end mouseUp
