Script "stack_libRevCurlDictionary_field_id_1011"

/*
# Name: field "handlers" of card id 1002 of stack "libRevCurlDictionary"
# ID: field id 1011 of card id 1002 of stack "libRevCurlDictionary"
*/


--> all handlers

on selectionChanged
   put value(the selectedline of me) into tKey
   lock screen
   put the notes[tKey] of this stack into tNote
   put line 1 of tNote & cr & cr  into fld "display"
   put line 2 of tNote & cr & cr after fld "display"
   put line 3 of tNote & cr & cr after fld "display"
   put line 4 to -1 of tNote after fld "display"
    
   set the textsize of line 1 of fld "display" to 24
   set the textstyle of line 1 of fld "display" to "underline"
   
   set the textcolor of line 3 of fld "display" to "127,127,127"
   set the textstyle of line 3 of fld "display" to "italic"
   
   unlock screen
end selectionChanged
