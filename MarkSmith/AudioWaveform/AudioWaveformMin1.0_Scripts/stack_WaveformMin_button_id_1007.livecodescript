Script "stack_WaveformMin_button_id_1007"

/*
# Name: button "show timing" of card id 1002 of stack "WaveformMin"
# ID: button id 1007 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  set cursor to watch
  set the uMillisecsPerPoint of grp "AudioWaveform" to fld "Ms/Pt"
  
  put the millisecs into st
  send "checkFile" to grp "AudioWaveform"
  put the millisecs - st into checkFileTime
  
  
  put the millisecs into st
  send "getSamples" to grp "AudioWaveform"
  put the millisecs - st into getSampleTime
  
  put the millisecs into st
  send "showWaveform" to grp "AudioWaveform"
  put the millisecs - st into showWaveformTime
  
  put "Time to check the file: " & checkFileTime & "ms." & cr \
      & "Time time to read the file: " & getSampleTime & "ms." & cr \
      & "Time to draw the waveform: " & showWaveformTime & "ms."
end mouseUp
