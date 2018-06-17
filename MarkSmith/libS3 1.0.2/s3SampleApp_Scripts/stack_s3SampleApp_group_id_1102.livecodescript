Script "stack_s3SampleApp_group_id_1102"

/*
# Name: group "p1" of card id 1002 of stack "s3SampleApp"
# ID: group id 1102 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

##############################
# DO NOT DELETE THIS SCRIPT --
# THE GAUGE WILL FAIL TO OPERATE
##############################

on tmUpdateGauge t1, t2, tValue
  put min(max(0,tValue),99) into V
  if tValue < 10 then put "0" before V
  repeat with D = 1 to 2
    put value("the tmDigitData" & char D of V && "of me") into tData
    put tData into img ("tmDigit" & D) of me
  end repeat
  put the points of grc tmGaugeTickBase of me into P
  set the points of grc tmGaugeTicks of me to line 1 to (V + 0) of P
end tmUpdateGauge
