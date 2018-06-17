Script "stack_freedbDemo_field_id_1003"

/*
# Name: field "tracklist" of card id 1002 of stack "freedbDemo"
# ID: field id 1003 of card id 1002 of stack "freedbDemo"
*/


--> all handlers




on selectionchanged
   set the itemdelimiter to tab
   put word 2 of the selectedline of me into tLineNum
   put item 2 of line tLineNum of me into tTrack
   put the formattedheight of line 1 to tLineNum of me + the top of me - 3 into tHeight
   set the top of btn "playersp" to tHeight
   show btn "playersp"
   playTrack tTrack
end selectionchanged
