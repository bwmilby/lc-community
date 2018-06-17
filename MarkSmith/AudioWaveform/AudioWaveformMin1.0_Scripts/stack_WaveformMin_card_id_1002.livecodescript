Script "stack_WaveformMin_card_id_1002"

/*
# Name: card id 1002 of stack "WaveformMin"
# ID: card id 1002 of stack "WaveformMin"
*/



on resizeStack
  send "resizeControl" to grp "AudioWaveform" in 10 millisecs
  pass resizeStack
end resizeStack
