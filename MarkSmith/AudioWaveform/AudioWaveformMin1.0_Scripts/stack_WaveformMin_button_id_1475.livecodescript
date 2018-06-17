Script "stack_WaveformMin_button_id_1475"

/*
# Name: button "Set background color" of card id 1002 of stack "WaveformMin"
# ID: button id 1475 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  answer color with the uBGshade of grp "AudioWaveform"
  if it is empty then exit to top
  set the uBGshade of grp "AudioWaveform" to it
end mouseUp
