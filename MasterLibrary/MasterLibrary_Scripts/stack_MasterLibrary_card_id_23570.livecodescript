Script "stack_MasterLibrary_card_id_23570"

/*
# Name: card "Testing Playground" of stack "MasterLibrary"
# ID: card id 23570 of stack "MasterLibrary"
*/


on mouseup
   put the short name of the target into jump
   switch jump
      case "Test"
         doit
         break
   end switch
end mouseup

/*
g    Global variable                                       gMyGlobal
t    Local ("temporary") variable                    tMyVar
s    Script-local var                                       sMyVar
p    Parameter                                              pMyParam
k    Constant                                                 kMyNumber
u    User-defined (or custom) properties      uMyProp
*/

-- begin xxx
-- end xxx
/* xxx yyy
Syntax:
Examples:
Description:
Source:
xxx */
/* Include
*/


-- °

on doit
   alex
end doit

/*
Pass a string, a modelist and a custom list. This will act as a simple regex character filter for any string 
you pass it. (Great for filtering out hidden/non-printing characters!) If you only pass it a string and no 
arguements, it will return uppercase, lowercase, numbers and spaces. 

The modelist can be any items in "tabs,newlines,returns,spaces,numbers,lowercase,uppercase,symbols,custom". 
If the modelist contains "custom" then pass any other characters you want to include in pCustomList. 
*/


function cleanASCII pString, pModeList, pCustomChars
   if pModeList is empty then
      put " 0-9a-zA-Z" into tAllowedChars
   end if
   
   repeat for each item pMode in pModeList
      switch
         case "tabs" is in pMode
            put "\t" after tAllowedChars
            break
         case "newlines" is in pMode
            put "\n" after tAllowedChars
            break
         case "returns" is in pMode
            put "\r" after tAllowedChars
            break
         case "spaces" is in pMode
            put " " after tAllowedChars
            break
         case "numbers" is in pMode
            put "0-9" after tAllowedChars
            break
         case "lowercase" is in pMode
            put "a-z" after tAllowedChars
            break
         case "uppercase" is in pMode
            put "A-Z" after tAllowedChars
            break
         case "symbols" is in pMode
            put "!#$%&'()*+,./:;<=>?@[\\_`{|}~^-" after tAllowedChars
            break
         case pMode is "custom"
            put pCustomChars after tAllowedChars
            break
      end switch
   end repeat
   
   put "[" & tAllowedChars & "]" into tMatchText
   
   repeat for each character theChar in pString
      if matchtext(theChar, tMatchText) is true then
         put theChar after cleanString
      end if
   end repeat
   
   return cleanString
end cleanASCII

--------

## Commented for occasional readers.
## You still has to use the locations for a numbers display: Use either
## one num-field per line or one for all using Alex's method of space below.

local rg="TEXT", l0, t0, b0, v0
local gpoints -- collects the toplefts of the lines

on updateNbs2
  put the millisecs into m1
  lock screen; lock messages
  put the top of fld rg into t0
  put the left of fld rg into l0
  put the bottom of fld rg into b0
  put the height of fld rg into h0
  put the selectedChunk into sc
  put the vscroll of fld rg into v0
  put the num of lines of fld rg into nL
  put visibleTextLines(nL) into tL
  put "Lines: " & tL & " of " & nL into fld "range"
  put gPoints into fld "info" -- ready to use
  -- avoid bug(?) with the field num:
  if sc is not empty then
    do ("select "& (word 1 to 4 of sc) &" of fld "&quote& rg &quote)
  end if
  set the vscroll of fld rg to v0
  put (the millisecs-m1) & " ms" into fld "timing"
  unlock screen; unlock messages
end updateNbs2

-- returns the visible lines range and (in gPoints) the toplefts
-- n is the num of lines
function visibleTextLines n
  put the scrollbarWidth of fld rg into sw
  put the margins of fld rg into m
  put (m,m,m,m) into m -- now we have always at least 4 items
  put findTopLine(v0+t0-1+item 2 of m,1,n) into L1
  put L1-1 into L2; put v0+b0+6-item 4 of m into x
  put empty into gPoints
  -- now a simple line-after-line check could/should be made faster,
  -- its advantage: We get at the same time already the locations!
  repeat while L2 <= n
    add 1 to L2
    set vscroll of fld rg to v0 -- important for measuring
    select before line L2 of fld rg
    put item 2 of the selectedLoc into slc
    put cr & (l0,slc) after gPoints -- adjust here the left
    if (the vscroll of fld rg) + slc > x then
      put line 2 to -2 of gPoints into gPoints
      exit repeat
    end if
  end repeat
  return L1,L2-1
end visibleTextLines

