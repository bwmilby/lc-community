Script "stack_MasterLibrary_card_id_23690"

/*
# Name: card "LibMgr" of stack "MasterLibrary"
# ID: card id 23690 of stack "MasterLibrary"
*/


local theLib
global gFuctionDisplay
global skip
global masterIndex

on opencard
   put empty into sScriptOnlyStackName
   put empty into sScriptOnlyPath
   if skip is not false then
      put false into skip
      initCard
   end if
    fixDisplay
end opencard

on updateMasterIndex
   put the script of btn "Lib" of cd "LibMgr" into input
   parse input, masterIndex
end updateMasterIndex

on initCard
   put empty into fld "Syntax"
   put empty into fld "Examples"
   put empty into fld "Notes"
   put empty into fld "Source"
   updateMasterIndex
   put buildlist() into MasterListArray  -- passing no stack builds the initial array
   set the uMaster of fld "FnList" to reFormatMaster(MasterListArray)
   --set the uMaster of fld "TabList" to MasterListArray
   dispatch "refresh" to fld "TabList"
   set the text of btn "stacks" to  get_other_stacks()
   verify_test_handlers MasterListArray
   set the label of btn "stacks" to the short name of this stack
   set the hilite of btn "filter" to false
   dispatch "menuPick" to me with the short name of this stack
end initCard

on  getOtherStacks
   set the text of btn "stacks" of card "LibMgr" to  get_other_stacks()
end getOtherStacks

on mouseup
   put the short name of the target into jump
   switch jump
      case "Insert Script"
         put getSelected() into theList
         build_library theList
         break
      case "Refresh"
         initCard
         break
      case "Help"
         go to cd "Help"
         break
      case "View"
         if  gFuctionDisplay <> empty then
            build_library gFuctionDisplay, true
            put the result into fld "script" of cd "Source"
            put false into skip
            go to cd "Source"
         end if
         break
      case "Only Selected"
      case "Filter"
         fixDisplay
         break
      case "ScriptOnly"
         CreateScriptOnly
         break
      default
          set the text of btn "stacks" to  get_other_stacks()
   end switch
   
end mouseup

on CreateScriptOnly
   ask file "Please name the Script Only Library file:"
   if it is empty then exit to top
   set the itemdel to "/"
   put item 1 to -2 of it into sScriptOnlyPath
   put item -1 of it into sScriptOnlyStackName
   set the itemdel to "."
   put item 1 of sScriptOnlyStackName into sScriptOnlyStackName
   create script only stack sScriptOnlyStackName
   set the script of stack sScriptOnlyStackName to \
          cr & "-- Library Routines Below" 
   save stack sScriptOnlyStackName as (sScriptOnlyPath & "/" & sScriptOnlyStackName & ".livecode")
   set the text of btn "stacks" to  get_other_stacks()
   set the label of btn "stacks" to sScriptOnlyStackName
end CreateScriptOnly

function _ScriptOnly pStackName
   put the effective filename of stack pStackName into thePath
   open file thePath
   read from file thePath for 20
   if word 1 of it contains "script" then
      put true into rData
   else
      put false into rData
   end if
   close file thePath
   return rData
end _ScriptOnly

on fixDisplay
   if the hilite of btn "filter" then
      set the vis of grp "filterlist" to true
      set the vis of grp "fn" to false
      dispatch "BuildDisplay" to fld "TabList"
      set the hilitedline of fld "TabList" to empty
   else
      set the vis of grp "filterlist" to false
      dispatch "BuildDisplay" to fld "fnList"
      set the vis of grp "fn" to true
   end if
end fixDisplay

on menuPick pItemName
   put pItemName into target_stack
   put buildlist() into MasterListArray --reset the master to so no functions selected
   put buildlist(target_stack) into alreadySelected
   repeat for each line x in alreadySelected
      if x is not among the keys of MasterListArray then 
         answer "Corrupt Library - entry not in Master Library"
         breakpoint
         exit to top
      end if
      put true into MasterListArray[x]["Check"]
   end repeat
   set the uMaster of fld "FnList" to reFormatMaster(MasterListArray)
   fixDisplay
   end menuPick

