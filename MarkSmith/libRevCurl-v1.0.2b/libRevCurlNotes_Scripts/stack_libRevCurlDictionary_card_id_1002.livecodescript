Script "stack_libRevCurlDictionary_card_id_1002"

/*
# Name: card id 1002 of stack "libRevCurlDictionary"
# ID: card id 1002 of stack "libRevCurlDictionary"
*/


--> all handlers

on openCard
   put the customKeys["notes"] of this stack into tNotes
   
   sort lines of tNotes
   put tNotes into fld "handlers"
end openCard
