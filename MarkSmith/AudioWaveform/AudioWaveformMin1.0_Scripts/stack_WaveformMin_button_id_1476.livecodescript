Script "stack_WaveformMin_button_id_1476"

/*
# Name: button "Set waveform color" of card id 1002 of stack "WaveformMin"
# ID: button id 1476 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  answer color with the uWaveShade of grp "AudioWaveform"
  if it is empty then exit to top
  set the uWaveShade of grp "AudioWaveform" to it
end mouseUp
