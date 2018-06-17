Script "stack_hash_tests_button_id_1035"

/*
# Name: button "sha-1/256 speed tests" of card "Hash Tests" of stack "hash tests"
# ID: button id 1035 of card id 1002 of stack "hash tests"
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
   repeat while n <= 60000
      put n into fld "info"
      wait 0 millisecs
      add n to totalbytes
      makeStr n
       
      put sStr into url ("binfile:" & tFile)
       
      put the millisecs into ts
      put sha1.hex(tFile, true) into tSha1
      put the millisecs - ts into t1Ms
      add t1Ms to totalSha1Ms
      
      put the millisecs into ts
      put sha256.hex(tFile, true) into tSha2
      put the millisecs - ts into t2Ms
      add t2Ms to totalSha2Ms
       
      put "size:" & n & "   " & "sha1:" & t1Ms & "ms   " & "sha256:" & t2Ms & "ms" & cr after tList
      put "sha-1  :" && tSha1 & cr & "sha-256:" && tSha2 & cr & cr after tList
      
      
      if n = 0 then
         put 7 into n
      else
         multiply n by 2
      end if
   end repeat
   
   delete file tFile
   put tList into fld "info"
   
   put "sha-1/256 speed tests" & cr into dList
   put "total size:" && totalbytes & cr after dList
   put "Sha-1 speed  :" && round(totalbytes / totalSha1Ms * 1000) && "bytes/sec" & cr after dList
   put "Sha-256 speed:" && round(totalbytes / totalSha2Ms * 1000) && "bytes/sec" & cr after dList
   put dList into fld "res"
end mouseUp

on makeStr pNum
   repeat pNum - length(sStr)
      put numtobyte(random(255)) after sStr
   end repeat
end makeStr
