Script "stack_hash_tests_button_id_1086"

/*
# Name: button "Option Menu" of bkgnd "nav" of stack "hash tests"
# ID: button id 1086 of bkgnd id 1089 of stack "hash tests"
*/


--> all handlers

on menuPick pChosen
    go cd pChosen
    set the label of this stack to pChosen
end menuPick
