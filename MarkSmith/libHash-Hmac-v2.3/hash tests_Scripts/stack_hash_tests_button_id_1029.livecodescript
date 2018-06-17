Script "stack_hash_tests_button_id_1029"

/*
# Name: button "sha-224/256 fips ex." of card "Hash Tests" of stack "hash tests"
# ID: button id 1029 of card id 1002 of stack "hash tests"
*/


--> all handlers

on mouseUp
   set cursor to watch
   put arraydecode(the sha2fipstests of this stack) into tTests
   put 0 into failures
   
   repeat with n = 1 to 2
      add length(tTests[n]["m"]) to tTotalBytes
      put the millisecs into ts
      put sha224.hex(tTests[n]["m"]) into tDigest
      add the millisecs - ts to tTotalMs
      if tDigest = tTests[n][224] then
         put "passed" into tRes
      else
         put "failed" into tRes
         add 1 to failures
      end if
       
      put n & ": sha-224:" & cr & "calc:" && tDigest & cr & "fips:" && tTests[n][224] & cr & tRes & cr & cr after tList
      
      put the millisecs into ts
      put sha256.hex(tTests[n]["m"]) into tDigest
      add the millisecs - ts to tTotalMs
      if tDigest = tTests[n][256] then
         put "passed" into tRes
      else
         put "failed" into tRes
         add 1 to failures
      end if
       
      put n & ": sha-256:" & cr & "calc:" && tDigest & cr & "fips:" && tTests[n][256] & cr & tRes & cr & cr after tList
      
      put "--------------------------------------" & cr & cr after tList
       
   end repeat
   
   put tList into fld "info"
   
   put "sha-224/256 fips tests" & cr into dList
   put "total time:" && round(tTotalMs / 1000, 3) && "secs" & cr after dList
   put "total size:" && tTotalBytes && "bytes" & cr after dList
   put "rate:" && round(tTotalBytes / tTotalMs * 1000) && "bytes/sec" & cr after dList
   put "failures:" && failures after dList
   put dList into fld "res"
   
end mouseUp
