Script "stack_hash_tests_button_id_1007"

/*
# Name: button "FIPS sha1 test vectors" of card "Hash Tests" of stack "hash tests"
# ID: button id 1007 of card id 1002 of stack "hash tests"
*/


--> all handlers

on mouseUp
   put empty into fld "res"
   put empty into fld "info"
   put 0 into failures
   set cursor to watch
    
   put the number of lines in the customKeys["FIPSsha1TestVectors"] of this stack / 2 into numVectors
   repeat with n = 1 to numVectors
      put the millisecs into tt
      put sha1.hex(the FIPSsha1TestVectors[n,"msg"] of this stack) into revDig
      add the millisecs - tt to tTotalMs
      put the FIPSsha1TestVectors[n,"md"] of this stack into testDig
      
      put length(the FIPSsha1TestVectors[n,"msg"] of this stack) into tLen
      add tLen to tTotalBytes
       
      put n & ":" && tLen && "bytes" & cr & "calc:" && revDig & cr & "fips:" && testDig & cr after tList
      if (revDig is testDig) then
         put "passed" & cr & cr after tList
      else
         put "failed" & cr & cr after tList
         add 1 to failures
      end if
       
      put n  && "of" && numVectors into fld "info"
      wait 1 millisec
      if the optionkey is down then exit repeat
   end repeat
    
   put tList into fld "info"
    
   delete char 1 of timeList
   put "FIPS sha-1 testvectors" & cr into dList
   put "total time:" && round(tTotalMs / 1000, 3) && "secs" & cr after dList
   put "total size:" && tTotalBytes && "bytes" & cr after dList
   put "rate:" && round(tTotalbytes / tTotalMs * 1000) && "bytes/sec" & cr after dList
   put "failures:" && failures after dList
   put dList into fld "res"
end mouseUp
