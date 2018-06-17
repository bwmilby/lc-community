Script "stack_UUID_Demo_group_id_1003"

/*
# Name: group id 1003 of card id 1002 of stack "UUID Demo"
# ID: group id 1003 of card id 1002 of stack "UUID Demo"
*/


--> all handlers

on grabUUID pUUID
  put pUUID into fld "info"
  set the clipboardData to pUUID
end grabUUID
