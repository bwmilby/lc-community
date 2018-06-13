Script "stack_MasterLibrary_field_id_23709"

/*
# Name: field "filter" of card "Misc" of stack "MasterLibrary"
# ID: field id 23709 of card id 23710 of stack "MasterLibrary"
*/


on textchanged
   if fld "filter" is empty then
      put the uErrList of fld "scriptErrors" into fld "scriptErrors"
   else
      put the uErrList of fld "scriptErrors" into theList
      put "*" & fld "filter" & "*" into thefilter
      filter thelist with thefilter
      put theList into fld "scriptErrors"
   end if
end textchanged

on rawkeydown x
   if x = 65293 then exit to top
   pass rawkeydown
end rawkeydown