-- the simplest recursive method as base for optimization
function findTopLine x,n1,n -- x=top pixel value, n1=start, n=max
  put n1+((n-n1) div 2) into m
  set vscroll of fld rg to v0
  select before line m+1 of fld rg
  put the vscroll of fld rg + item 2 of the selectedLoc into vsl
  if vsl >= x then
    set vscroll of fld rg to v0
    select before line m of fld rg
    put the vscroll of fld rg + item 2 of the selectedLoc into vsl
    if vsl < x then return word 2 of the selectedLine
    else
      if m <= n1 then return n1
      else return findTopLine(x,n1,m-1)
    end if
  else
    if m >= n then return n
    else return findTopLine(x,m+1,n)
  end if
end findTopLine

## The field's script is again:
on textchanged
  updateNbs2
end textchanged

on scrollbardrag
  updateNbs2
end scrollbardrag
### END_OF_SCRIPT


function quickenDate what
   /*
   Returns current date if sent an empty string
   Returns empty if can't figure out what "what" is supposed to be
   
   Delimiter can be ".", "/", ";", <SP> or comma
   Date can be in m/d/y, m/d, or just d format
   Also accepts (upper or lower case)
   T - (T)oday
   M - First day of (M)onth
   H - Last day of mont(H)
   W - First day of (W)eek
   K - Last day of wee(K)
   Y - First day of (Y)ear
   R - Last day of yea(R)
   + - tomorrow
   +x, where x is an integer, x days from today
   - - yesterday
   -x where x is an integer, x days before today
   
   Mike Kerner <MikeKerner@roadrunner.com>
   */
   
   if what is empty then return the short date # you got a better idea?
   
   put the short date into currentDateInDateItems
   convert currentDateInDateItems to dateItems #y,m,d,h(24format),m,s,daynum (0 sun, 6 sat)
   put item 1 of currentDateInDateItems into currentYear
   put item 2 of currentDateInDateItems into currentMonth
   
   if what = "T" then #today
      put the short date into what
   else if what = "Y" then #first day of year
      put "01/01/" & currentYear into what
   else if what = "R" then #last day of year
      put "12/31/" & currentYear into what
   else if what = "M"  then # first of month
      put currentMonth & slash & "01" & slash & currentYear into what
   else if what = "H" then # last day of month
      if currentMonth is 12 then
         put "12/31/" & currentYear into what
      else #not 12, # the easiest way to do this math is to get midnight on the first day of the following 
         # month and then move back a second and let LC do the math on what the date is
         # since otherwise we have to figure out the 30 days have september, blah, blah, blah, and leap years, blah, blah, blah.
         add 1 to item 2 of currentDateInDateItems #next month
         put "0" into item 3 of currentDateInDateItems #I love dateItems. 
         # How to figure out the last day of this month?  
         # Go to first day of next month and subtract 1, (making it a 0, e.g. 5/0/17 is 4/30/17)
         put currentDateInDateItems into what
      end if #currentMonth is 12
   else if what is "W" then #first day of week #sunday is first day of week
      put last item of currentDateInDateItems into dayNumber
      subtract (dayNumber-1) from item 3 of currentDateInDateItems
      put currentDateInDateItems into what
   else if what is "K" then #last day of week #saturday is last day of week
      put last item of currentDateInDateItems into dayNumber
      add (7-dayNumber) to item 3 of currentDateInDateItems
      put currentDateInDateItems into what
      convert what to short date
   else if first char of what is "+" then #at least tomorrow, but if a nuber follows, then x days after today
      delete first char of what # "+"
      if what is empty then put 1 into what #"+" is tomorrow, i.e. +1
      add what to item 3 of currentDateInDateItems
      put currentDateInDateItems into what
   else if first char of what is "-" then # at least yesterday, or if a number follows, then x days before today
      delete first char of what #"-"
      if what is empty then put 1 into what #"-" is yesterday, i.e. -1
      subtract what from item 3 of currentDateInDateItems
      put currentDateInDateItems into what
   else # a date-ish string could be a date only or a month and a date, or a month and a date and a year
      #<determine the delimiter, if there is one.  It could be a comma, aslash, a period, or a space>
      if what contains ";" then replace ";" with slash in what
      if what contains space then replace space with slash in what
      if what contains "." then replace "." with slash in what
      if what contains comma then replace comma with slash in what
      # and, if what doesn't contain any of those, comma will be the delimiter
      #</determine the delimiter, if there is one.  It could be a comma, a slash, a period, or a space>
      
      set the itemDelimiter to slash
      
      #<date format can be D, M/D, or M/D/Y, so test and add>
      if the number of items in what is not 3 then put slash&currentYear after what   # try adding a year, first
      if the number of items in what is not 3 then put currentMonth&slash before what # try adding the month, next
      #</date format can be D, M/D, or M/D/Y, so test and add>
      
      if what is not a date then put empty into what #error
   end if #what="T"
   
   convert what to short date
   return what
end quickenDate
