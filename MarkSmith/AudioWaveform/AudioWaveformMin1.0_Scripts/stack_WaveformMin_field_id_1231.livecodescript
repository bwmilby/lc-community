Script "stack_WaveformMin_field_id_1231"

/*
# Name: field "Ms/Pt" of card id 1002 of stack "WaveformMin"
# ID: field id 1231 of card id 1002 of stack "WaveformMin"
*/


on enterInField
  setMP
end enterInField

on returnInField
  setMP
end returnInField

on setMP
  set cursor to watch
  set the uMillisecsPerPoint of grp "AudioWaveform" to me
  send "reload" to grp "audioWaveform"
end setMP
