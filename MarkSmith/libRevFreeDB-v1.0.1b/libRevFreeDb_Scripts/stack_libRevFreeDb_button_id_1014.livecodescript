Script "stack_libRevFreeDb_button_id_1014"

/*
# Name: button "try it..." of card id 1002 of stack "libRevFreeDb"
# ID: button id 1014 of card id 1002 of stack "libRevFreeDb"
*/


--> all handlers

on mouseUp
   if the platform is "MacOS" then
      answer folder "Choose CD..."
      if it is empty then exit to top
      put it into tCDpath
      put getCDdata(tCDpath) into tData
   else if the platform is "Win32" then
      put getCDdata() into tData
       
   end if
   put showArray(tData)
end mouseUp

function showArray pArray, pLevel
   if pArray is not an array then return pArray
   if pLevel is empty then put 0 into pLevel
   
   put keys(pArray) into tkeys
   sort lines of tKeys
   repeat for each line k in tKeys
      repeat pLevel
         put "   " after tDisplay
      end repeat
      if pArray[k] is an array then
         put k && "=>" & cr & showArray(pArray[k], pLevel + 1) & cr after tDisplay
      else
         put k && "=>" && pArray[k] & cr after tDisplay
      end if
   end repeat
   replace cr & cr & cr with cr & cr in tDisplay
   return tDisplay
end showArray