-- Constructor for the master Library Array.
-- if no parameter is passed, the masterLibrary Array is return
-- if a stackname is passed in, the a list of fuctions is returned in a cr delimited list

function buildList lib
   put empty into rout
   if lib is empty then
      repeat for each line x in keys of masterIndex
         if "category" is among the keys of masterIndex[x] then
            put masterIndex[x]["category"] into rout[x]["Type"]
            put false into rout[x]["Check"]
         end if
      end repeat
   else
      put the script of stack lib into tList
      get lineoffset ("-- Library Routines Below", tList) 
      if it is not 0 and it is not 1 then
         delete line 1 to it of tList
      end if
   end if
   parse tList, tIndex
   repeat for each line x in keys of tIndex
      if "category" is among the keys of tIndex[x] then
         put x & cr after rout
      end if
   end repeat
   return rout
end buildList

function reFormatMaster @ain
   put 1 into z
   repeat for each line x in the keys of ain
      put x into rout[z]["Name"]
      repeat for each line y in the keys of ain[x]
         put ain[x][y] into rout[z][y]
      end repeat
      add 1 to z
   end repeat
   return rout
end reFormatMaster

function script_meta_data fnName
   -- returns an array of meta data for the library command or function within
   -- the Master Library Script (the script of btn "Lib")
   
   put empty into rArray
   put line item 1 of  masterIndex[fnName]["comment"] to \
         item 2 of masterIndex[fnName]["comment"] of the script of btn "Lib" of cd "LibMgr" into Comment
   
   repeat with i = 1 to the number of lines in Comment
      put word 1 to -1 of line i of Comment into line i of Comment
   end repeat
   delete  line 1 of Comment
   
   repeat until Comment is empty
      if word 1 of line 1 of Comment <> "Syntax:" then
         delete line 1 of Comment
      else
         delete line 1 of Comment
         repeat until  word 1 of line 1 of Comment = "Examples:" or Comment = empty
            put line 1 of Comment & return after rArray["syntax"]
            delete line 1 of Comment
         end repeat
         if the last char of rArray["syntax"] is return then delete the last char of rArray["syntax"]
         exit repeat
      end if
   end repeat
   
   repeat until Comment is empty
      if word 1 of line 1 of Comment <> "Examples:" then
         delete line 1 of Comment
      else
         delete line 1 of Comment
         repeat until word 1 of line 1 of Comment = "Description:" or Comment = empty
            put line 1 of Comment & return after rArray["examples"]
            delete line 1 of Comment
         end repeat
         if the last char of rArray["examples"] is return then delete the last char of rArray["examples"]
         exit repeat
      end if
   end repeat
   
   repeat until Comment is empty
      if word 1 of line 1 of Comment <> "Description:" then
         delete line 1 of Comment
      else
         delete line 1 of Comment
         put "^\s*" & fnName & "\s+\*\/.*" into regexp
         repeat until \
               word 1 line 1 of Comment = "Source:" or \
               Comment = empty or \
               MatchText(line 1 of Comment,regexp)
            put line 1 of Comment & return after rArray["description"]
            delete line 1 of Comment
         end repeat
         if the last char of rArray["description"] is return then delete the last char of rArray["description"]
         exit repeat
      end if
   end repeat
   
   repeat until Comment is empty
      if word 1 of line 1 of Comment <> "Source:" then
         delete line 1 of Comment
      else
         delete line 1 of Comment
         put "^\s*" & fnName & "\s+\*\/.*" into regexp
         repeat until \
               MatchText(line 1 of Comment,regexp) or \ 
               Comment = empty
            put line 1 of Comment & return after rArray["source"]
            delete line 1 of Comment
         end repeat
         if the last char of rArray["source"] is return then delete the last char of rArray["source"]
         exit repeat
      end if
   end repeat
   return rArray
end script_meta_data



