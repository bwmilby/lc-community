Script "stack_libS3Docs_button_id_1010"

/*
# Name: button "Tab Menu" of card id 1002 of stack "libS3Docs"
# ID: button id 1010 of card id 1002 of stack "libS3Docs"
*/


--> all handlers

on menuPick pChosen
   switch pChosen
      case "intro to S3"
         hide fld "notesText"
         hide grp "dictionary"
         show fld "introText"
         break
      case "dictionary"
         send "makeList" to grp "dictionary"
         show grp "dictionary"
         hide fld "notesText"
         hide fld "introText"
         break
      case "notes"
         show fld "notesText"
         hide grp "dictionary"
         hide fld "introText"
         
         break
   end switch
end menuPick
