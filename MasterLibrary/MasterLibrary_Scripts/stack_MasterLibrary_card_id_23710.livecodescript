Script "stack_MasterLibrary_card_id_23710"

/*
# Name: card "Misc" of stack "MasterLibrary"
# ID: card id 23710 of stack "MasterLibrary"
*/


on opencard
   fetchErrors
end opencard

on fetchErrors
   put the cErrorsList of stack "revErrorReport" of stack "revStandaloneSettings" into errList
   set the itemdel to tab
   split errList with return
   combine errList with return and tab
   sort lines of errList numeric by item 1 of each
   put empty into fld "filter"
   put errList into fld "scriptErrors"
   set the uErrList of fld "scriptErrors" to errList
end fetchErrors

function resizeImageFile pFile, pOutFile, pMaxWid, pMaxHeight 
   local t, tt 

   import paint from file pFile 
   put the name of the last image into t 
   set the name of t to "Im1" 

   clone img "Im1" 
   set the name of it to "Im2" 
   setAreaProportional the long id of img "Im2", pMaxWid, pMaxHeight 
   export img "Im2" to file pOutFile as jpeg 
   put the result into tt 

   delete img "Im2" 
   delete img "Im1" 

   return empty      -- "Done resize" & ":" & tt & ":" && pFile && pOutfile 
end resizeImageFile 
