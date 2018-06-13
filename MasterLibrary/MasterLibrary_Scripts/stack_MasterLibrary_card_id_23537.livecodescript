Script "stack_MasterLibrary_card_id_23537"

/*
# Name: card "Summary" of stack "MasterLibrary"
# ID: card id 23537 of stack "MasterLibrary"
*/


on opencard
   MakeDocs
end opencard

on MakeDocs
   put empty into fld "D"
   dispatch function "buildList" to cd "LibMgr"
   put flatten (the result) into theList
   set the styledtext of fld "D" to  makeListing(theList)
   set the scroll of fld "D" to 1
end MakeDocs

function flatten tA
   repeat for each line x in the keys of tA
      put tA[x]["Type"],x&cr after rOut
   end repeat
   sort rout by item 2 of each
   sort rout by item 1 of each
   return rOut
end flatten

function makeListing theList
   put 1 into pgh
   put 1 into run
   put empty into ttype
   repeat for each line x in theList
      set the cursor to busy
      put item 2 of x into tname
      dispatch function "script_meta_data"  to cd "LibMgr" with tname
      put the result into meta
      if item 1 of x <> ttype then 
         put item 1 of x into rOut[pgh]["runs"][run]["text"]
         put "bold" into rOut[pgh]["runs"][run]["style"]["textstyle"]
         put "14" into rOut[pgh]["runs"][run]["style"]["textsize"]
         put 5 into rOut[pgh]["style"]["spacebelow"]
         put 0 into rOut[pgh]["style"]["leftindent"]
         add 1 to pgh
         put 1 into run
      end if
      put item 1 of x into ttype
      put line 1 of meta["syntax"] into rOut[pgh]["runs"][run]["text"]
      --      if word 1 of rOut[pgh]["runs"][run]["text"] <> "Cmd:" then
      --         put "Ftn:     " before rOut[pgh]["runs"][run]["text"]
      --      end if
      put "plane" into rOut[pgh]["runs"][run]["style"]["textstyle"]
      put "12" into rOut[pgh]["runs"][run]["style"]["textsize"]
      put 5 into rOut[pgh]["style"]["spacebelow"]
      put 20 into rOut[pgh]["style"]["leftindent"]
      add 1 to pgh
      put 1 into run
      --      if meta["examples"] <> empty then
      --         put "Examples:" into rOut[pgh]["runs"][run]["text"]
      --         put 40 into rOut[pgh]["style"]["leftindent"]
      --         add 1 to pgh
      --         put 1 into run
      --         repeat for each line y in meta["examples"]
      --            put y into rOut[pgh]["runs"][run]["text"]
      --            if char 1 of rOut[pgh]["runs"][run]["text"] = "." then put " " into char 1 of rOut[pgh]["runs"][run]["text"]
      --            put 60 into rOut[pgh]["style"]["leftindent"]
      --            add 1 to pgh
      --            put 1 into run
      --         end repeat
      --         put 5 into rOut[pgh-1]["style"]["spacebelow"]
      --      end if
      --      if meta["description"] <> empty then
      --         put "Description:" into rOut[pgh]["runs"][run]["text"]
      --         put 40 into rOut[pgh]["style"]["leftindent"]
      --         add 1 to pgh
      --         put 1 into run
      --         repeat for each line y in meta["description"]
      --            put y into rOut[pgh]["runs"][run]["text"]
      --             if char 1 of rOut[pgh]["runs"][run]["text"] = "." then put " " into char 1 of rOut[pgh]["runs"][run]["text"]
      --            put 60 into rOut[pgh]["style"]["leftindent"]
      --            add 1 to pgh
      --            put 1 into run
      --         end repeat
      --         put 5 into rOut[pgh-1]["style"]["spacebelow"]
      --      end if
      --      if meta["source"] <> empty then 
      --         put "Source:" && line 1 of meta["source"] into rOut[pgh]["runs"][run]["text"]
      --         put 40 into rOut[pgh]["style"]["leftindent"]
      --         add 1 to pgh
      --         put 1 into run
      --      end if
      put 5 into rOut[pgh-1]["style"]["spacebelow"]
   end repeat
   set the cursor to arrow
   return rOut
end makeListing
