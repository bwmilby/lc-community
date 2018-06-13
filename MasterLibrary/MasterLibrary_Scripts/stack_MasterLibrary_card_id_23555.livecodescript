Script "stack_MasterLibrary_card_id_23555"

/*
# Name: card "Source" of stack "MasterLibrary"
# ID: card id 23555 of stack "MasterLibrary"
*/


global gFuctionDisplay

on preopencard
   -- colorize script
   -- thanks to Mark Wieder, of the useRev listserv
   put the number of lines of field "script" into tNum
   -- the following 2 lines are only necessary if no script has been opened yet in this
   --   session of LC
   -- and they will throw an error for later versions of LC
   try
      send "sePrefInit" to stack "revNewScriptEditor"
      send "revSEColorize thisScript,default" to stack "revNewScriptEditor"
   end try
   _internal script colorize line 1 to tNum of field "script"
   -- how he figured this out, I don't know
   
   set the hscrollbar of fld "script" to (the width of fld "script" < the formattedwidth of \
         fld "script")
end preopencard

on opencard
   put false into gotit
   put 0 into linesToSkip
   repeat until gotit is true
      put lineoffset (gFuctionDisplay, fld "script", linesToSkip) into theline
      if theline = 0 then put true into gotit
      put linesToSkip + theLine into theline
      put theLine into linesToSkip
      if word 1 of line theline of fld "script" is among the items "on,function,command" then
         put true into gotit
      end if
   end repeat
   put the effective textheight of field "script" into tLineHeight
   put the height of field "script"  into tFieldHeight
   put tLineHeight * theline into tScroll
   subtract tLineHeight from tScroll
   set the vscroll of field "script"  to trunc(tScroll)
end opencard