function get_other_stacks
   -- Returns a list of potential library stacks.  A library stack must be one of the following"
   -- have the stack script empty   or
   -- must contain a line "-- Library Routines Below"
   
   put revloadedStacks() into temp
   
   filter temp without "Data Grid Templates*"
   repeat for each line x in temp
      if the password of stack x is true then next repeat
      if the script of stack x is empty or \
            lineoffset ("-- Library Routines Below", the script of stack x) <> 0 then
         put x & return after thelist
      end if
   end repeat
   return thelist
end get_other_stacks

function getSelected
   put the uSelected of fld "FnList" into rout
   return rout
end getSelected

on build_library rNames inResult
   put the label of btn "stacks" into target_stack
   if inResult <> true then
      answer "Inserting into stack:" && target_stack & cr & cr & "Correct?" with "Yes" and "No"
      if it is "No" then exit to top
   end if
   if rNames = empty then 
      if inResult <> true then
         answer "Do you really want to set the Library Scripts of stack" && target_stack && "to empty" with "Yes" or "No"
         if it is "No" then exit to top
      end if
      put empty into theScript
      insert_script target_stack, theScript
      exit to top
   end if
   if inResult <> true then
      answer "Inserting:" & cr & cr & rNames & cr &  "Proceed?" with "Yes" and "No"
      if it is "No" then exit to top
   end if
   put empty into modulelist
   repeat until rNames is empty
      put word 1 of rNames into x
      delete line 1 of rNames
      if x is not among the lines of modulelist then 
         put x & cr after modulelist
         if masterIndex[x]["includes"] <> empty then
            put masterIndex[x]["includes"] into includelist
            repeat for each line y in includelist
               if y is not among the lines of modulelist then
                  if y is not among the lines of rNames then
                     put y & cr after rNames
                  end if
               end if
            end repeat
         end if
      end if
   end repeat
   repeat for each line x in moduleList
      if masterIndex[x]["Kind"] = "-- begin" then
         put 1, x & cr after thelist
      else
         put 2, x & cr after thelist
      end if
   end repeat
   sort thelist by item 2 of each 
   sort thelist numeric
   if inResult <> true then
      put "-- Library Routines Below" & cr & cr & cr into theScript
   end if
   repeat for each line x in thelist
      put item 2 of x into x
      set the cursor to busy
      put  item 1 of masterIndex[x]["code"] into s
      put  item 2 of masterIndex[x]["code"] into e
      put line s to e of the script of btn "Lib" of cd "LibMgr" & cr & cr & cr after theScript
   end repeat
   if inResult is true then
      return theScript
   else
      if target_stack is not empty then 
         insert_script target_stack, theScript
      end if
   end if
   set the cursor to arrow
end build_library

on insert_script stackname @Scr
   if the password of stack stackname is true then exit insert_script
   if the script of stack stackname is empty and Scr is empty then exit insert_script
   if the script of stack stackname is empty then
      set the script of stack stackname to Scr
      exit insert_script
   end if
   put lineoffset ("-- Library Routines Below", the script of stack stackname) into lib_start
   if lib_start = 0 then
      answer "Stack" && stackname && "does not have Library Routines section"
      exit to top
   end if
   put the script of stack stackname into temp
   if Scr is empty then
      delete line (lib_start + 1) to -1 of temp  -- remove anything afer marker, but leave marker
   else
      delete line lib_start to -1 of temp  -- delete marker because it is in Scr already
   end if
   put Scr after temp
   try
      set the script of stack stackname to temp
   catch theError
      dispatch function "__expandError" to btn "Lib" of cd "LibMgr" with theError
      if it = "handled" then
         put the result into expandedError
      else
         put it & cr & theError into expandedError
      end if
      answer "An Error Occured when trying to set the script of stack" && stackname & cr & expandedError
   end try
   
   get lineoffset( "__InstallPasswordFont", temp)
   if it <> 0 then
      put the PasswordTextFont of stack "MasterLibrary" into it
      put the custompropertyset of stack stackname into oldcps
      set the custompropertyset of stack stackname to "Library"
      set the PasswordTextFont of stack stackname to it
      set the custompropertyset of stack stackname to oldcps
   end if 
   
   if  _ScriptOnly (stackname) then
      save stack stackname
   end if
