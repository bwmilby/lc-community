Script "stack_hash_tests_button_id_1027"

/*
# Name: button "hmac sha224/256 rfc 4231" of card "Hash Tests" of stack "hash tests"
# ID: button id 1027 of card id 1002 of stack "hash tests"
*/


--> all handlers

on mouseUp
   set cursor to watch
   put arraydecode(the hmac256tests of this stack) into tTests
   put 0 into failures
   
   put the millisecs into ts
   repeat with n = 1 to 7
       
      put hmacSha224.hex(tTests[n]["d"], tTests[n]["k"]) into tHmac
      if n = 5 then delete byte 33 to -1 of tHmac
      if tHmac = tTests[n][224] then
         put "passed" into tRes
      else
         put "failed" into tRes
         add 1 to failures
      end if
       
      put n & ": hmacSha224:" & cr & "calc:" && tHmac & cr & "rfc :" && tTests[n][224] & cr & tRes & cr & cr after tList
       
      put hmacSha256.hex(tTests[n]["d"], tTests[n]["k"]) into tHmac
      if n = 5 then delete byte 33 to -1 of tHmac
      if tHmac = tTests[n][256] then
         put "passed" into tRes
      else
         put "failed" into tRes
         add 1 to failures
      end if
       
      put n & ": hmacSha256:" & cr & "calc:" && tHmac & cr & "rfc :" && tTests[n][256] & cr & tRes & cr & cr after tList
      
      put "-------------------------------------------" & cr & cr after tList
   end repeat
   put the millisecs - ts into tMs
   
   put tList into fld "info"
   
   put "hmac sha 224/256 rfc 4231 results" & cr into dList
   put "time taken:" && round(tMs / 1000, 3) && "secs" & cr after dList
   put "failures:" && failures after dList
   put dList into fld "res"
end mouseUp
