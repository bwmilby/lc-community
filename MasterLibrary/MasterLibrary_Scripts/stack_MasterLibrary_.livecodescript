Script "stack_MasterLibrary_"

/*
# Name: stack "MasterLibrary"
# ID: stack "MasterLibrary"
*/


global skip
 
on saveStackRequest 
   call "saveStackVersion" of btn "Lib" of cd "LibMgr"
   pass saveStackRequest -- or the stack won't be save
end saveStackRequest

on preopenstack
      send "Mark_IDE_done" to me in 2 ticks
      go to cd "Splash"
end preopenstack

on Mark_IDE_done
   try 
      get revloadedstacks()
   catch err
      send "Mark_IDE_done" to me in 2 ticks
      exit to top
   end try
   go to cd "LibMgr"
end Mark_IDE_done

on openstack
   put true into skip
   if WeAreCurrent() then 
       set the default of btn "Version" of cd "LibMgr" of stack "MasterLibrary" to false
    else
       set the default of btn "Version" of cd "LibMgr" of stack "MasterLibrary" to true
    end if
    insert the script of btn "Front" of cd "LibMgr" of stack "MasterLibrary" into front
end openstack

function WeAreCurrent
   dispatch function "__isConnectedToInternet" to btn "Lib" of cd "LibMgr" of stack "MasterLibrary" with empty, "Yes"
   put "https://dl.dropbox.com/s/4uawi24k2gdwa3q/MasterLibrary.txt"  into cVersion
   put "https://dl.dropbox.com/s/3wpwn3hfbmpl7sk/MasterLibrary.livecode" into cNewStack
   Put the effective filename of this stack into pStackPath
   put the label of btn "Version" of cd "LibMgr" of stack "MasterLibrary" into myVer
   put URL cVersion into newVer
   if word 2 myVer < word 1 of newVer then
      return newVer , cNewStack
   else
      return true
   end if
end WeAreCurrent



on resumeStack
   if IDE_Done then send "getOtherStacks" to card "LibMgr" of stack "MasterLibrary"
end resumeStack

on commandkeyDown pKey 
   switch pKey 
     case "x" 
       cut 
       break 
     case "v" 
       paste 
       break 
     case "c" 
       copy 
       break 
     case "z" 
       undo 
       break 
     default 
       pass commandKeyDown 
   end switch 
end commandkeyDown

-- Library Routines Below
