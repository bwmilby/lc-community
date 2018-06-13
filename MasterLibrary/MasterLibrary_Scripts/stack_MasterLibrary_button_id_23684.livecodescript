Script "stack_MasterLibrary_button_id_23684"

/*
# Name: button "Version" of card "LibMgr" of stack "MasterLibrary"
# ID: button id 23684 of card id 23690 of stack "MasterLibrary"
*/


on mouseUp
   put WeAreCurrent() into it
   if it = true then
      answer "You have the current version."
      set the default of me to false
   else
      put item 1 of it into newVer
      put item 2 of it into cNewStack
      ask file "Version" && newVer && "of MasterLibrary.livecode is available.  Where would you like to put it?" with "MasterLibrary.livecode"
      if it is empty then exit to top
      put it into pStackPath
      put URL cNewStack into URL ("binfile:" & pStackPath)
      put the result into tResult
      if tResult is not empty then
         answer warning tResult
      else
         set the default of me to false
      end if
      --      answer "Open the new version?" with "Yes" or "No"
      --      if it is "Yes" then
      --         go to card "LibMgr" of stack pStackPath
      --      end if
   end if
end mouseUp
