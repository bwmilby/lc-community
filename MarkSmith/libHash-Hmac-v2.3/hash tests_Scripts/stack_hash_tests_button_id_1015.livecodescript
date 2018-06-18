Script "stack_hash_tests_button_id_1015"

/*
# Name: button "test sha1 against openssl" of card "Hash Tests" of stack "hash tests"
# ID: button id 1015 of card id 1002 of stack "hash tests"
*/


--> all handlers

local sStr

on mouseUp
   set cursor to watch
   put empty into fld "res"
   put empty into fld "info"
   put empty into sStr
   put 0 into tFailures
   put the tempname into tFile
   put 0 into n
   repeat while n <= 200000
      wait 0 millisecs
      put n into fld "info"
      add n to totalbytes
      makeStr n
       
      put sStr into url ("binfile:" & tFile)
       
      put the millisecs into ts
      put sha1.hex(tFile, true) into tRevDig
      add (the millisecs - ts) to totalRevMs
      
      
      put the millisecs into ts
      put word -1 of shell("openssl sha1" && q(tFile)) into tOslDig
      --put fileSha1.hex(tFile) into tOslDig
      add (the millisecs - ts) to totalOslMs
       
      put "length:" && n & cr & "rev :" && tRevDig & cr & "ossl:" && tOslDig & cr after tList
      if (tRevDig = tOslDig) then
         put "passed" & cr & cr after tList
      else
         put "failed" & cr & cr after tList
         add 1 to tFailures
      end if
       
      
      if n = 0 then
         put 7 into n
      else
         multiply n by 2
      end if
   end repeat
   
   delete file tFile
   put tList into fld "info"
   
   put "test rev sha-1 against openssl sha-1" & cr into dList
   put "total size:" && totalbytes & cr after dList
   put "Rev speed:" && round(totalbytes / totalRevMs * 1000) && "bytes/sec" & cr after dList
   put "Osl speed:" && round(totalbytes / totalOslMs * 1000) && "bytes/sec" & cr after dList
   put "failures:" && tFailures after dList
   put dList into fld "res"
end mouseUp

on makeStr pNum
   repeat pNum - length(sStr)
      put numtobyte(random(255)) after sStr
   end repeat
end makeStr

private function q pStr
   return quote & pStr & quote
end q

