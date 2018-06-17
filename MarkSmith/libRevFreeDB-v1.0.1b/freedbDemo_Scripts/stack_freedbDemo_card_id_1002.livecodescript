Script "stack_freedbDemo_card_id_1002"

/*
# Name: card id 1002 of stack "freedbDemo"
# ID: card id 1002 of stack "freedbDemo"
*/


--> all handlers

on preopenstack
   initStack
end preopenstack

on closeStackRequest
   lock screen
   
   if the environment is "Development" then save this stack
   pass closeStackRequest
end closeStackRequest

on initStack
   if "libRevFreeDb" is not among the lines of the stacksinuse then start using stack "libRevFreeDb"
   stopTrack
   put empty into fld "header"
   put empty into fld "tracklist"
   hide btn "playersp"
   set the filename of player "p1" to empty
   put "drag a cd onto me" into fld "info"
   show fld "info"
end initStack

on ejectDisc pCDpath
   initStack
   switch the platform
      case "MacOS"
         set the itemdelimiter to "/"
         put item -1 of pCDpath into tDiscName
         put the ejectAS of this stack into tScr
         replace "!DISC!" with q(tDiscName) in tScr
         do tScr as applescript
         if the result is empty then return the result
         break
      case "Win32"
         get mcisendstring("set cdaudio door open")
         if it is not empty then return it
         break
   end switch
end ejectDisc

on dragEnter
   set the acceptdrop to true
end dragEnter

on dragdrop
  doCD the dragdata
end dragdrop


on doCD pCDpath
   set the cdPath of this stack to pCDpath
   put empty into fld "header"
   put empty into fld "tracklist"
   stopTrack
   set the filename of player "p1" to empty
   hide btn "playersp"
   
   put "getting cd data from freedb..." into fld "info"
   show fld "info"
   put getCDdata(pCDpath) into tArray
   if "error" is in tArray then
      put tArray into tHead
   else if tArray["cddb"] is not "ok" then
      put "freedb:" & tab & tArray["nummatches"] && tArray["cddb"] into tHead
      repeat with n = 1 to tArray["nummatches"]
         put showArray(tArray[n]) & cr after tList
      end repeat
   else
      put "CD:" & tab & tArray["album"] & cr into tHead
      put "Artist:" & tab & tArray["artist"] after tHead
      get tArray["year"]
      if it is not empty then put cr & "Year:" & tab & it after tHead
       
      repeat with n = 1 to the number of lines in keys(tArray["cdpaths"])
         put format("%02s",n) & ":" & tab & tArray["tracks"][n] & cr after tList
         put tArray["cdpaths"][n] into tLinks[tArray["tracks"][n]]
      end repeat
      delete char -1 of tList
      set the customproperties["links"] of this stack to tLinks
   end if
   put tHead into fld "header"
   put tList into fld "tracklist"
   hide fld "info"
end doCD

-----

local sPlaying = false

function isPlaying
   return sPlaying
end isPlaying

on playTrack tTrack
   put the links[tTrack] of this stack into tFile
   if there is no file tFile then exit to top
   stop player "p1"
   set the filename of player "p1" to empty
   set the filename of player "p1" to tFile
   start player "p1"
   set the label of btn "playersp" to "="
   put true into sPlaying
end playTrack

on startTrack
   start player "p1"
   set the label of btn "playersp" to "="
   put true into sPlaying
end startTrack

on stopTrack
   stop player "p1"
   set the label of btn "playersp" to ">"
   put false into sPlaying
end stopTrack



