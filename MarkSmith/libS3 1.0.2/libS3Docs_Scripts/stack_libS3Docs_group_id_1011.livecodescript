Script "stack_libS3Docs_group_id_1011"

/*
# Name: group "dictionary" of card id 1002 of stack "libS3Docs"
# ID: group id 1011 of card id 1002 of stack "libS3Docs"
*/


--> all handlers

on makeList
   put the customKeys["dictionary"] of this stack into hList
   sort lines of hList
   put hList into fld "handlers" of me
end makeList
