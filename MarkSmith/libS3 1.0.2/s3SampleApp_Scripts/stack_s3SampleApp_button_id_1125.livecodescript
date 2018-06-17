Script "stack_s3SampleApp_button_id_1125"

/*
# Name: button "timeLimitUrls" of group "ContentsDisplay" of card id 1002 of stack "s3SampleApp"
# ID: button id 1125 of group id 1054 of card id 1002 of stack "s3SampleApp"
*/


--> all handlers

on mouseUp
   put line (the hilitedline of fld "bucketList") of fld "bucketList"  into tBucket
    
   put the seconds + (60 * 60 * 24 * 7) into tExpiry -- this is one week from now
   put s3.timeLimitUrls(tBucket, tExpiry)
end mouseUp

