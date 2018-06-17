Script "stack_freedbDemo_"

/*
# Name: stack "freedbDemo"
# ID: stack "freedbDemo"
*/


--> all handlers

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