end insert_script

on verify_test_handlers @MasterListArray
   put the keys of MasterListArray into functionList
   put the script of btn "Test" of cd "LibMgr" into testScript
   put "(?i)^\s*on\s+test_.*" into regexp
   repeat for each line L in testScript
      get MatchText(L,regexp)
      if it then put word 2 of L & cr after testFunctions
   end repeat
   repeat for each line x in functionList
      if "test_" & x is not among the lines of testFunctions then
         put cr & "on test_" & x & cr after testScript
         put "--TODO" & cr after testScript
         put "end test_" & x & cr after testScript
      end if
   end repeat
   try
      set the script of btn "Test" of cd "LibMgr" to testScript
   catch theError
      dispatch function "__expandError" to btn "Lib" of cd "LibMgr" with theError
      if it = "handled" then
         put the result into expandedError
      else
         put it & cr & theError into expandedError
      end if
      answer "An error occure trying to update the Test Button." & cr & expandedError
   end try
end verify_test_handlers

function replaceFirstPeriod tList
   put empty into tListo
   repeat for each line x in tList
      if x contains "." then
         repeat with y = 1 to the length of x
            if char y of x = "." then 
               put space into char y of x
               exit repeat
            end if
         end repeat
         put x & cr after tListo
      else
         put x & cr after tListo
      end if
   end repeat
   return tListo
end replaceFirstPeriod

/*
Parse is passed the code to analize in input and a container to be updated with
an array of information about the code.  The first level of index are the function and command
names.  the second level index contains:

code_start - linenumber of first line of code
code_end - linenumber of last line of code
comment_start - linenumber of first line of comment description
comment_end - linenumber of first line of comment description
include_start - linenumber of start of include marker
include-end - linenumber of end of include marker
includes - contains the lines of included routine
kind - one of "function", "private function", "command", "private command", "on", "-- begin"
"-- begin" refers to a variable block,  all others refer to executable code segments
category - the grouping of the code block.

This optimized version of the parser is courtesy of Thierry Douez <th.douez@gmail.com>
*/


--on parse @input, @output
--   local old_name, state, x
--   put empty into output
--   put empty into old_name
--   put "out" into state

--   put 0 into x -- line number
--   repeat for each line aLine in input
--      add 1 to x

--      if not _getToken( aLine, old_name, cmd, tname, category ) then next repeat

--      switch cmd
--         case "function"
--         case "private function"
--         case "command"
--         case "private command"
--         case "on"
--            if state is "out" then
--               put "in" into state
--               put x into item 1 of output[tname]["code"]
--               put cmd into output[tname]["kind"]
--               put tname into old_name
--            else
--               if "comment" is not among the lines of the keys of output[old_name] then
--                  answer "Error 1" && line x of input
--                  breakpoint
--                  exit to top
--               end if
--            end if
--            break
--         case "-- begin"
--            if state is "out" then
--               put "in" into state
--               put x into item 1 of output[tname]["code"]
--               put cmd into output[tname]["kind"]
--               put tname into old_name
--            else
--               answer "Error 2" && line x of input
--               breakpoint
--               exit to top
--            end if
--            break
--         case "-- end"
--         case "end"
--            if state is  "in" and tname = old_name then
--               put "out" into state
--               put x into item 2 of output[old_name]["code"]
--               put empty into old_name
--            else
--               answer "Error 3" && line x of input
--               breakpoint
--               exit to top
--            end if
--            break
--         case "include"
--            if state is "in" and old_name <> empty then
--               put x into item 1 of output[old_name]["incl"]
--            end if
--            break
--         case "end_include"
--            if state is "in" and old_name <> empty then
--               -- trying to make sure that normal comments are allowed by testing the keys.
--               if "incl" is among the lines of the keys of output[old_name] and \
      --                     the number of items in output[old_name]["incl"]  = 1 then
