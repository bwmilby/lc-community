Script "stack_WaveformMin_group_id_1241"

/*
# Name: group id 1241 of card id 1002 of stack "WaveformMin"
# ID: group id 1241 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  set cursor to watch
  if the hilite of btn "Average all channels" then
    set the uDisplayType of grp "AudioWaveform" to 1
  else
    set the uDisplayType of grp "AudioWaveform" to 2
  end if
  
end mouseUp
