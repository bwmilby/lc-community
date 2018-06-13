Script "stack_MasterLibrary_button_id_23725"

/*
# Name: button "Front" of card "LibMgr" of stack "MasterLibrary"
# ID: button id 23725 of card id 23690 of stack "MasterLibrary"
*/


on seSetObjectState objRef, objState
   if objRef is empty then pass seSetObjectState
   put the long id of objRef into t1
   put the long id of btn "Lib" of cd "LibMgr" of stack "MasterLibrary" into t2
   if t1 = t2 and objState = "applied" then
      send "updateMasterIndex" to cd "LibMgr" of stack "MasterLibrary" in 1 ticks
   end if
   pass seSetObjectState
end seSetObjectState

