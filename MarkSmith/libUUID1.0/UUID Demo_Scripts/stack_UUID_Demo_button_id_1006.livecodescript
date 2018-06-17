Script "stack_UUID_Demo_button_id_1006"

/*
# Name: button "Name-based UUID" of group id 1003 of card id 1002 of stack "UUID Demo"
# ID: button id 1006 of group id 1003 of card id 1002 of stack "UUID Demo"
*/


on mouseUp
  ask "Choose a namespace and a name, separated by a comma..." with "URL,www.google.com"
  if it is empty then exit to top
  put item 1 of it into tNS
  put item 2 of it into tName
  
  grabUUID luiNameUUID(tNS,tName)
end mouseUp