--                  put x into item 2 of output[old_name]["incl"]
--                  put item 1 of output[old_name]["incl"] + 1 into ss
--                  put item 2 of output[old_name]["incl"] - 1 into ee
--                  put line ss to ee of input into temp
--                  repeat for each line i in temp
--                     put word 1 of i & cr after output[old_name]["includes"]
--                  end repeat
--               end if
--            end if
--            break
--         case "comment"
--            if state is "in" and old_name <> empty then
--               put x into item 1 of output[old_name]["comment"]
--               put word 1 to  -1 of category into output[old_name]["category"]
--            end if
--            break
--         case "end_comment"
--            if state is "in" and old_name <> empty then
--               put x into item 2 of output[old_name]["comment"]
--            end if
--            break
--      end switch
--   end repeat
--end parse

--private function _getToken @tLine oldname @cmd @tname @category
--   -- -- handler definition
--  get "(?i)^\s*(private\s)?(?:\s*)?(function|command|on)\s+(\w+)"
--   if MatchText( tLine, IT, isPrivate,cmd, tname) then
--      put isPrivate  before cmd
--      return TRUE
--   end if
--   -- -- end
--   if oldname is not empty then
--      if MatchText( tLine, "(?i)^\s*(--\s+end)\s+\Q" & oldname & "\E", cmd )  then 
--         put oldname into tname
--         return TRUE
--      end if   
--   end if
--   -- -- begin  codeblock
--   if MatchText( tLine,  "(?i)^\s*(--\s+begin)\s+(\w+)" ,cmd, tname) then return TRUE
--   -- "end" codeblock 
--   if oldname is not empty then
--      if MatchText( tLine, "(?i)^\s*(end)\s+(\Q" & oldname & "\E)", cmd, tname) then return TRUE
--      -- Start Comment
--      if MatchText(tLine, "(?i)^\s*\/\*\s+\Q" & oldname & "\E\s+(.*)\s*$", category)  then 
--         put "comment" into cmd
--         put oldname into tname
--         return TRUE
--      end if
--      -- Start Comment
--      if MatchText(tLine, "(?i)^\s*\Q" & oldname & "\E\s+\*/")  then 
--         put "end_comment" into cmd
--         return TRUE
--      end if
--   end if -- oldname is not empty
--   -- include 
--   if MatchText( tLine, "(?i)^\s*/\*\s+include") then
--      put "include" into cmd
--      return TRUE
--   end if
--   -- end of include 
--   if MatchText(tLine,  "^\s*\*/")  then
--      put "end_include" into cmd
--      return TRUE
--   end if
--   return FALSE
--end _getToken


// THIERRY  PARSING BASED ON A FINITE STATE MACHINE (FSM)

// our FSM Matrix
// All states of our FSM
constant S_START=1
constant S_BEGIN=2
constant S_INCLUDE=3
constant S_HANDLER=4
constant S_COMMENT=5
// All transitions of our FSM
constant T_NONE=0 -- see transition switchs
constant T_BEGIN=1
constant T_BEGIN_END=2
constant T_HANDLER=3
constant T_HANDLER_END=4
constant T_INCLUDE=5
constant T_INCLUDE_END=6
constant T_COMMENT=7
constant T_COMMENT_END=8
// the current state
local fsmState

private command newState v
   put v into fsmState
end newState

