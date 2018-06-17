Script "stack_libS3Docs_field_id_1007"

/*
# Name: field "handlers" of group "dictionary" of card id 1002 of stack "libS3Docs"
# ID: field id 1007 of group id 1011 of card id 1002 of stack "libS3Docs"
*/


--> all handlers



on selectionChanged
   put the selectedtext of me into tHandler
   set the htmltext of fld "dictText" to the dictionary[tHandler] of this stack
end selectionChanged
