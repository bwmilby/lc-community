Script "stack_WaveformMin_button_id_5669"

/*
# Name: button "uRIP menu" of card id 1002 of stack "WaveformMin"
# ID: button id 5669 of card id 1002 of stack "WaveformMin"
*/


on mouseDown
  put the customKeys["uRip"] of grp "AudioWaveform" into me
end mouseDown

on menuPick which
  put the uRIP[which] of grp "AudioWaveform" into content
  put "uRIP[" & which & "]" & cr & cr before content
  put content into fld "tf" of stack "uRIPprops"
  palette stack "uRIPprops"
end menuPick
