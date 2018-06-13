Script "stack_MasterLibrary_field_id_23697"

/*
# Name: field "filter" of group "filterList" of card "LibMgr" of stack "MasterLibrary"
# ID: field id 23697 of group id 23686 of card id 23690 of stack "MasterLibrary"
*/


on textchanged
   dispatch "BuildDisplayFiltered" to fld "TabList" with fld "filter"
end textchanged

on rawkeydown x
   if x = 65293 then exit to top
   pass rawkeydown
end rawkeydown


