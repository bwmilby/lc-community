Script "stack_MasterLibrary_button_id_23714"

/*
# Name: button "CG" of card "LibMgr" of stack "MasterLibrary"
# ID: button id 23714 of card id 23690 of stack "MasterLibrary"
*/


on mouseUp
   put "https://dl.dropbox.com/s/k9t9xxl2s8bioje/ContactGenerator.livecode" into cNewStack
   ask file "Where would you like to put the ContactGenerator?" with "ContactGenerator.livecode"
   if it is empty then exit to top
   put it into pStackPath
   put URL cNewStack into URL ("binfile:" & pStackPath)
   put the result into tResult
   if tResult is not empty then
      answer warning tResult
   end if
   go to stack pStackPath
end mouseUp
