Script "stack_libBinConvert_card_id_1002"

/*
# Name: card id 1002 of stack "libBinConvert"
# ID: card id 1002 of stack "libBinConvert"
*/


--> all handlers

on openStack
  if the target is me then initLibBin
  pass openStack
end openStack
