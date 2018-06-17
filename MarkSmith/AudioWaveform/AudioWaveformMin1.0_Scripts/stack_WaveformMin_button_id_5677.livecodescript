Script "stack_WaveformMin_button_id_5677"

/*
# Name: button "Snapshot" of card id 1002 of stack "WaveformMin"
# ID: button id 5677 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  ask file "Name..."
  if it is empty then exit to top
  put it into fName
  
  put the windowID of this stack into wID
  put the rect of grp "AudioWaveform" into cRect
  export snapshot from rect cRect of window wID to file fName as PNG
end mouseUp
