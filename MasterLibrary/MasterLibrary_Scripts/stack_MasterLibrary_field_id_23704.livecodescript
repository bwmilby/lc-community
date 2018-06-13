Script "stack_MasterLibrary_field_id_23704"

/*
# Name: field "scriptErrors" of card "Misc" of stack "MasterLibrary"
# ID: field id 23704 of card id 23710 of stack "MasterLibrary"
*/


on mouseup
   if the commandkey is down and the shiftkey is down then
      select empty
      set the locktext of me to not the locktext of me
   end if
end mouseup

on selectLine n
   select line n of me
end selectLine

on mousemove
   
end mousemove
