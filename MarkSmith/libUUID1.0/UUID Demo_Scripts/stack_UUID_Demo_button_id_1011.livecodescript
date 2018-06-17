Script "stack_UUID_Demo_button_id_1011"

/*
# Name: button "?" of card id 1002 of stack "UUID Demo"
# ID: button id 1011 of card id 1002 of stack "UUID Demo"
*/


on mouseUp
  put the top of this stack into tTop
  lock screen
  if the height of this stack > 175 then
    set the height of this stack to 175
  else
    set the height of this stack to 500
  end if
  set the top of this stack to tTop
  unlock screen
end mouseUp
