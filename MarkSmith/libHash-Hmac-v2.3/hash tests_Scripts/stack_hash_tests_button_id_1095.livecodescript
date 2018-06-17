Script "stack_hash_tests_button_id_1095"

/*
# Name: button "Button" of card "hash-hmac" of stack "hash tests"
# ID: button id 1095 of card id 1036 of stack "hash tests"
*/


--> all handlers

on mouseUp
   put "markymarkymarky" into tStr
   
   put the millisecs into ts
   repeat 10000
      put md5digest(tStr) into tm
   end repeat
   put the millisecs - ts into t1
   
   put the millisecs into ts
   repeat 10000
      put fnv132.bin(tStr) into tf
   end repeat
   put the millisecs - ts into t2
   put t1 && t2
end mouseUp
