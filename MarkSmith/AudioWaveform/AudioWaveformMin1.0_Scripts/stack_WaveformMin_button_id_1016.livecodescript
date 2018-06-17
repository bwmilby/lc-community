Script "stack_WaveformMin_button_id_1016"

/*
# Name: button "Choose File" of card id 1002 of stack "WaveformMin"
# ID: button id 1016 of card id 1002 of stack "WaveformMin"
*/


on mouseUp
  answer file "Choose.."
  if it is empty then exit to top
  set cursor to watch
  set the uFile of grp "AudioWaveform" to it
  send "showFileInfo" to me in 1 second
end mouseUp

on showFileInfo
  --  put the customProperties["FileInfo"] of grp "AudioWaveform" into tFileInfoA
  --  
  --  put "File: " & tFileInfoA["FileName"] & cr into tList
  --  put "Type: " & tFileInfoA["FileType"] & cr after tList
  --  put "Duration: " & tFileInfoA["FileDuration"] && "seconds" & cr after tList
  --  put "Channels: " & tFileInfoA["NumChannels"] & cr after tList
  --  put "Sample frames: " & tFileInfoA["NumSampleFrames"] & cr after tList
  --  put "Sample rate: " & tFileInfoA["SampleRate"] & cr after tList
  --  put "Sample size: " & tFileInfoA["SampleSize"] after tList
  --  put tList into fld "info"
  put the uFileInfo of grp "AudioWaveform" into fld "info"
end showFileInfo
