Script "stack_MasterLibrary_field_id_23700"

/*
# Name: field "FnList" of group "Fn" of card "LibMgr" of stack "MasterLibrary"
# ID: field id 23700 of group id 23689 of card id 23690 of stack "MasterLibrary"
*/


global gFuctionDisplay
global masterIndex

setprop uMaster pArray
   put empty into tA
   repeat for each line x in the keys of pArray
      put pArray[x]["Check"] into tA[pArray[x]["Type"]][pArray[x]["Name"]]
      if tA[pArray[x]["Type"]][pArray[x]["Name"]] then
         put true into tA[pArray[x]["Type"]]["status"]
      end if
   end repeat
   set the uMasterArray of me to tA
end uMaster

getprop uMasterList
   put empty into tList
   put the uMasterArray of me into tA
   repeat for each line x in the keys of tA
      repeat for each line y in the keys of tA[x]
         if y = "status" then next repeat
            put y & tab & x & cr after tList
      end repeat
   end repeat
   return tList
end uMasterList

getprop uSelected
   put empty into tList
   put the uMasterArray of me into tA
   repeat for each line x in the keys of tA
      repeat for each line y in the keys of tA[x]
         if y = "status" then next repeat
         if tA[x][y] then 
            put y & cr after tList
         end if
      end repeat
   end repeat
   return tList
end uSelected

on BuildDisplay
   lock screen
   put the vScroll of me into scrollpos
   put empty into me
   put 0 into ctr
   put the uMasterArray of me into tA
   put the keys of tA into tList
   sort tList
   repeat for each line x in tList  -- this is the list of topics
      add 1 to ctr
      put space & space & space & x & cr after me -- output the main topic line with no indention
      set the leftindent of line ctr of me to 0
      if tA[x]["status"] is empty or tA[x]["status"] = "-" then -- ignore all of the members
         set the imagesource of char 1 of line ctr of me to 200086
         next repeat
      else -- open, list all of the member of this topic 
         set the imagesource of char 1 of line ctr of me to 200087
         
         -- now do all of the functions under the topic
         
         add 1 to ctr
         put ctr into startLineofIndent
         put the keys of tA[x] into fList -- get the list of fuctions under the topic
         filter fList without "status"  -- remove the key that holds the colaption status of the topic
         sort fList
         repeat for each line y in fList
            put space & space & space & y & cr after me -- output the topic
            if tA[x][y] then 
               set the imagesource of char 1 of line ctr of me to 22174
            else
               set the imagesource of char 1 of line ctr of me to 22173
            end if
            add 1 to ctr
         end repeat
         subtract 1 from ctr -- back up the counter to the last line
         put ctr into endLineofIndent
         set the leftindent of line startLineofIndent to endLineofIndent of me to 15
      end if
   end repeat
   if the last char of me is cr then delete the last char of me
   set the vScroll of me to scrollpos
   unlock screen
end BuildDisplay

on selectionchanged
   put the uMasterArray of me into tA
   put false into reBuild
   put the imagesource of the clickCharChunk into imageSelected
   put the selectedline of me into lineSelected
   put word 1 to -1 of value( the selectedline of me) into textSelected
   
   switch imageSelected
      case 200087 -- -
         put "-" into tA[textSelected]["status"]
         put true into reBuild
         break
      case 200086 -- +
         put "+" into tA[textSelected]["status"]
         put true into reBuild
         break
      case 22174 -- checked
         repeat for each line x in the keys of tA
            if textSelected is among the keys of tA[x] then put false into tA[x][textSelected]
         end repeat
         set the imagesource of char 1 of lineSelected to 22173
         break
      case 22173-- not checked
         repeat for each line x in the keys of tA
            if textSelected is among the keys of tA[x] then put true into tA[x][textSelected]
         end repeat
         set the imagesource of char 1 of lineSelected to 22174
         break
      default
         if textSelected is not among the keys of tA then
            put textSelected into gFuctionDisplay
            put script_meta_data (textSelected) into tArray
            put tArray["syntax"] into fld "Syntax"
            put replaceFirstPeriod(tArray["examples"]) into fld "Examples"
            put replaceFirstPeriod(tArray["description"]) into fld "Notes"
            put tArray["source"] into fld "Source"
         else
            put empty into gFuctionDisplay
            put "" into fld "Syntax"
            put "" into fld "Examples"
            put "" into fld "Notes"
            put "" into fld "Source"
         end if
   end switch
   
   set the uMasterArray of me to tA
   if reBuild then BuildDisplay
end selectionchanged
