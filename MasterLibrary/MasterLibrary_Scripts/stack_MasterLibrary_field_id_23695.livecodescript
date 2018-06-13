Script "stack_MasterLibrary_field_id_23695"

/*
# Name: field "TabList" of group "filterList" of card "LibMgr" of stack "MasterLibrary"
# ID: field id 23695 of group id 23686 of card id 23690 of stack "MasterLibrary"
*/


global gFuctionDisplay

--setprop uMaster pArray
--   put empty into tA
--   repeat for each line x in the keys of pArray
--      put x & tab & pArray[x][ "Type"] & cr after thelist
--   end repeat
--   sort theList
--   set the uContents of fld "TabList" to theList
--   put thelist into fld TabList
--end uMaster

on BuildDisplay
   BuildDisplayFiltered fld "filter"
end BuildDisplay

on BuildDisplayFiltered theFilter
   lock screen
   put the vScroll of fld "TabList" into scrollpos
   put empty into fld "TabList"
   put empty into temp
   put the uMasterList of fld "fnList" into temp
   put the uSelected of fld "fnList" into checked
   sort temp
   set the itemdel to tab
   if the hilite of btn "Only Selected" then
      put empty into it
      repeat for each line x in temp
         if item 1 of x is among the lines of checked then put x & cr after it
      end repeat
      put it into temp
   else
      if thefilter is not empty then filter temp with "*" & thefilter & "*"
   end if
   set itemdel to tab
   repeat for each line x in temp
      put x & cr after fld TabList
      if item 1 of x is among the lines of checked then set the backgroundcolor of the last line of fld "TabList" to 225,225,255
   end repeat
   set the vScroll of fld "TabList" to scrollpos
   unlock screen
end BuildDisplayFiltered

on mouseup
   put the hilitedline of me into tline
   put line tline of me into textSelected
   set the itemdel to tab
   delete item 2 of textSelected
   put textSelected into gFuctionDisplay
   put script_meta_data (textSelected) into tArray
   put tArray["syntax"] into fld "Syntax"
   put replaceFirstPeriod(tArray["examples"]) into fld "Examples"
   put replaceFirstPeriod(tArray["description"]) into fld "Notes"
   put tArray["source"] into fld "Source"
end mouseup

on mousedoubleup
   put the hilitedline of me into tline
   put line tline of me into textSelected
   put the backgroundcolor of line tline of me into thecolor
   if thecolor is empty then 
      put 225,225,255 into thecolor
   else
      put empty into thecolor
   end if
   set  the backgroundcolor of line tline of me to thecolor
   set the hilitedline of me to empty
   set the itemdel to tab
   put item 1 of textSelected into y
   put item 2 of textSelected into x
   put the uMasterArray of fld "FnList" of cd "LibMgr" into tA
   if thecolor is empty then 
      put false into tA[x][y]
   else
      put true into tA[x][y]
   end if
   set the uMasterArray of fld "FnList" of cd "LibMgr" to tA
end mousedoubleup
