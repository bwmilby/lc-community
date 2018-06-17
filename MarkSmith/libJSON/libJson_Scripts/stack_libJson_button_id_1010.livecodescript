Script "stack_libJson_button_id_1010"

/*
# Name: button "json.toArray" of card id 1002 of stack "libJson"
# ID: button id 1010 of card id 1002 of stack "libJson"
*/


--> all handlers

on mouseUp
   put the json of me into tJson
   put jsonToArray(tJson) into tArray
   
   put displayArray(tArray)
end mouseUp

function displayArray pArray, pLevel
   if pLevel is empty then put 0 into pLevel
   
   repeat for each key k in pArray
      repeat pLevel
         put "   " after tDisplay
      end repeat
      if pArray[k] is an array then
         put k && ":" & cr & displayArray(pArray[k], pLevel + 1) & cr after tDisplay
      else
         put k && "=" && pArray[k] & cr after tDisplay
      end if
   end repeat
   replace cr & cr & cr with cr & cr in tDisplay
   return tDisplay
end displayArray