on parse @input, @output
   local  nLine, currentCmdName, currentBeginName, currentIncludeName
   put empty into output
   newState S_START
   
   put 0 into nLine -- line number
   repeat for each line tLine in input
      add 1 to nLine
      
      switch  fsmState
         
         case S_START    -- wait for transitions: T_begin T_handler
            switch isToken_Begin_Handler( tLine, cmd, tname)
               case T_NONE
                  break
               case T_HANDLER
                  put nLine into output[tname]["code"]
                  put cmd into output[tname]["kind"]
                  put tname into currentCmdName
                  newState S_HANDLER
                  break
               case T_BEGIN
                  put nLine into output[tname]["code"]
                  put cmd into output[tname]["kind"]
                  put tname into currentBeginName
                  newState S_BEGIN
                  break
               default
                  breakpoint -- Never here
            end switch
            break
            
         case S_HANDLER --  T_comment T_include T_handler_end
            switch isToken_Comment_Include_HandlerEnd( tLine, currentCmdName, category)
               case T_NONE
                  break
               case T_COMMENT
                  put nLine into output[tname]["comment"]
                  put category into output[tname]["category"]
                  newState S_COMMENT
                  break
               case T_INCLUDE
                  put nLine into output[ currentCmdName]["incl"]
                  newState S_INCLUDE
                  break
               case T_HANDLER_END
                  put nLine into item 2 of output[ currentCmdName]["code"]
                  newState S_START
                  break
               default
                  breakpoint -- Never here
            end switch
            break
            
         case S_COMMENT -- T_comment_end
            switch isToken_Comment_end( tLine, currentCmdName)
               case T_NONE
                  break
               case T_COMMENT_END
                  put nLine into item 2 of output[ currentCmdName]["comment"]
                  newState S_HANDLER
                  break
               default
                  breakpoint -- Never here
            end switch
            break
            
         case S_INCLUDE -- T_include_end
            switch isToken_Include_end( tLine)
               case T_NONE
                  get replaceText( tLine, space, empty)
                  put  IT & cr after output[ currentCmdName]["includes"]
                  break
               case T_INCLUDE_END
                  put nLine into item 2 of output[ currentCmdName]["incl"]
                  -- if you feel so, here you can get rid of the extra cr:
                  delete last char of  output[ currentCmdName]["includes"]
                  newState S_HANDLER
                  break
               default
                  breakpoint -- Never here
            end switch
            break
            
         case S_BEGIN -- T_begin_end
            switch isToken_Begin_end( tLine, currentBeginName)
               case T_NONE
                  break
               case T_BEGIN_END
                  put nLine into item 2 of output[ currentBeginName]["code"]
                  newState S_START
                  break
               default
                  breakpoint -- Never here
            end switch
            break
            
         default
            put "<" &  fsmState & ">" &Cr& tLine &cr& nLine
            breakpoint -- Never here!
      end switch
      
   end repeat
end parse

private function isToken_Begin_Handler @aLine @typeCmd @cmd_Name
   if MatchText( aLine,  "(?i)^\s*(--\s+begin)\s+(\w+)" ,typeCmd, cmd_Name) then \
               return T_BEGIN
   get "(?i)^\s*(private\s)?(?:\s*)?(function|command|on)\s+(\w+)"
   if MatchText( aLine, IT, isPrivate, typeCmd, cmd_Name) then
      put isPrivate before typeCmd
      return T_HANDLER
   end if
   return T_NONE
end isToken_Begin_Handler

private function isToken_Comment_end  @aLine @currentName
   if MatchText( aLine, "(?i)^\s*\Q" & currentName & "\E\s+\*/")  then \
               return T_COMMENT_END
   return T_NONE
end isToken_Comment_end

private function isToken_Include_end  @aLine
   if MatchText(aLine,  "^\s*\*/")  then \
               return T_INCLUDE_END
   return T_NONE
end isToken_Include_end

private function isToken_Begin_end  @aLine @currentName
   if MatchText( aLine, "(?i)^\s*(--\s+end)\s+\Q" & currentName & "\E", cmd )  then \
               return T_BEGIN_END
   return T_NONE
end isToken_Begin_end

private function isToken_Comment_Include_HandlerEnd @aLine, @currentName @category
   if MatchText( aLine, "(?i)^\s*/\*\s+include") then \
               return T_INCLUDE
   if MatchText(aLine, "(?i)^\s*/\*\s+\Q" & currentName & "\E\s+(.*)\s*$", category) then \
               return T_COMMENT
   if MatchText( aLine, "(?i)^\s*(end)\s+(\Q" & currentName & "\E)", cmd, tname) then \
               return T_HANDLER_END
   return T_NONE   
end isToken_Comment_Include_HandlerEnd
