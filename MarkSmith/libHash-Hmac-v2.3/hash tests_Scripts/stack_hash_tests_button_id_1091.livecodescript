Script "stack_hash_tests_button_id_1091"

/*
# Name: button "Button" of card "Hash Tests" of stack "hash tests"
# ID: button id 1091 of card id 1002 of stack "hash tests"
*/


--> all handlers

on mouseUp
   put "marksmith" into s1
   put "marksmitj" into s2
    
   put fnv132.hex(s1) into h1
   put fnv132.hex(s2) into h2
    
   put h1 && h2
end mouseUp
