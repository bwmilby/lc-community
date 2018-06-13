Script "stack_MasterLibrary_button_id_23674"

/*
# Name: button "Lib" of card "LibMgr" of stack "MasterLibrary"
# ID: button id 23674 of card id 23690 of stack "MasterLibrary"
*/


function earthKM myLat,myLon,Lat0,Lon0,@aid
   /* earthKM Geo
   Syntax:
   earthKM (myLat,myLon,Lat0,Lon0,@aid)
   Examples:
   put empty into aid
   earthKM (38.898556, -77.037852, 38.897147, -77.043934, aid)
   
   Description:
   Returns km distance on earth between two lat,long points
   and loads the bearing in degrees in the fifth parameter.  
   
   Note that the bearing is passed by reference so it must exist prior to calling the fuction
   
   Source:
   David Epstein
   earthKM */
   
   put PI/180 into rpd -- radians per degree
   put myLat*rpd into myLat
   put myLon*rpd into myLon
   put Lat0*rpd into Lat0
   put Lon0*rpd into lon0
   put (SIN((myLat-Lat0)/2))^2+COS(Lat0)*COS(myLat)*(SIN((myLon-Lon0)/2))^2 into j
   put 6371*2*ASIN(MIN(1,j^0.5)) into dkm -- distance in km
   put ATAN2(SIN(myLon-Lon0)*COS(myLat),COS(Lat0)*SIN(myLat)-SIN(Lat0)*COS(myLat)*COS(myLon-Lon0)) into k -- bearing in radians
   put k/rpd into aid -- in degrees
   return dkm
end earthKM

on saveStackVersion 
   /* saveStackVersion System
   Syntax:
   saveStackVersion   # Command #
   
   Examples:
   saveStackVersion
   
   Description:
   This code caused a version of the stack to be saved in a folder adjacent to the original
   in a folder called  "{stacknamegoeshere}_vers".  The stacks themselves will be
   named nbr_{stacknamegoeshere]
   
   This routine is normally called from within the saveStackRequest handler
   
   Source:
   Michael Doub
   saveStackVersion */
   
   put the defaultfolder into currentfolder 
   set itemDel to "/"
   set the defaultfolder to item 1 to -2 of (the effective fileName of this stack)
   put item -1 of the filename of this stack into fname 
   set itemdel to "."
   put item 1 of fname  & "_vers" into foldername
   if foldername is not among the lines of the folders then
      create folder foldername
   end if
   set the defaultfolder to (the defaultfolder & "/" & foldername)
   put the files into  tFileList
   if the number of lines in tFileList = 0 then
      put 0 into nVers
   else
      set itemdel to "_"
      sort tFileList numeric by item 1 of each
      put item 1 of the last line of tFileList +1 into nVers
   end if
   put URL ( "binfile:" & the effective fileName of this stack ) into URL ("binfile:" & nVers & "_" & fname)
   set the defaultfolder to currentfolder 
end saveStackVersion


-- begin libjson_var
local sJson
local sIndex
local sNumTokens
local sOutputUnicode = false
local sUnicodeInput = false
-- end libjson_var


function jsonVersion
   return "1.0.4b"
end jsonVersion




function jsonToArray pJson, asUnicode
   /* jsonToArray JSON
   Syntax:
   jsonToArray (pJson,[asUnicode])
   
   Examples:
   put jsonToArray (pJson)
   put jsonToArray (pJson,true)
   
   Description:
   Converts a JSON structure to an array
   
   Input:
   .   param pJson  - The json to convert.
   .   param asUnicode  - Pass in true to return everything as UTF-8.
   
   Output:
   .   Array or "error: json malformed" if error.
   
   Source: 
   Mark Smith, http://marksmith.on-rev.com/revstuff/files/libJson.zip
   jsonToArray */
   
   /* include
   libjson_var
   jsonToUtf8
   tokenizeJson
   jObjectToArray
   jArrayToArray
   */
   put asUnicode is true into sOutputUnicode
   put jsonToUtf8(pJson) into tJson
   if tJson begins with "libJson-error"then return tJson
   
   tokenizeJson tJson
   if the result is not empty then return the result
   
   if char 1 of pJson is "{" then
      put jObjectToArray() into tArray
   else
      put jArrayToArray() into tArray
   end if
   put empty into sJson
   return tArray
end jsonToArray

-----

private command tokenizeJson pJson
   put empty into sJson
   put 0 into sIndex
   put 0 into sNumTokens
   
   -- escaped quotes < \" > and reverse-solidus < \\ > will confuse the tokenizer
   -- so we replace them with "\u0022" and "\u005C" which we'll unescape
   -- with all the other unescapes when we parse - jsonDecode()
   
   replace "\\" with "\u005C" in pJson
   replace "\" & quote with "\u0022" in pJson
   
   put 0 into tDepth
   put empty into prevToken
   repeat for each token tToken in pJson
      if tToken is in "+-" then
         -- since "+" & "-" are rev tokens, but not json tokens,
         -- we have to prepend them to the next token
         put tToken into prevToken
      else
         add 1 to sNumTokens
         put prevToken & tToken into sJson[sNumTokens]
         put empty into prevToken
         
         if tToken is in "{[" then add 1 to tDepth
         if tToken is in "}]" then subtract 1 from tDepth
         
      end if
   end repeat
   
   if tDepth <> 0 then return "libJson-error: json malformed"
   repeat with n = 1 to sNumTokens - 1
      if (sJson[n] is not in "{}[],:") and (sJson[n + 1] is not in "{}[],:") then return "libJson-error: json malformed"
   end repeat
   
end tokenizeJson

-----

private function jObjectToArray
   /* include
   jsonDecode
   jObjectToArray
   */
   put empty into tArray
   
   repeat while sIndex < sNumTokens
      add 1 to sIndex
      
      switch sJson[sIndex]
         case "{"
            put jsonDecode(sJson[sIndex + 1]) into tName
            break
         case ":"
            if sJson[sIndex + 1] is not "{" then
               put jsonDecode(sJson[sIndex + 1]) into tArray[tName]
            else
               put jObjectToArray() into tArray[tName]
            end if
            break
         case "}"
            return tArray
            break
         case "["
            put jArrayToArray() into tArray[tName]
            break
         case comma --must be after "[" or will fuck up jArrays
            put jsonDecode(sJson[sIndex + 1]) into tName
            break
      end switch
      
   end repeat
   return tArray
end jObjectToArray

-----

private function jArrayToArray
   /* include
   jObjectToArray
   */
   put 0 into tKey
   put empty into tArray
   
   repeat while sIndex < sNumTokens
      add 1 to sIndex
      
      switch sJson[sIndex]
         case "]"
            return tArray
            break
         case comma
            next repeat
            break
         case "{"
            add 1 to tKey
            subtract 1 from sIndex
            put jObjectToArray() into tArray[tKey]
            break
         case "["
            add 1 to tKey
            put jArrayToArray() into tArray[tKey]
            break
         default
            add 1 to tKey
            put jsonDecode(sJson[sIndex]) into tArray[tKey]
      end switch
      
   end repeat
end jArrayToArray



function arrayToJson pArray, asUnicode
   /* arrayToJson JSON
   Syntax:
   arrayToJson (pJson,[asUnicode])
   
   Examples:
   put arrayToJson (pJson)
   put arrayToJson (pJson,true)
   
   Description:
   Converts a LiveCode array to json.
   
   Input:
   .    pArray  - The array to convert.
   .    asUnicode  - Pass in true if data in array is encoded as UTF-8.
   
   Output:
   .    JSON structure or "error: ..."
   
   Source: 
   Mark Smith, http://marksmith.on-rev.com/revstuff/files/libJson.zip
   arrayToJson */
   
   /* include
   arrayToJarray
   arrayToJobject
   */
   put asUnicode is true into sUnicodeInput
   
   if arrayKeysAreNumeric(pArray) then
      put arrayToJarray(pArray) into tJson
   else
      put arrayToJobject(pArray) into tJson
   end if
   
   return tJson
end arrayToJson

-----

private function arrayToJobject pArray
   /* include
   q
   jsonEncodeString
   arrayToJarray
   arrayToJobject
   jsonEncodeValue
   */
   put "{" into tJson
   
   put keys(pArray) into tKeys
   sort lines of tKeys
   repeat for each line k in tKeys
      put q(jsonEncodeString(k)) & ":" after tJson
      
      if pArray[k] is an array then
         
         if arrayKeysAreNumeric(pArray[k]) then
            put arrayToJarray(pArray[k]) & comma after tJson
         else
            put arrayToJobject(pArray[k]) & comma after tJson
         end if
         
      else
         
         put jsonEncodeValue(pArray[k]) & comma after tJson
         
      end if
   end repeat
   
   put "}" into char -1 of tJson
   
   return tJson
end arrayToJobject

-----

private function arrayToJarray pArray
   /* include
   arrayKeysAreNumeric
   arrayToJarray
   arrayToJobject
   jsonEncodeValue
   */
   put the keys of pArray into tKeys
   sort tKeys numeric
   put "[" into tJarray
   
   repeat for each line k in tKeys
      if pArray[k] is an array then
         if arrayKeysAreNumeric(pArray[k]) then
            put arrayToJarray(pArray[k]) & comma after tJarray
         else
            put arrayToJobject(pArray[k]) & comma after tJarray
         end if
      else
         put jsonEncodeValue(pArray[k]) & comma after tJarray
      end if
   end repeat
   put "]" into char -1 of tJarray
   return tJarray
end arrayToJarray

-----

private function arrayKeysAreNumeric pArray
   repeat for each key k in pArray
      if k is not an integer then return false
   end repeat
   return true
end arrayKeysAreNumeric



function jsonFormat pJson, pIndentSize
   /* jsonFormat JSON
   Syntax:
   jsonFormat (pJson,[pIndentSize])
   
   Examples:
   put jsonFormat (pJson)
   put jsonFormat (pJson,5)
   
   Description:
   Formats a JSON structure
   
   Input:
   .   pJson  - is the JSON structure
   .   pIndentSize - is the amount of indent, default is 3
   
   Output:
   .   Formated text (readable)
   
   Source: 
   Mark Smith, http://marksmith.on-rev.com/revstuff/files/libJson.zip
   
   jsonFormat */
   if pIndentSize is empty then put 3 into pIndentSize
   repeat pIndentSize
      put space after tIndent
   end repeat
   put 0 into tDepth
   put false into inString
   
   put empty into prevChar
   repeat for each char c in pJson
      if c is quote and prevChar is not "\" then put not Instring into inString
      if not inString then
         switch c
            case "{"
            case "["
               put c & cr after tFormatted
               add 1 to tDepth
               break
            case ":"
               put c & space after tFormatted
               break
            case "}"
            case "]"
               put c & cr after tFormatted
               subtract 1 from tDepth
               break
            case comma
               if prevChar is in "}]" then delete line -1 of tFormatted
               put c & cr after tFormatted
               break
            default
               put c after tFormatted
               break
         end switch
      else
         put c after tFormatted
      end if
      
      put c into prevChar
      
      if char -1 of tFormatted is cr then
         repeat tDepth
            put tIndent after tFormatted
         end repeat
      end if
   end repeat
   
   return tFormatted
end jsonFormat

-----

private function jsonDecode pString
   /* include
   unicodeEscapes
   utf8decode
   */
   switch pString
      case "false"
         return "false"
         break
      case "true"
         return "true"
         break
      case "null"
         return empty
         break
      default
         if pString is a number then
            return pString
         else
            replace "\" & quote with quote in pString
            replace "\\" with "\" in pString
            replace "\b" with numtochar(8) in pString
            replace "\t" with numtochar(9) in pString
            replace "\f" with numtochar(12) in pString
            replace "\r" with numtochar(13) in pString
            replace "\n" with numtochar(10) in pString
            
            -- some more common unicode escapees
            replace "\u0022" with quote in pString
            replace "\u005C" with "\" in pString
            -- any others
            if "\u" is in pString then
               put unicodeEscapes(pString) into pString
            end if
            
            if not sOutputUnicode then
               return utf8decode(pString)
            else
               return pString
            end if
         end if
   end switch
end jsonDecode

-----

private function unicodeEscapes pString
   put false into inEsc
   repeat for each char c in pString
      add 1 to count
      put c after buffer
      
      if count < 2 then next repeat
      
      if buffer is "\u" then put true into inEscape
      
      if inEscape then 
         if length(buffer) < 6 then 
            next repeat 
         else 
            -- TO DEAL WITH DIACRITICS : 
            -- TKD (26-07-2012): The output of this should be UTF-8. 
            -- The original code returned platform specific encoding. On Windows
            -- this worked fine as the code is the same as UTF-8. On Mac this is
            -- not correct. The code did not take into account integers > 255.
            --            if platform() is "MacOS" then 
            --               put isotomac(numtochar(baseconvert(char 3 to 6 of buffer, 16, 10))) into buffer 
            --            else 
            --               put numtochar(baseconvert(char 3 to 6 of buffer, 16, 10)) into buffer 
            --            end if 
            set the useUnicode to true
            try
               # might not be a valid conversion (think C:\Users\...)
               put unidecode(numToChar(baseconvert(char 3 to 6 of buffer, 16, 10)), "utf8") into buffer
            catch e
            end try
            set the useUnicode to false
            
            put buffer after nString
            put empty into buffer
            put false into inEscape
            put 0 into count
         end if 
      else 
         put char 1 of buffer after nString 
         delete char 1 of buffer 
      end if 
      
   end repeat
   put buffer after nString
   return nString
end unicodeEscapes

-----

private function jsonEncodeValue pString
   /* include
   jsonEncodeString
   */
   switch pString
      case true
         return "true"
         break
      case false
         return "false"
         break
      case "null"
         return "null"
         break
      case empty
         return quote & quote
         break
      default
         if pString is not a number OR pString contains NULL OR the last char of word 1 to -1 of pString is "." then #TKD Things like "3." or unicode ". " (period followed by NULL) need to be encoded by LiveCode says it is a number
            return q(jsonEncodeString(pString))
         else
            return pString
         end if
         break
   end switch
end jsonEncodeValue

private function jsonEncodeString pString
   /* include
   utf8encode
   */
   replace "\" with "\\" in pString
   replace quote with "\u0022" in pString
   replace numtochar(8) with "\b" in pString
   replace numtochar(9) with "\t" in pString
   replace numtochar(10) with "\n" in pString
   replace numtochar(12) with "\f" in pString
   replace numtochar(13) with "\r" in pString
   
   repeat for each item i in "0,1,2,3,4,5,6,7,11,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31"
      replace numtochar(i) with "\u" & format("%04X", i) in pString
   end repeat
   
   if sUnicodeInput then
      return pString
   else
      # TKD: This shouldn't be necessary. If not UTF8 then it is platform encoded and
      #          utf8encode will translate it to UTF8. That is what JSON wants. [Untested]
      --      -- TO DEAL WITH DIACRITICS : 
      --      if platform() is "MacOS" then 
      --         repeat with i=129 to 255 
      --            put numtochar(i) into c 
      --            put format("%04x",chartonum(mactoiso(c))) into tHexEncode 
      --            replace c with "\u" & tHexEncode in pString 
      --         end repeat 
      --      else 
      --         repeat with i=129 to 255 
      --            replace numtochar(i) with "\u" & format("%04x", i) in pString 
      --         end repeat 
      --      end if
      
      return utf8encode(pString)
   end if
end jsonEncodeString

-----

private function jsonToUtf8 @pJson
   /* include
   utf8encode
   swapEndianness
   */
   local tNulls = "1111"
   
   repeat with n = 1 to 4
      if (byte n of pJson is null) then put 0 into char n of tNulls
   end repeat
   
   put (char 1 of (binaryencode("I",1)) is null) into bigEndian
   
   switch tNulls
      case "1111"  -- UTF-8
         return pJson
         break
      case "0101"  -- UTF-16BE
         if bigEndian then
            return utf8encode(pJson, true)
         else
            return utf8encode(swapEndianness(pJson), true)
         end if
         break
      case "1010"  -- UTF-16LE
         if not bigEndian then
            return utf8encode(pJson, true)
         else
            return utf8encode(swapEndianness(pJson), true)
         end if
         break
      case "0001"  -- UTF-32BE
         return "libJson-error: 4 byte unicode, can't decode"
         break
      case "1000"  -- UTF-32LE
         return "libJson-error: 4 byte unicode, can't decode"
         break
   end switch
end jsonToUtf8

-----

private function swapEndianness pString, pSize
   if pSize is empty then put 2 into pSize
   repeat with n = 1 to length(pString) step pSize
      repeat with s = pSize - 1 down to 0
         put byte n + s of pString  after nString
      end repeat
   end repeat
   return nString
end swapEndianness

-----

private function utf8encode pString, pIsUnicode
   if pIsUnicode then
      return unidecode(pString, "UTF8")
   else
      return unidecode(uniencode(pString),"UTF8")
   end if
end utf8encode

-----

private function utf8decode pString, pToUnicode
   if pToUnicode then
      return uniencode(pString,"UTF8")
   else
      return unidecode(uniencode(pString,"UTF8"))
   end if
end utf8decode

-----

function q pString
   /* q ShortCut
   Syntax:
   q(string)
   
   Examples:
   put q("hello") --> "hello"
   
   Description:
   Returns a quoted string  -- "string"
   q */
   return quote & pString & quote
end q

function qq pWhat
   /* qq ShortCut
   Syntax:
   qq(string)
   
   Examples:
   put qq("'hello'")  --> "hello"
   
   Description:
   Replaces a single quote ( ' )  with a standard quote ( " )
   qq */
   replace "'" with quote in pWhat
   return pWhat
end qq



function getNestedItems
   /* getNestedItems Text Items
   Syntax:
   getNestedItems (theData, item_number, delimiter[,item_number, delimiter]...)
   
   Examples:
   put "aaa,bbb,ccc#ddd#eee#fff,ggg,hhh" into theData
   put getNestedITems(theData,3,comma,2,"#") -> "ddd" 
   
   put "a//b//1,2,3,4,5//d//e" into tData
   put getNestedItems(tData,3,"//",4,comma) -> 4
   
   put "aaa,bbb,ccc*ddd*eee*fff,ggg,hhh" into tData
   put getNestedItem(tData,3,comma,2,"*") -> "ddd"
   
   Description:
   Allows specifying different delimiters to extract nested chunks
   Specified delimiters can be strings, not just single characters.
   The parsing of items goes from left to right within the parameter list.
   
   So the following extracts the top-level domain name from a URL:
   .    put "http://www.nytimes.com/pages/science/index.html/" into tURL
   .    put getNestedItem(tURL,2,"://",1,"/") -> www.nytimes.com
   
   note: delimiter strings may not contain returns, except if they consist of a 
   single <cr> character
   
   based on a function by Richard Gaskin, use-LC list, originally named nDepth()
   debugged by members of the use-LC list,
   expanded by Peter M. Brigham, pmbrig@gmail.com
   
   .   theData = is the string to seach
   .   item_number = is the index to extract
   .   delemiter i= is a multi character string, default is comma
   
   Source: 
   Peter M. Brigham
   getNestedItems */
    
   /* include
   getItem
   */
   put paramcount() into prmCount
   if prmCount mod 2 <> 1 or prmCount = 1 then
      return "getNestedItem(): error in parameters."
   end if
   put param(1) into workingString
   repeat with i = 2 to prmCount-1 step 2
      if workingString = empty then return empty
      put param(i) into tItemNbr
      put param(i+1) into tDelim
      put getItem(workingString,tItemNbr,tDelim) into workingString
   end repeat
   return workingString
end getNestedItems

function getItem tList,tIndex,tDelim
   /* getItem Text Items
   Syntax:
   getItem (tList,tIndex,[tDelim])
   
   Examples:
   getItem("a,b,c,d,e,f",4) -> d
   getItem("a,b,c,d,e,f",4,",") -> d
   getItem("a//b//c//d//e//f",4,"//") -> d
   
   Description:
   Returns item # tIndex of tList, given itemdelimiter = tDelim
   could just "get item tIndex of tList" in the calling handler but
   then have to set and restore the itemDelimiter, so this is less hassle
   defaults to tDelim = tab
   
   It allows tDelim to be a string of characters so you could do this:
   getItem("a//b//c//d//e//f",4,"//") -> d
   
   It also allows tIndex to be a range, eg "3-5"
   in that case enclose the range in quotes
   
   Input:
   .   tList = is the string to seach
   .   tIndex = is the index to extract
   .   tDelim = is a multi character string, defaults to comma
   
   Output:
   .   item_number of tList
   
   Source: 
   Peter M. Brigham
   getItem */
   
   /* include
   getDelimiters
   */
   
    if tDelim = empty then put tab into tDelim
   put getDelimiters(tList) into tempDelim
   if len(tempDelim) > 1 then exit getItem
   replace tDelim with tempDelim in tList
   set the itemdelimiter to tempDelim
   if offset("-",tIndex) > 1 then
      replace "-" with " to " in tIndex
      do "put item" && tIndex && "of tList into theItem"
      replace tempDelim with tDelim in theItem
   else
      put item tIndex of tList into theItem
   end if
   return theItem
end getItem



function doAge birthDate,asOf
   /* doAge Date
   Syntax:
   doAge (birthDate,[asOf])
   
   Examples:
   doAge ("8/20/1952")
   doAge ("8/20/1952","1/1/2015")
   
   Description:
   Return the age given birthdate = <birthDate>  as of the date <asOf> 
   (if <asOf> is empty, it assumes today)
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   doAge */
   
     if asOf = empty then
           put the date into asOf
     end if
     convert birthDate to dateItems
     put item 1 of birthDate into birthYear
     convert asOf to dateitems
     put item 1 of asOf - birthYear - 1 into tAge
     if tAge < 0 then add 100 to tAge
     put item 1 of asOf into item 1 of birthDate
     convert birthDate to seconds
     convert asOf to seconds
     if birthDate <= asOf then add 1 to tAge
     return tAge
end doAge


function PadShortDate pDate,pYear
   /* PadShortDate Date
   
   Syntax:
   PadShortDate(pDate, [2000])
   
   Examples:
   PadShortDate()
   PadShortDate(,2000)
   PadShortDate("1/3/2003")
   PadShortDate("1/3/13")
   PadShortDate("1/3/13",2000)
   PadShortDate("1/3/13",1900)
   
   Description:
   Pads a English date (m/d/y) to mm/dd/yyyyy.  yy is also supported.  
   
   If no date is specified, it will return the current date. 
   
   Source:
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   PadShortDate */
   
   if pDate is empty then put the english date into pDate
   set itemdel to slash
   put format ("%2d", item 1 of pdate) into item 1 of pDate
   put format ("%2d", item 2 of pdate) into item 2 of pDate
   if pYear is not empty then 
      if item 3 of pdate < 100 then
         add pYear to item 3 of pdate
      end if
   end if
   replace space with "0" in pDate
   return pdate
end PadShortDate


function englishToSystemDate pDate, pUseLong
   /* englishToSystemDate Date
   
   Syntax:
   englishToSystemDate([pDate], [showLong])
   
   Examples:
   englishToSystemDate()
   englishToSystemDate("12/31/2003")
   englishToSystemDate(,showLong)
   
   Description:
   Converts English date (m/d/y) to the system date format.
   
   If no date is specified, it will return the current date in the system format.
   
   The optional 2nd parameter allows specification of long or short date
   with the short format being the default.  
   
   Source:
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   englishToSystemDate */
   if pDate is empty then put the english date into pDate
   if pUseLong = "showLong" then
      convert pDate from english date to long system date
   else
      convert pDate from english date to short system date
   end if
   return pDate
end englishToSystemDate


function systemToEnglishDate pDate, pUseLong
   /* systemToEnglishDate Date
   
   Syntax:
   systemToEnglishDate([pDate], [showLong])
   
   Examples:
   systemToEnglishDate()
   systemToEnglishDate(,showLong)
   
   Description:
   Converts the system date to the English date format (m/d/y).
   
   If no date is specified, it will return the current date in English format.
   
   The optional 2nd parameter allows specification of long or short date
   with the short format being the default. 
   
   Source:
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   systemToEnglishDate */
   
   if pDate is empty then put the system date into pDate
   if pUseLong = "showLong" then
      convert pDate from system date to long english date
   else
      convert pDate from system date to short english date
   end if
   return pDate
end systemToEnglishDate


function isLeapYear pYear
   /* isLeapYear Date
   Syntax:
   isLeapYear([pYear])
   
   Examples:
   IsLeapYear()
   isLeapYear(2000)
   
   Description:
   Returns true if the specified year is a leap year and false if not.
   
   If no year is specified, it will calculate for the current year.
   
   Source:
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   isLeapYear */
   
   if pYear is empty or pYear is not a number then
      put the seconds into tNow
      convert tNow to dateItems
      put item 1 of tNow into pYear
   end if
   
   if (pYear mod 400 = 0) or (pYear mod 100 <> 0) and (pYear mod 4 = 0) then
      return true
   else
      return false
   end if
end isLeapYear

function totalDaysInYear pYear
   /* totalDaysInYear Date
   
   Syntax:
   totalDaysInYear([pYear])
   
   Examples:
   totalDaysInYear()
   totalDaysInYear(2001)
   
   Description:
   Clever function for determining the number of days in a year
   allowing for leap years. 
   
   It works by setting the dateItems to the day before the 1st March. 
   When converted back to date format, the internal handlers automatically 
   convert this to 29th or 28th February allowing you to check for a leap year.
   
   The single optional parameter is a year. If none is specified, the current year is used.
   Thanks to Éric Chatonet for this function.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   totalDaysInYear */
   
   if pYear is empty or pYear is not a number then
      put the seconds into tDate
      convert tDate to dateItems
      put 3 into item 2 of tDate
      put 0 into item 3 of tDate
   else
      put pYear & "3,0,12,0,0,0" into tDate
   end if
   
   convert tDate to dateItems
   if item 3 of tDate = 29 then return "366"
   else return "365"
end totalDaysInYear


function numericDate pDate
   /* numericDate Date
   
   Syntax:
   numericDate([pDate])
   
   Examples:
   numericDate()
   numericDate("12/31/03")
   
   Description:
   Returns the date in yyyymmdd format for the specified date.
   
   If no date is specified, it will return the current year.
   
   This has the advantage of being sortable both numerically and alphabetically.
   If supplied, the date must be in English format (use the systemToEnglishDate 
   function if necessary).
      
      Source: 
      Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
      numericDate */
      
      if pDate is empty or pDate is not a date then put the short english date into pDate
      convert pDate from short english date to dateItems
      
      put item 2 of pDate into tMonth
      if tMonth < 10 then put "0" before tMonth
      put item 3 of pDate into tDay
      if tDay < 10 then put "0" before tDay
      return item 1 of pDate & tMonth & tDay
end numericDate


function yearNum pDate
   /* yearNum Date
   
   Syntax:
   yearNum([pDate])
   
   Examples:
   yearNum()
   yearNum("6/3/03")
   
   Description:
   Returns the 4 digit year number for the specified date.
   
   If no date is specified, it will return the current year.
   
   If supplied, the date must be in English format (use the systemToEnglishDate 
   function if necessary).
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   yearNum */
   
   if pDate is empty or pDate is not a date then put the short english date into pDate
   convert pDate from short english date to dateItems
   
   return item 1 of pDate
end yearNum


function monthName pMonthNum
   /* monthName Date
   
   Syntax:
   monthName([pMonthNum], [abbrev], [useSystem])
   
   Examples:
   monthName()
   monthName(7)
   monthName(,abbrev)
   monthName(3,useSystem)
   
   Description:
   Returns the month name for a specific month number.
   
   If no month is specified, it will return the current month's name.
   
   The other parameters allows specification of long or short names
   with the long names being the default and specification of system or default names
   with the system names being the default. The order of these extra parameters does
   not matter, but the month number must be first. If no month number is specified, 
   an empty parameter must be first.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   monthName */
   
   
   if pMonthNum is empty then
      put the seconds into tNow
      convert tNow to dateItems
      put item 2 of tNow into pMonthNum
   else if pMonthNum is not a number then
      return pMonthNum
   end if
   
   put false into pAbbrev
   put false into pUseSystemNames
   put the paramcount into pCount
   repeat for each item p in the params
      if p contains "abbrev" then put true into pAbbrev
      if p contains "useSystem" then put true into pUseSystemNames
   end repeat
   
   if pAbbrev = true then
      if pUseSystemNames = false then
         return line pMonthNum of the abbrev monthnames
      else
         return line pMonthNum of the abbrev system monthnames
      end if
   else
      if pUseSystemNames = false then
         return line pMonthNum of the monthnames
      else
         return line pMonthNum of the system monthnames
      end if
   end if
end monthName


function monthNum pMonth
   /* monthNum Date
   
   Syntax:
   monthNum([pMonth])
   
   Examples:
   monthNum()
   monthNum("Dec")
   monthNum("January")
   
   Description:
   Returns the month number for a specific month name, with either long or short month names being allowed.
   
   .   It will work if the system names or the default names for the months are used.
   .   If no month is specified, it will return the current month's number.
   .   If no match is found, the result will be 0.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   monthNum */
   
   
   if pMonth is empty then
      put the seconds into tNow
      convert tNow to dateItems
      return item 2 of tNow
   else
      get lineoffset(pMonth, the abbrev system monthNames)
      if it = 0 then get lineoffset(pMonth, the system monthNames)
      if it = 0 then get lineoffset(pMonth, the abbrev monthNames)
      if it = 0 then get lineoffset(pMonth, the monthNames)
      return it
   end if
end monthNum


function daysInMonth pMonth, pYear
   /* daysInMonth Date
   
   Syntax:
   daysInMonth([pMonth], [pYear])
   
   Examples:
   daysInMonth()
   daysInMonth("Dec")
   daysInMonth(2,2000)
   
   Description:
   Returns the number of days in a specific month.
   
   The month can be entered as a number or a name with either long or 
   short month names being allowed.   System or default month names are 
   both allowed.
   
   If no month is specified, it will return the current month's number.
   If a name is used, this function calls the monthNum() function, so don't separate 
   them if copying this script into another stack.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   daysInMonth */
   
   /* Include
   monthNum
   */
   
   if pMonth is empty or pYear is empty then
      put the seconds into tNow
      convert tNow to dateItems
      if pMonth is empty then put item 2 of tNow into pMonth
      if pYear is empty then put item 1 of tNow into pYear
   end if
   if pMonth is not a number then put monthNum(pMonth) into pMonth
   
   if (pMonth is in "1,3,5,7,8,10") or (pMonth = 12) then
      return 31
   else if (pMonth is in "4,6,9,11") then
      return 30
   else if (pYear mod 400 = 0) or (pYear mod 100 <> 0) and (pYear mod 4 = 0) then
      return 29 -- leap year
   else return 28
end daysInMonth


function weekNum pDate
   /* weekNum Date
   
   Syntax:
   weekNum([pDate])
   
   Examples:
   weekNum()
   weekNum("12/31/2002")
   
   Description:
   Returns the absolute week number for a specific date.
   
   .    if supplied, the date must be in English format (use the systemToEnglishDate 
   .    function if necessary).
   .    If no date is specified, the current week number is returned
   
   This is not the ISO week number where week 1 is the week beginning on a Monday that contains
   4th January, but the absolute week where week 1 starts on January 1st.  December 31st will 
   always be in week 53 and December 30th will vary with leap years.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   weekNum */
   
   
   if pDate is empty or pDate is not a date then put the short english date into pDate
   
   put pDate into startYearDate
   set itemdelimiter to "/"
   put 1 into item 1 of startYearDate
   put 1 into item 2 of startYearDate
   
   convert pDate from short english date to seconds
   convert startYearDate from short english date to seconds
   
   put pDate - startYearDate into secsThisYear
   put secsThisYear / (24*60*60) into daysThisYear
   return (daysThisYear div 7) + 1
end weekNum


function weekNumISO pDate, pBeginningDay
   /* weekNumISO Date
   
   Syntax:
   weekNumISO([pDate], [pBeginningDay])
   
   Examples:
   weekNumISO()
   weekNumISO("30/3/2002")
   weekNumISO(,"Sunday")
   weekNumISO("12/31/2000")
   weekNumISO("12/31/2000", "Sunday")
   
   Description:
   Returns the number of the current week according to ISO:
   first Thursday of the year is always in the first week of the year.
   
   .   If supplied, the date must be in English format (use the systemToEnglishDate
   .       function if necessary).
   .   If no date is specified, the current date is used.
   
   The second optional parameter is "Sunday" or "Monday" and indicates the 
   first week day to be displayed.   If no beginning date is specified, "Monday" 
   is used as the default (ISO standard).
   
   Source:
   Eric Chatonet
   weekNumISO */
   
   /* Include
   dayInYear
   weekNum
   */
   
   if pBeginningDay <> "Sunday" then put "Monday" into pBeginningDay
   if pDate is empty or pDate is not a date then put the short english date into pDate
   
   -- computing the number of days in current week:
   convert pDate from short english date to dateItems
   put last item of pDate into tDay
   if pBeginningDay = "Sunday" then
      put tDay into tNumOfDaysInCurrentWeek
   else
      if tDay = 1 then put 7 into tNumOfDaysInCurrentWeek
      else put tDay - 1 into tNumOfDaysInCurrentWeek
   end if
   
   -- computing the days of first & last day of year
   put pDate into firstDayOfYear
   put 1 into item 2 of firstDayOfYear
   put 1 into item 3 of firstDayOfYear
   convert firstDayOfYear to dateItems
   put last item of firstDayOfYear into firstDay
   
   put pDate into lastDateOfYear
   put 12 into item 2 of lastDateOfYear
   put 31 into item 3 of lastDateOfYear
   convert lastDateOfYear to dateItems
   put last item of lastDateOfYear into lastDay
   
   -- computing the number of days in first week of the year:
   if pBeginningDay = "Sunday" then
      put (firstDay is not in "67") into tThursdayIsInFirstWeek
   else
      put (firstDay is not in "167") into tThursdayIsInFirstWeek
   end if
   if pBeginningDay = "Sunday" then
      put 8 - (firstDay) into tNumOfDaysInFirstWeek
   else
      if firstDay = 1 then put 1 into tNumOfDaysInFirstWeek
      else put 9 - firstDay into tNumOfDaysInFirstWeek
   end if
   
   -- computing the week number and returning the result:
   put pDate into tEnglishDate
   convert tEnglishDate from dateItems to short english date
   put dayInYear(tEnglishDate) into tDayNum
   
   if tThursdayIsInFirstWeek then
      if tDayNum <= tNumOfDaysInFirstWeek then
         return "1"
      else if (tDayNum > tNumOfDaysInFirstWeek) and \
            (tDayNum <= tNumOfDaysInFirstWeek + tNumOfDaysInCurrentWeek) then
         return "2"
      else
         put ((tDayNum - (tNumOfDaysInFirstWeek + tNumOfDaysInCurrentWeek)) / 7) + 2 into tWeekNum
         -- check for going over to the next year
         if tWeekNum = 53 then
            -- if last day of the year is after Thursday, go to next year
            if lastDay < 5 then return 1
            else return 53
         else if tWeekNum = 54 then
            return 1
         else
            return tWeekNum
         end if
      end if
      
   else if tDayNum <= tNumOfDaysInFirstWeek then
      if (firstDay < 4 and pBeginningDay = "Sunday") or \
            (tDayNum <> 1 and tDayNum < 4 and pBeginningDay = "Monday") then
         return 1
      else
         subtract 1 from item 1 of lastDateOfYear
         return weekNum(lastDateOfYear, pBeginningDay) -- recursive
      end if
      
   else if (tDayNum > tNumOfDaysInFirstWeek) and \
         (tDayNum <= tNumOfDaysInFirstWeek + tNumOfDaysInCurrentWeek) then
      return "1"
   else
      return ((tDayNum - (tNumOfDaysInFirstWeek + tNumOfDaysInCurrentWeek)) / 7 ) + 1
   end if
end weekNumISO


function dayName pDate
   /* dayName Date
   
   Syntax:
   dayName([pDate], [abbrev], [useSystem])
   
   Examples:
   dayName()
   dayName("9/30/2020")
   dayName(,abbrev)
   dayName(,useSystem)
   
   Description:
   Returns the weekday name for a specific date.
   
   .   If no date is specified, it will use the current date.
   .   If supplied, the date must be in English format (use the systemToEnglishDate 
   .      function if necessary).
      
      The other parameters allows specification of long or short names
      with the long names being the default and specification of system or default names
      with the system names being the default. The order of these extra parameters does
      not matter, but the date must be first. If no date is specified, 
      an empty parameter must be first.
      
      Source: 
      Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
      dayName */
      
      
      if pDate is empty then put the short english date into pDate
      else if pDate is not a date then return empty
      
      put false into pAbbrev
      put false into pUseSystemsNames
      put the paramcount into pCount
      repeat for each item p in the params
         if p contains "abbrev" then put true into pAbbrev
         if p contains "useSystem" then put true into pUseSystemsNames
      end repeat
      
      convert pDate from short english date to dateItems
      put last item of pdate into dayInYear
      if pAbbrev = true then
         if pUseSystemsNames = false then
            return line dayInYear of the abbrev weekdaynames
         else
            return line dayInYear of the abbrev system weekdaynames
         end if
      else
         if pUseSystemsNames = false then
            return line dayInYear of the weekdaynames
         else
            return line dayInYear of the system weekdaynames
         end if
      end if
end dayName


function dayInYear pDate
   /* dayInYear Date
   
   Syntax:
   dayInYear([date])
   
   Examples:
   dayInYear()
   dayInYear("12/31/2004")
   
   Description:
   Returns the day number within the year for a specific date.
   
   .   If no date is specified, it will use the current date.
   .   If supplied, the date must be in English format (use the systemToEnglishDate 
   .       function if necessary).
   
   Thanks to Éric Chatonet for this function.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   dayInYear */
   
   
   if pDate is empty or pDate is not a date then put the short english date into pDate
   
   put pDate into tJanuaryFirst
   convert tJanuaryFirst from short english date to dateItems
   put 1 into item 2 of tJanuaryFirst
   put 1 into item 3 of tJanuaryFirst
   convert tJanuaryFirst to seconds
   
   convert pDate to seconds
   return round((pDate - tJanuaryFirst) / 86400) + 1
end dayInYear


function daysBetween pDate1, pDate2
   /* daysBetween Date
   
   Syntax:
   daysBetween(date1, [date2])
   
   Examples:
   daysBetween("9/28/03")
   daysBetween("1/1/2002", "1/1/2003")
   
   Description:
   Returns the number of days between 2 dates.
   
   .   If only one date is specified, it will use the current date for the second.
   
   The dates must be in English format (use the systemToEnglishDate function if necessary).
   It doesn't matter whether the most recent date is first or last.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   daysBetween */
   
   
   if pDate2 is empty then put the short english date into pDate2
   if pDate1 is not a date or pDate2 is not a date then return empty
   
   convert pDate1 from short english date to dateItems
   convert pDate2 from short english date to dateItems
   repeat with i = 4 to 7
      put 0 into item i of pDate1
      put 0 into item i of pDate2
   end repeat
   convert pDate1 from dateItems to seconds
   convert pDate2 from dateItems to seconds
   
   put abs(pDate1 - pDate2) into tDiff
   return tDiff / (60 * 60 * 24)
end daysBetween


function monthNumber pDate
   /* monthNumber Date
   
   Syntax:
   monthNumber([date])
   
   Examples:
   monthNumber()
   monthNumber("12/31/2004")
   monthNumber() - monthNumber("1/1/2004")
   
   Description:
   returns a numeric value for the months in a given date so month comparisons can be made
   
   .    If no date is specified, it will use the current date.
   .    If supplied, the date must be in English format (use the systemToEnglishDate
   .          function if necessary).
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   monthNumber */
   
   
   if pDate is empty or pDate is not a date then put the short english date into pDate
   
   convert pDate to dateItems
   put item 1 of pDate into tYears
   put item 2 of pDate into tMonths
   put item 3 of pDate into tDay
   
   if tDay > 15 then add 1 to tMonths
   return (tYears * 12) + tMonths
end monthNumber


function timeZone
   /* timeZone Date
   
   Syntax:
   timeZone()
   
   Examples:
   timeZone()
   
   Description:
   Returns the time zone according to the current system settings using +/-hhmm format.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   timeZone */
   
   
   put the internet date into tNow
   put last word of tNow into tZone
   return tZone
end timeZone

function militaryClock pShowSeconds
   /* militaryClock Date
   
   Syntax:
   militaryClock([showSecs])
   
   Examples:
   militaryClock()
   militaryClock(showSecs)
   
   Description:
   Returns the time in 24 hour format, regardless of current system settings.
   
   The normal preferences will remain unchanged.
   
   The optional parameter can be used to specify that the time be shown with seconds,
   without seconds is the default.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   militaryClock */
   
   put the twelvehourtime into oldSet
   set the twelvehourtime to false
   if pShowSeconds = "showSecs" then
      put the long  time into tNow
   else
      put the  time into tNow
   end if
   set the twelvehourtime to oldSet
   return tNow
end militaryClock


function twelveHourClock pShowSeconds
   /* twelveHourClock Date
   
   Syntax:
   twelveHourClock([showSecs])
   
   Examples:
   twelveHourClock()
   twelveHourClock(showSecs)
   
   Description:
   Returns the time in 12 hour format showing am or pm, regardless of current system settings.
   
   The normal preferences will remain unchanged.
   
   The optional parameter can be used to specify that the time be shown with seconds,
   without seconds is the default.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   twelveHourClock */
   
   put the twelvehourtime into oldSet
   set the twelvehourtime to true
   if pShowSeconds = "showSecs" then
      put the long system time into tNow
   else
      put the system time into tNow
   end if
   set the twelvehourtime to oldSet
   return tNow
end twelveHourClock


function titleCase pString
   /* titleCase Date
   
   Syntax:
   titleCase(pString)
   
   Examples:
   titleCase("wednesday")
   titleCase("janvier")
   
   Description:
   Changes the first letter of the supplied string to uppercase.
   
   Apparently, the system monthNames and system weekdayNames in some
   languages, return the names all in lower case, which may need correcting.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   titleCase */
   
   put toupper(char 1 of pString) into char 1 of pString
   return pString
end titleCase


function dateOfEaster pYear
   /* dateOfEaster Date
   
   Syntax:
   dateOfEaster(pYear)
   
   Examples:
   dateOfEaster()
   dateOfEaster(2000)
   dateOfEaster(1500)
   
   Description:
   This funcion calculates the date of Easter for a given year.
   
   If no year is specified, the current year is used.
   
   It cannot calculate Easter for years before 1583, so will return empty for any 
   years earlier than that.
   
   The date is returned in short English format (use the systemToEnglishDate 
   .    function to convert if necessary).
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   dateOfEaster */
   
   
   if pYear is empty or pYear is not a number then
      put the seconds into tNow
      convert tNow to dateItems
      put item 1 of tNow into pYear
   end if
   
   if pYear < 1583 then return empty
   
   put 0 into wCorrection
   if( pYear < 1700 ) then put 4 into wCorrection
   else if pYear < 1800 then put 5 into wCorrection
   else if pYear < 1900 then put 6 into wCorrection
   else if pYear < 2100 then put 0 into wCorrection
   else if pYear < 2200 then put 1 into wCorrection
   else if pYear < 2300 then put 2 into wCorrection
   else if pYear < 2500 then put 3 into wCorrection
   
   put (19 * (pYear mod 19) + 24) mod 30 into wDay
   put 22 + wDay + ((2 * (pYear mod 4) + 4 * (pYear mod 7) + 6 * wDay + 5 + wCorrection) mod 7) into wDay
   
   -- jump to next month
   if wDay > 31 then
      put 4 into wMonth
      subtract 31 from wDay
   else
      put 3 into wMonth
   end if
   
   return wMonth & "/" & wDay & "/" & pYear
end dateOfEaster


function relativeDate pIndex, pDay, pMonth, pYear
   /* relativeDate Date
   
   Syntax:
   relativeDate(pIndex, pDay, pMonth, pYear)
   
   Examples:
   relativeDate("First", "Tues", "November", "2004")
   relativeDate("Last", "Wednesday", "January", "2000")
   relativeDate(2, "Sunday", 5, "2002")
   
   Description:
   This function calculates exact dates from relative dates
   like "the last Monday in May 2000" or "the 2nd Saturday in October 2004".
   
   .    pIndex can be: First, Second, Third, Fourth, Last
   .          or +1, +2, +3, +4, +5, -1 (the + is optional).
   .    pDay is a day name in long or abbreviated system form.
   .    pMonth can be a number or a month name and pYear must be a number.
   
   The resulting date is returned in short English format 
   .    (use the systemToEnglishDate function to convert if necessary).
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   relativeDate */
   /* Include
   monthNum
   */
   
   -- extract the day name & convert to a number
   put char 1 to 3 of pDay into tDayName
   put the abbrev system weekdaynames into tDayList
   get lineoffset(tDayName, tDayList)
   if it = 0 then return empty
   put it into tDayNum
   
   if pMonth is not a number then put monthNum(pMonth) into pMonth
   if char 1 of pIndex = "+" then delete char 1 of pIndex
   
   -- find first whatever day in the month
   put pMonth & "/1/" & pYear into firstDate
   convert firstDate from short english date to dateItems
   put last item of firstDate into firstDayNum
   put tDayNum - firstDayNum into dayDiff
   if dayDiff < 0 then add 7 to dayDiff
   add dayDiff to item 3 of firstDate
   convert firstDate to seconds
   convert firstDate to dateItems
   
   -- add weeks as necessary
   switch pIndex
      case "First"
      case "1"
         break
      case "Second"
      case "2"
         add 7 to item 3 of firstDate
         break
      case "Third"
      case "3"
         add 14 to item 3 of firstDate
         break
      case "Fourth"
      case "4"
         add 21 to item 3 of firstDate
         break
      case "Fifth"
      case "5"
         add 28 to item 3 of firstDate
         break
      case "Last"
      case "-1"
         -- try week 5 and if that doesn't work, use week 4
         put firstDate into testDate
         add 28 to item 3 of testDate
         convert testDate to seconds
         convert testDate to dateItems
         if item 2 of testDate = pMonth then
            put testDate into firstDate
         else
            add 21 to item 3 of firstDate
         end if
         break
      default
         return empty
   end switch
   
   convert firstDate to seconds
   convert firstDate to dateItems
   put item 2 of firstDate into newM
   put item 3 of firstDate into newD
   
   return pMonth & "/" & newD & "/" & pYear
end relativeDate


function dateTimeToJulian pYear, pMonth, pDate, pHour, pMins, pSecs
   /* dateTimeToJulian Date
   
   Syntax:
   dateTimeToJulian(pYear, pMonth, pDate, [pHour], [pMins], [pSecs])
   
   Examples:
   dateTimeToJulian()
   dateTimeToJulian(2004,3,22)
   dateTimeToJulian(2004,3,22,12,2)
   dateTimeToJulian(2004,3,22,12,5,45)
   
   Description:
   This function returns the date and time in Julian date format.
   
   .     If no date is specified, it will use the current date.
   .          If supplied, the date must be in date items format: year, month, day, 
   .          hour, minutes, seconds.    This is because the internal date conversions 
   .          may not work for early dates.
   .    The time parameters are optional and seconds need not be specified.
   
   Julian dates (abbreviated JD) are simply a continuous count of days and fractions
   since noon Universal Time on January 1, 4713 BCE (on the Julian calendar).
   Almost 2.5 million days have transpired since this date.
   
   Julian dates are widely used as time variables within astronomical software.
   Typically, a 64-bit floating point (double precision) variable can represent
   an epoch expressed as a Julian date to about 1 millisecond precision.
   Note that the time scale that is the basis for Julian dates is Universal Time,
   and that 0h UT corresponds to a Julian date fraction of 0.5.
   
   It is assumed that 7-day weeks have formed an uninterrupted sequence since ancient times.
   Thus, the day of the week can be obtained from the remainder of the division of
   the Julian date by 7.
   
   Source:
   This function is copyright 2004 Mark Wieder and Ah, Software
   dateTimeToJulian */
   
   if the paramcount < 3 then
      put the seconds into tNow
      convert tNow to dateItems
      put item 1 of tNow into pYear
      put item 2 of tNow into pMonth
      put item 3 of tNow into pDate
      put item 4 of tNow into pHour
      put item 5 of tNow into pMins
      put item 6 of tNow into pSecs
   end if
   
   if pHour is empty then put 0 into pHour
   if pMins is empty then put 0 into pMins
   if pSecs is empty then put 0 into pSecs
   
   -- calculate date part of Julian number
   put 100 * pYear + pMonth - 190002.5 into extra
   put 367 * pYear into julianDate
   subtract trunc(7.0 * (pYear + trunc((pMonth + 9) / 12)) / 4) from julianDate
   add trunc(275 * pMonth / 9 ) to julianDate
   add pDate to julianDate
   
   -- now add the time as a fractional day
   add (pHour + (pMins + pSecs / 60) / 60) / 24 to julianDate
   add 1721013.5 to julianDate
   subtract .5 * extra / abs(extra) from julianDate
   
   -- compensate for the fact the UTC starts at noon
   add .5 to julianDate
   
   return julianDate
end dateTimeToJulian


function JulianToDateTime pJulian
   /* JulianToDateTime Date
   
   Syntax:
   JulianToDateTime(pJulian)
   
   Examples:
   JulianToDateTime(2453086.5)
   JulianToDateTime(2453087.001389)
   JulianToDateTime(2453087.003993)
   
   Description:
   This function returns the date in short English date format.
   
   .    If the supplied Julian time includes a time component,
   .         it returns the time in either long or short 24 hour format,
   .         depending on whether the seconds are zero or not.
   
   See dateTimeToJulian for more notes about Julian dates.
   
   Source:
   This function is copyright 2004 Mark Wieder and Ah, Software
   JulianToDateTime */
   
   put trunc(pJulian + .5) into jd0
   if (jd0 < 2299161) then
      put jd0 + 1524 into c
   else
      put trunc((jd0 - 1867216.25) / 36524.25) into b
      put jd0 + (b - trunc(b/4)) + 1525 into c
   end if
   put trunc((c - 122.1)/365.25) into d
   put 365 * d + trunc(d/4) into e
   put trunc((c-e) / 30.6001) into f
   
   put trunc(c - e + .5) - trunc(30.6001 * f) into tDate
   put f - 1 - 12 * trunc(f/14) into tMonth
   put d - 4715 - trunc((7 + tMonth) /10) into tYear
   
   put 24 * (pJulian + .5 - jd0) into tempHour
   put trunc(tempHour * 60 + .5) / 60 into tHour
   put trunc(tHour) into tHour
   
   put (60 * (tempHour - tHour)) into tempMin
   put trunc(tempMin) into tMin
   put round(60 * (tempMin - tMin)) into tSec
   
   if tHour < 10 then put "0" before tHour
   if tMin < 10 then put "0" before tMin
   if tSec < 10 then put "0" before tSec
   
   if tHour = 0 and tMin = 0 and tSec = 0 then
      put tMonth & "/" & trunc(tDate) & "/" & tYear into tResult
   else if tSec = 0 then
      put tMonth & "/" & trunc(tDate) & "/" & tYear && tHour & ":" & tMin into tResult
   else
      put tMonth & "/" & trunc(tDate) & "/" & tYear && tHour & ":" & tMin & ":" & tSec into tResult
   end if
   return tResult
end JulianToDateTime()


function englishToSQLdate pDate
   /* englishToSQLdate Date
   
   Syntax:
   englishToSQLdate([pDate])
   
   Examples:
   englishToSQLdate()
   englishToSQLdate("6/3/09")
   
   
   Description:
   Converts a short English date into an SQL format date (YYYY-MM-DD)
   
   .    If no date is specified, it will use the current date.
   .          If supplied, the date must be in English format 
   .          (use the systemToEnglishDate function if necessary).
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   englishToSQLdate */
   
   if pDate is empty then put the short english date into pDate
   convert pDate from short english date to dateItems
   put item 2 of pDate into m
   if m < 10 then put "0" before m
   put item 3 of pDate into d
   if d < 10 then put "0" before d
   
   return item 1 of pDate & "-" & m & "-" & d
end englishToSQLdate()


function SQLToEnglishDate pDate, pFourDigitYear
   /* SQLToEnglishDate Date
   
   Syntax:
   SQLToEnglishDate([pDate], [pFourDigitYear])
   
   Examples:
   SQLToEnglishDate()
   SQLToEnglishDate("2009-08-30")
   SQLToEnglishDate("2009-01-15", true)
   
   Description:
   Converts an SQL format date (YYYY-MM-DD) into a short English date. 
   
   .    If no date is specified, it will use the current date.
   .    The optional parameter pFourDigityear allows you to specify that the 
   .          short date will show the year in 4 digits.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   SQLToEnglishDate */
   
   if pDate is empty then return the short english date
   replace "-" with comma in pDate
   put ",12,0,0,0" after pDate
   convert pDate from dateItems to short english date
   
   if pFourDigitYear = true then
      set the itemdel to "/"
      put last item of pDate into y
      if the number of chars in y = 4 then
         return pDate
      end if
      if y > 80 and y < 100 then put "19" before last item of pDate
      else if y < 2000 then put "20" before last item of pDate
   end if
   
   return pDate
end SQLToEnglishDate()


function timeStamp pSecs
   /* timeStamp Date
   
   Syntax:
   timeStamp([pSecs])
   
   Examples:
   timeStamp()
   timeStamp(1249865187)
   
   Description:
   Converts the time in seconds into a standard timestamp format: YYYYMMDDHHMMSS
   
   This is very useful to transferring times across different time zones,
   and gives a readable as well as sortable time/date indicator.
   
   If no time in seconds is specified, it will use the current seconds.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   timeStamp */
   
   if the length of pSecs = 14 and pSecs is a number then return pSecs   -- already converted
   if pSecs is not empty and pSecs is not a number then return pSecs   -- not valid seconds
   
   if pSecs is empty then
      put the seconds into tNow
   else
      put pSecs into tNow
   end if
   convert tNow to dateItems
   
   put item 1 of tNow into tStamp
   repeat with x = 2 to 6
      put char -2 to -1 of ("00" & item x of tNow) after tStamp
   end repeat
   
   return tStamp
end timeStamp()


function timeStampToSeconds pStamp
   /* timeStampToSeconds Date
   
   Syntax:
   timeStampToSeconds([pStamp])
   
   Examples:
   timeStampToSeconds(20090810104945)
   timeStampToSeconds(20060630140000)
   
   Description:
   Converts the time in timestamp format (YYYYMMDDHHMMSS) back into time in seconds.
   
   If using a timeStamp, this allows you to convert it back to seconds for temporary use.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   timeStampToSeconds */
   
   if pStamp is empty then return the seconds
   
   put char 1 to 4 of pStamp & comma into tSecs
   put char 5 to 6 of pStamp & comma after tSecs
   put char 7 to 8 of pStamp & comma after tSecs
   put char 9 to 10 of pStamp & comma after tSecs
   put char 11 to 12 of pStamp & comma after tSecs
   put char 13 to 14 of pStamp & comma & 0 after tSecs
   
   convert tSecs from dateItems to seconds
   return tSecs
end timeStampToSeconds()


function timeStampToShortDate pStamp
   /* timeStampToShortDate Date
   
   Syntax:
   timeStampToShortDate([pStamp])
   
   Examples:
   timeStampToShortDate(20090810104945)
   timeStampToShortDate(20060630140000)
   
   Description:
   Converts the time in timestamp format (YYYYMMDDHHMMSS) to the short English date.
   
   This ignores the time portion of the timeStamp but is useful for display purposes.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   timeStampToShortDate */
   
   if pStamp is empty then return the short english date
   
   put char 1 to 4 of pStamp into tYear
   put char 5 to 6 of pStamp into tMonth
   put char 7 to 8 of pStamp into tDay
   if char 1 of tMonth = "0" then delete char 1 of tMonth
   if char 1 of tDay = "0" then delete char 1 of tDay
   
   put tYear & comma & tMonth & comma & tDay & ",12,0,0,0" into tDate
   convert tDate from dateItems to short english date
   
   return tDate
end timeStampToShortDate()

function timeStampToShortTime pStamp
   /* timeStampToShortTime Date
   
   Syntax:
   timeStampToShortTime([pStamp])
   
   Examples:
   timeStampToShortTime(20090810104945)
   timeStampToShortTime(20060630140000)
   
   Description:
   Converts the time in timestamp format (YYYYMMDDHHMMSS) to the shortime,
   converting from 24 to 12 hour time.
   
   This ignores the date portion of the timeStamp but is useful for display purposes.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   timeStampToShortTime */
   
   
   if pStamp is empty then return the short time
   
   put char 9 to 10 of pStamp into tHour
   put char 11 to 12 of pStamp into tMins
   if tHour > 12 then
      subtract 12 from tHour
      put "pm" into tSuffix
   else if tHour = 12 then
      put "pm" into tSuffix
   else
      put "am" into tSuffix
   end if
   
   -- allow for midnight
   if tHour = "00" then
      put 12 into tHour
      put "am" into tSuffix
   end if
   
   return tHour & ":" & tMins && tSuffix
end timeStampToShortTime


function DateOffset pDate, pOffset
   /* DateOffset Date
   
   Syntax:
   DateOffset (date, offsetdays)
   
   Examples:
   DateOffset(,7)
   DateOffset(,-7)
   DateOffset("1/1/2013",7)
   DateOffset("1/1/2013",-7)
   
   Description:
   returns the date (m/d/yyyy) after the offset in days has been computed
   
   .   If no date is specified, it will use the current date.
   
   Source: 
   Sarah Reichelt, http://www.troz.net/rev/stacks/DateTime.rev
   DateOffset */
   
   /* Include
   yearNum
   libDate_DayNumber
   FromDayNum
   */
   
   local pYear, pMonth,pDay
   set itemdel to slash
   if pDate is empty then 
      put the system date into pDate
      put yearNum() into item 3 of pDate
   end if
   put item 2 of pDate into pDay
   put item 1 of pDate into pMonth
   put item 3 of pDate into pYear
   put libDate_DayNumber (pYear,pMonth,pDay) into theNbr
   add pOffset to theNbr
   put FromDayNum (theNbr) into pDate
   return pDate
end DateOffset




function toDayNum pDate
   /* toDayNum Date
   
   Syntax:
   toDayNum
   
   Examples:
   toDayNum()
   toDayNum("12/31/2004")
   
   Description:
   Converts the date format (m/d/yyyy) to the day number.
   
   .   If no date is specified, it will use the current date.
   
   Source:
   taken from http://alcor.concordia.ca/~gpkatch/gdate-algorithm.html
   toDayNum */
   
   /* Include
   yearNum
   libDate_DayNumber
   */
   
   local pYear, pMonth,pDay
   set itemdel to slash
   if pDate is empty then 
      put the system date into pDate
      put yearNum() into item 3 of pDate
   end if
   put item 1 of pDate into pDay
   put item 2 of pDate into pMonth
   put item 3 of pDate into pYear
   return libDate_DayNumber (pYear,pMonth,pDay)
end toDayNum


function FromDayNum pNumber
   /* FromDayNum Date
   
   Syntax:
   FromDayNum([daynumber])
   
   Examples:
   FromDayNum("735540")
   
   Description:
   Converts the daynumber to  mm/dd/yyyy
   
   .   If no date is specified, it will use the current date.
   
   Source:
   taken from http://alcor.concordia.ca/~gpkatch/gdate-algorithm.html
   FromDayNum */
   
   /* Include
   libDate_dateFromNumber
   */
   
   local pYear, pMonth,pDay
   put libDate_dateFromNumber(pNumber) into tDate
   set itemdel to comma
   put (item 2 of tDate & slash & item 3 of tDate & slash & item 1 of tDate) into tDate
   return tDate
end FromDayNum

Private function libDate_DayNumber pYear,pMonth,pDay
   put  (pMonth + 9) mod 12 into pMonth
   put pYear - pMonth div 10 into pYear
   return 365*pYear + pYear div 4 - pYear div 100 + pYear div 400 + (pMonth*306 + 5) div 10 + ( pDay - 1 )
end libDate_DayNumber

Private function libDate_dateFromNumber pNumber
   local tYear,tMonth,tDay,tDays,tMonths
   put (10000*pNumber + 14780) div 3652425 into tYear
   put pNumber - (365*tYear + tYear div 4 - tYear div 100 + tYear div 400) into tDays
   if (tDays < 0) then
      put tYear - 1 into tYear
      put  pNumber - (365* tYear + tYear div 4 - tYear div 100 + tYear div 400) into tDays
   end if
   put  (100*tDays + 52) div 3060 into tMonths
   put  (tMonths + 2) mod 12 + 1 into tMonth
   put tYear + (tMonths + 2) div 12into tYear
   put tDays - (tMonths*306 + 5) div 10 + 1 into tDay
   return tYear, tMonth, tDay
end libDate_dateFromNumber


function setHeightProportional pImageID, pHeight
   /* setHeightProportional Image
   
   Syntax:
   setHeightProportional (pImage, pHeight)
   
   Examples:
   setHeightProportional (pImage, pHeight)
   
   Description:
   Resizes an image to fit within a given height maintaining proportianally
   
   Input:
   .   pImage - the identifer of the image
   .   pHight  - the desired pixel height of the image
   
   Return:
   .   tWidth  - the resulting width of the image after resizing
   
   Source: 
   Michael Doub
   setHeightProportional */
   local tRatio, tWidth, tloc
   put (the formattedHeight of pImageID) / pHeight into tRatio
   put (the formattedWidth of pImageID) / tRatio into tWidth
   put the loc of pImageID into tLoc
   lock screen
   set the width of pImageID to tWidth
   set the height of pImageID to pHeight
   set the loc of pImage to tLoc
   unlock screen
   return tWidth
end setHeightProportional



function setWidthProportional pImageID, pWidth
   /* setWidthProportional Image
   
   Syntax:
   setWidthProportional (pImage, pWidth)
   
   Examples:
   setWidthProportional (pImage, pWidth)
   
   Description:
   Resizes an image to fit within a given width maintaining proportianally
   
   Input:
   .   pImage - the identifer of the image
   .   pWidth  - the desired pixel width of the image
   
   Return:
   .   tHeight  - the resulting height of the image after resizing
   
   Source: 
   Michael Doub
   setWidthProportional */
   local tRatio, tHeight, tLoc
   put (the formattedWidth of pImageID) / pWidth into tRatio
   put (the formattedHeight of pImageID) / tRatio into tHeight
   put the loc of pImageID into tLoc
   lock screen
   set the width of pImageID to pWidth
   set the height of pImageID to tHeight
   set the loc of pImageID to tLoc
   unlock screen
   return tHeight
end setWidthProportional


on setAreaProportional pImageID, pWidth, pHeight
   /* setAreaProportional Image
   
   Syntax:
   setAreaProportional pImage, pWidth, pHeight   # Command #
   
   Examples:
   setAreaProportional pImage, pWidth, pHeight
   
   Description:
   Resizes an image to fit within a given height and width maintaining proportianally
   
   Input:
   pImage - the identifer of the image
   pWidth  - the max pixel width of the image
   pHeight - the max pixel width of the image
   
   Return:
   "Width" - if the width dimention was scalled by ratio
   "Height" - if the height dimention was scalled by ratio
   
   Source: 
   Michael Doub
   setAreaProportional */
   local tProportionalWidth, tProportionalHeight, tRatio, tLoc
   put (the formattedWidth of pImageID) / pWidth into tRatio
   put (the formattedHeight of pImageID) / tRatio into tProportionalHeight
   put (the formattedHeight of pImageID) / pHeight into tRatio
   put (the formattedWidth of pImageID) / tRatio into tProportionalWidth
   put the loc of pImageID into tLoc
   if tProportionalHeight > pHeight then
      lock screen
      set the width of pImageID to tProportionalWidth
      set the height of pImageID to pHeight
      set the loc of pImageID to tLoc
      unlock screen
      return "Width"
   else
      lock screen
      set the width of pImageID to pWidth
      set the height of pImageID to tProportionalHeight
      set the loc of pImageID to tLoc
      unlock screen
      return "Height"
   end if
end setAreaProportional


on setProportional pImageID, pRatio
   /* setProportional Image
   
   Syntax:
   setProportional pImage, pRatio   # Command #
   
   Examples:
   setProportional pImage, pRatio
   
   Description:
   Resizes an image based on a specific ratio
   
   Input:
   .   pImage - the identifer of the image
   .   pRatio  - ratio to be multipled by current image
   
   Return:
   .   "Width" - if the width dimention was scalled by ratio
   .   "Height" - if the height dimention was scalled by ratio
   
   Source: 
   Michael Doub
   setProportional */
   local tProportionalWidth, tProportionalHeight, tLoc
   put (the formattedHeight of pImageID) * pRatio into tProportionalHeight
   put (the formattedWidth of pImageID) * pRatio into tProportionalWidth
   put the loc of pImageID into tLoc
   lock screen
   set the width of pImageID to tProportionalWidth
   set the height of pImageID to tProportionalHeight
   set the loc of pImageID to tLoc
   unlock screen
end setProportional

-- begin image_var
local sData
local sImageID
local sImageWidth
-- end image_var


function setImage pImageID
   /* setImage Image - Pixel
   
   Syntax:
   setImage (pImage_id)
   
   Examples:
   setProportional (pImage, pRatio)
   
   Description:
   This function initialized the script local variables for use by the getPixel function
   pass in the image id to be used
   
   Source: 
   Michael Doub
   setImage */
   /* include
   image_var
   */
   put pImageID into sImageID
   put the imageData of sImageID into sData
   put the width of sImageID into sImageWidth
end setImage


function getPixel pX, pY, pFlag
   /* getPixel Image - Pixel
   
   Syntax:
   getPixel (pX, pY[, pFlag])
   
   Examples:
   getPixel (pX, pY)
   getPixel (pX, pY, pFlag)
   
   Description:
   This fuction will return the data associated with a single pixel of the 
   image given the x,y coordinates of the image initialized the setImage function
   
   Input:
   .   pX  - zero is not valid
   .   pY  - zero if not valid
   .   pFlag (optional or empty - causes getPixel to return: "Red,Green,Blue"
   .   pFlag = "Encode" - causes getPixel will return the a 4 byte binary encoded 
   .       represenation of the image data
   
   Return:
   .   -1 - invalid x,y coordiant
   
   Source: 
   Michael Doub
   getPixel */
   /* Include
   image_var
   */
   local tmyindex, tSpacer, tRed, tGreen, tBlue
   if pX <= 0 or pY <=0 then return -1
   -- put ((y - 1) * theWidth * 4) + ((x - 1) * 4) into myindex
   put (((pY - 1) * sImageWidth) + pX - 1)* 4 into tmyindex
   put charToNum(char tmyindex + 1 of sData) into tSpacer
   put charToNum(char tmyindex + 2 of sData) into tRed 
   put charToNum(char tmyindex + 3 of sData) into tGreen  
   put charToNum(char tmyindex + 4 of sData) into tBlue 
   if pFlag <> "Encode" then
      return tRed & comma & tGreen & comma & tBlue
   else
      put binaryEncode("CCCC",tSpacer,tRed,tGreen,tBlue) into it
      return it
   end if
end getPixel

######################
-- never completely tested 
######################
-- copyImage - this function will return the imageID of a newly created the image that
--                      contains the image data  of the specified region for the image set by the 
--                      setImage Function
-- Input:
--           pTop
--           pLeft
--           pBottom
-- Return:
--           pImageID
--           pRight

--function copyImageData  pTop, pLeft, pBottom, pRight
--   put pBottom - pTop into tHeight
--   put pRight - pLeft into tWidth
--   put empty into tData
--   put empty into ctr
--   repeat with tY = pTop to pBottom-1
--      repeat with tX = pLeft to pRight-1
--         put getPixel (tX, tY, "Encode") after tData
--         add 1 to counter
--         put counter && the length of tData
--         beep
--      end repeat
--   end repeat
--   set the height of templateImage to tHeight
--   set the width of templateImage to tWidth
--   create image
--   set the imagedata of the last image to tData
--   return the long name of the last image
--end copyImageData

function isPosInteger pWhat,pOpt_Min,pOpt_Max,pOpt_AcceptZero
   /* isPosInteger Math
   Syntax:
   isPosInteger(pWhat,[pOpt_Min],[pOpt_Max],[pOpt_AcceptZero]
   Examples:
   isPosInteger(var)
   isPosInteger(var,10,20)
   isPosInteger(var,,true)
   
   Description:
   Determines if the container passed to it is a positive integer and optionally 
   whether if it falls within a specified range.
   
   Parameters:
   .   <pWhat> is the container to check
   .   <pOpt_Min> is an integer at the lower bound of the range (optional)
   .   <pOpt_Max> is an integer at the upper bound of the range (optional)
   .   <pOpt_AcceptZero> if "true" means that zero is accepted as a positive integer;
   
   .    if anything else is passed, or it is empty, zero is *not* considered an
   .         integer
   
   Returns:
   .   "true" if the container passed in <pWhat> is a positive integer
   .   "false" if the container passed in <pWhat> is NOT a positive integer
   
   Source:
   Ken Ray, sdtlib 1.0b
   isPosInteger */
   put (pOpt_AcceptZero = "true") into tAcceptZero
   if (pOpt_Min = "") and (pOpt_Max = "") then
      if tAcceptZero then
         return ((pWhat is an integer) and (pWhat >= 0))
      else
         return ((pWhat is an integer) and (pWhat > 0))
      end if
   else
      if (isPosInteger(pOpt_Min)  <> "") and (pOpt_Max = "") then
         return ((pWhat is an integer) and (pWhat >= pOpt_Min))
      else
         if (pOpt_Min = "") and (isPosInteger(pOpt_Max) <> "") then
            return ((pWhat is an integer) and (pWhat <= pOpt_Max))
         else
            if (isPosInteger(pOpt_Min)) and (isPosInteger(pOpt_Max)) then
               return ((pWhat is an integer) and (pWhat >= pOpt_Min) and (pWhat <= pOpt_Max))
            end if
         end if
      end if
   end if
end isPosInteger

function isEmail pWhat
   /* isEmail Misc
   Syntax:
   isEmail (string)
   
   Examples:
   isEmail("ken.ray@test.com")
   
   Description:
   Determines if the container passed to it in <what> contains a valid email address.
   Note that although it supports periods in user addresses (ken.ray@test.com),
   multiple subdomains (kenray@test.co.uk), and new domains with more than two
   characters (.info, .museum, etc.), it does not support direct IP addresses.
   
   Supports:
   periods in user address (ken.ray@test.com)
   multiple subdomains (kenray@test.co.uk)
   new domains with more than 2 characters (.info, .museum, etc.)
   IP addresses (with or without port numbers)
   
   Returns true or false.
   
   Source: 
   Key Ray
   isEmail */
   put matchText(pWhat,"^[A-z0-9_\-\.]+[@][A-z0-9_\-]+([.][A-z0-9_\-]+)+[A-z]$") into tNotIP
   put matchText(pWhat,"^(1*\d{1,2}|2[0-4]\d|25[0-5])\.(1*\d{1,2}|2[0-4]\d|25[0-5])\.(1*\d{1,2}|2[0-4]\d|25[0-5])\.(1*\d{1,2}|2[0-4]\d|25[0-5])(:\d{1,5})*$") into tIsIP
   return (tIsIP or tNotIP)
end isEmail


function isDate pWhat
   /* isDate Date
   Syntax:
   isDate (pWhat)
   Examples:
   isDate("10/10/2001")
   Description:
   Determines if the container passed to it in <pWhat> contains a valid date.
   
   Returns true or false.
   
   Source:   
   Ken Ray, sdtlib 1.0b
   isDate */
   convert pWhat to short date
   return not(the result is "invalid date")
end isDate


-- begin Extensions_vars
local sMovieExtensions="mov,mpeg,mpg,avi,swf"
local sImageExtensions="psd,gif,jpg,jpeg,pic,pict,pct,pcx,tif,tiff,png"
-- end Extensions_vars


function isImage  pPath
   /* isImage File
   Syntax:
   isImage(path)
   Examples:
   isImage(path)
   Description:
   Determines if the file at <pPath> is an image or not (based on the extensions
   list provided in sImageExtensions)
   
   Source:   
   Ken Ray, sdtlib 1.0b
   isImage */
   
   /* Include
   AssetType
   */
   
   return (AssetType(pPath) = "image")
end isImage


function isMovie pPath
   /* isMovie File
   Syntax:
   isMovie(path)
   Examples:
   isMovie(path)
   Description:
   Determines if the file at <pPath> is an movie or not (based on the extensions
   list provided in sImageExtensions)
   
   Source:   
   Ken Ray, sdtlib 1.0b
   isMovie */
   
   /* Include
   AssetType
   */
   return (AssetType(pPath) = "movie")
end isMovie


function AssetType pPath
   /* AssetType File
   Syntax:
   AssetType(path)
   Examples:
   AssetType(path)
   Description:
   Determines if the file at <pPath> is an movie or not (based on the extensions
   list provided in sImageExtensions)
   
   Note that this is the type of file, not what kind of object is needed in Rev to
   mplement that file (for example, .PSD files are identified as images, even though
   they require an rev player object to display them).
   
   Source:   
   Ken Ray, sdtlib 1.0b
   AssetType */
   
   /* Include
   Extensions_vars
   GetExtension 
   */
   put GetExtension(pPath) into tExtension
   if tExtension is among the items of sMovieExtensions then return "movie"
   if tExtension is among the items of sImageExtensions then return "image"
   return "unknown"
end AssetType


function GetExtension pPath
   /* GetExtension File
   Syntax:
   GetExtension(path)
   Examples:
   GetExtension(path)
   Description:
   Returns the extension of a file. If there is no extension, it returns empty.
   
   Source:   
   Ken Ray
   GetExtension */
   
   if matchText(pPath,"\.([^\.]*)$",tExtension) then
      return tExtension
   else
      return ""
   end if
end GetExtension


-- begin PendingMgs_var
global gStdPendingMessages
-- end PendingMgs_var


on CancelPending pWhat
   /* CancelPending Messages
   Syntax:
   CancelPending pWhat   # Command #
      Examples:
      CancelPending pWhat
      Description:
      Cancels all or a specific set of pending messages from the 'pendingMessages'.
      
      Source:   
      Ken Ray, sdtlib 1.0b
      CancelPending */
      
      if pWhat = "" then put "all" into pWhat
      switch pWhat
         case "all"
            repeat with x = (the number of lines of the pendingmessages) down to 1
               cancel (item 1 of line x of the pendingMessages)
            end repeat
            break
         default
            repeat with x = (the number of lines of the pendingmessages) down to 1
               if line x of the pendingMessages contains ("," & pWhat & ",") then
                  cancel (item 1 of line x of the pendingMessages)
               end if
            end repeat
            break
      end switch
end CancelPending


on PausePending pWhat
   /* PausePending Messages
   Syntax:
   PausePending pWhat    # Command #
      Examples:
      PausePending pWhat 
      Description:
      Pauses the current set of pending messages. Can be restarted with ResumePending.
      
      Source:   
      Ken Ray, sdtlib 1.0b
      PausePending */
      
      /* Include
      CancelPending
      */
      if pWhat = "" then put "all" into pWhat
      switch pWhat
         case "all"
            put the pendingMessages into gStdPendingMessages
            CancelPending "all"
            break
         default
            repeat with x = (the number of lines of the pendingmessages) down to 1
               if line x of the pendingMessages contains ("," & pWhat & ",") then
                  put line x of the pendingMessages &cr after gStdPendingMessages
                  cancel (item 1 of line x of the pendingMessages)
               end if
            end repeat
            delete last char of gStdPendingMessages
            break
      end switch
end PausePending


on ResumePending pWhat
   /* ResumePending Messages
   Syntax:
   ResumePending pWhat    # Command #
      Examples:
      ResumePending pWhat
      Description:
      Resumes a paused set of pending messages.
      
      Source:   
      Ken Ray, sdtlib 1.0b
      ResumePending */
      
      /* Include
      PendingMgs_var
      */
      put "" into tMsgs
      if pWhat = "" then put "all" into pWhat
      switch pWhat
         case "all"
            put gStdPendingMessages into tMsgs
            delete global gStdPendingMessages
            break
         default
            repeat with x = (the number of lines of gStdPendingMessages) down to 1
               if line x of gStdPendingMessages contains ("," & pWhat & ",") then
                  put line x of the pendingMessages &cr after tMsgs
                  delete line x of gStdPendingMessages
               end if
            end repeat
            delete last char of tMsgs
            break
      end switch
      -- Resend the messages
      repeat for each line tLine in tMsgs
         put item 3 of tLine into tCmd
         put item 4 of tLine into tTarget
         do "send" && quote & tCmd & quote && "to" && tTarget
      end repeat
end ResumePending


function Pack pData, pPassword
   /* Pack Compression/Encription
   Syntax:
   Pack(pData, [pPassword])
   Examples:
   Pack(pData)
   Pack(pData, "Password")
   Description:
   Generic functions for packing data for Internet transmission,
   with an optional modest level of password-protected security.
   
   In the simplest form, data is first compressed with gzip and
   then encoded with Base64 for robust storage or transmission.
   
   Data can be optionally protected by supplying a password,
   using a very lightweight but fast "mdx" (MD5+Xor) algorithm.
   DO NOT USE THIS ALGORITHM IF YOU REQUIRE STRONG ENCRYPTION.
   
   Source:   
   Richard Gaskin, sdtlib 1.0b
   Pack */
   
   local tMd5, tRandSeed, tMax, tOffsetsA
   local tStackName, tSaveVis, tFile
   --
   if pPassword is empty then
      -- Simply mark the data as not password-protected
      -- and compress it without further modification:
      put "00"&compress(pData) into pData
   else
      -- Get MD5 digest:
      put md5digest(pPassword) into tKeyString
      put len(tKeyString) into tKeyStringLen
      --
      put compress(pData) into pData
      --
      -- Apply it with Xor to the data one byte at a time:
      put 0 into i
      put empty into tCryptoText
      repeat for each char k in pData
         add 1 to i
         if i > tKeyStringLen then put 1 into i
         put char i of tKeyString into tKeyChar
         put  numtochar( chartonum(k) bitxor chartonum(tKeyChar))\
         after tCryptoText
         end repeat
         --
         -- Mark the data as password-protected:
         put "01" & tCryptoText into pData
      end if
      -- Convert to common low ASCII:
      return base64encode(pData)
end Pack


function Unpack pData, pPassword
   /* Unpack Compression/Encription
   Syntax:
   Unpack(pData, [pPassword])
   Examples:
   Unpack(pData)
   Unpack(pData, "Password")
   Description:
   Generic functions for ubpacking data for Internet transmission,
   with an optional modest level of password-protected security.
   
   Source:   
   Richard Gaskin, sdtlib 1.0b
   Unpack */
   
   local tEncryptionMethod
   local tMd5, tRandSeed, tMax, tOffsetsA
   --
   -- Convert from base64 back to binary:
   put base64decode(pData) into pData
   -- Check and remove password-protection flag:
   put char 1 to 2 of pData into tEncryptionMethod
   delete char 1 to 2 of pData
   --
   switch tEncryptionMethod
      case "00" --no encryption
         break
         --
      case "01" -- mdx
         -- Get MD5 digest:
         put md5digest(pPassword) into tKeyString
         put len(tKeyString) into tKeyStringLen
         --
         -- Apply it with Xor to the data one byte at a time:
         put 0 into i
         put empty into tClearText
         repeat for each char k in pData
            add 1 to i
            if i > tKeyStringLen then put 1 into i
            put char i of tKeyString into tKeyChar
            put numtochar( chartonum(k) bitxor chartonum(tKeyChar))\
            after tClearText
            end repeat
            put tClearText into pData
            break
            --
      end switch
      --
      -- Attempt to decompress data, throwing an error if not valid:
      try
         get decompress(pData)
      catch errNo
         throw "Error: Wrong password"
         exit to top
      finally
         return it
      end try
end Unpack


on append pWhat,@pToWhat,pType
   /* append Misc
   Syntax:
   append pWhat,pToWhat,[pType]   # Command #
      
      Examples:
      append pWhat,pToWhat
      append pWhat,pToWhat,"line"
      
      Description:
      Appends a value (<pWhat>) to an existing container (<pToWhat>) using
      pass-by-reference parameters. <pType> can contain "line", "item" or "word", and
      assumes "line" if not specified.
      
      Source:   
      Ken Ray, sdtlib 1.0b
      append */
      if pType = "" then
         put "line" into pType
      end if
      switch pType
         case "line"
            put pWhat into line (the number of lines of of pToWhat)+1 of pToWhat
            break
         case "item"
            put pWhat into item (the number of items of of pToWhat)+1 of pToWhat
            break
         case "word"
            -- get around a bug in Rev that does not insert spaces
            -- Can't Do: put pWhat into word (the number of words of of pToWhat)+1 of pToWhat
            put " " & pWhat after pToWhat
            break
      end switch
end append



function trim pWhat,pOpt_Position
   /* trim Text
   Syntax:
   trim (pWhat,[pOpt_Position])
   
   Examples:
   trim ("   This is a test.  ")  --> "This is a test."
   trim ("   This is a test.  ","end") --"   This is a test."
   
   Description:
   Removes white space (spaces, tabs, linefeeds, hard spaces, and returns) from
   the beginning and end of a container, or optionally only from the beginning
   (pass "left" or "begin") or end of a container (pass "right" or "end")
   
   Source:   
   Ken Ray, sdtlib 1.0b
   trim */
   if the platform is "MacOS" then put numToChar(202) into tHardSpc
   else put numToChar(160) into tHardSpc
   if pOpt_Position="" then put "both" into pOpt_Position
   put (space & tab & cr & linefeed & tHardSpc) into tWhiteSpc
   if pOpt_Position is among the items of "both,left,begin" then
      repeat
         if char 1 of pWhat is not in tWhiteSpc then exit repeat
         else delete char 1 of pWhat
      end repeat
   end if
   if pOpt_Position is among the items of "both,right,end" then
      repeat
         if char -1 of pWhat is not in tWhiteSpc then exit repeat
         else delete char -1 of pWhat
      end repeat
   end if
   return pWhat
end trim



function isWinNT
   /* isWinNT Misc
   Syntax:
   isWinNt()
   Examples:
   ff isWinNt() then ..
   Description:
   Test for WinNT
   Source:   
   Ken Ray, sdtlib 1.0b
   isWinNT */
   if the platform is not "Win32" then return false
   if word 1 of the systemVersion is "Windows" then return false
   return true
end isWinNT



function isOSX
   /* isOSX Misc
   Syntax:
   isOSX()
   Examples:
   ff isOSX() then ..
   Description:
   Test for OSX
   Source:   
   Ken Ray, sdtlib 1.0b
   isOSX */
   if the platform is not "MacOS" then return false
   get the systemversion
   set the itemdel to "."
   if item 1 of it >= 10 then return true
   return false
end isOSX



on IfX pIt
   /* IfX ShortCut
   Syntax:  
   IfX it   # Command #
   Examples:
   IfX it
   Description:
   Convenient generalized shortcut for "if it is empty then exit to top", 
   used mostly after Ask or Answer.
   Source:   
   Ken Ray, sdtlib 1.0b
   IfX */
   if pIt is empty or pIt is "Cancel" then exit to top
end IfX


function _Switch
   /* _Switch Misc
   Syntax:
   _Switch (var_to_Match,<matchValue>=<returnValue>,[<matchValue>=<returnValue>]...
   Examples:
   put "Ken" into tName
   put _Switch(tName,"Ken=male","Richard=male","Carol=female") into tGender
   --> tGender = "male"
   Description:
   Provides a quick inline switch/case against any number of tests, where the first
   parameter is what is to be evaluated, and params 2+ are in the form
   <matchValue>=<returnValue>. If there is a match against <matchValue>, it
   will return <returnValue>, otherwise it will return empty.
   
   Also see caseSwitch
   
   Source:   
   Ken Ray, sdtlib 1.0b
   _Switch */
   put param(1) into tCheckValue
   set the itemDel to "="
   repeat with x = 2 to the paramCount
      put param(x) into tCheck
      if tCheckValue = (item 1 of tCheck) then return (item 2 of tCheck)
   end repeat
   return ""
end _Switch


function StripDupes pWhat
   /* StripDupes Lines
   Syntax:
   StripDupes (pWhat)
   Examples:
   put StripDupes (pWhat) into pWhat
   Description:
   Strips the duplicates from a lined container. Each line must be an exact match for
   it to be stripped.
   
   Source:   
   Ken Ray, sdtlib 1.0b
   StripDupes */
   put "" into retVal
   put "" into uniqueLines
   repeat for each line tLine in pWhat
      if tLine is among the lines of uniqueLines then next repeat
      put tLine & cr after uniqueLines
      put tLine & cr after retVal
   end repeat
   delete last char of retval
   return retVal
end StripDupes

function StripDupLines pWhat
   /* StripDupLines Lines
   Syntax:
   StripDupLines (pWhat)
   Examples:
   put StripDupLines (pWhat) into pWhat
   Description:
   Strips the duplicates from a lined container. Each line must be an exact match for
   it to be stripped.  This uses the regular expression engine and replaceText.
   
   1
   1
   2
   return:
   1
   2
   
   Source:   
   Thierry Douez   th.douez@sunny-tdz.com
   StripDupLines */
   --return replacetext( pWhat,  "(?m)^(.*)(?=\n?\n\1)+(\n|$)" , empty)
   return replacetext( L1,  "(?m)^([^\n]*)(?=\n\1)\n" , empty)
   /*
   (?m)    go into multiline mode
   ^         assert the position at the start of the line
   (          start of 1st capure group
   [^\n]        match a char not newline
   *              between 0 and unlimited
   )          end of 1st capture group
   (?=     start of positive look ahead
   \n             match newline
   \1             the contents of the 1st capture group
   )          end of look ahead
   */
end StripDupLines

function RemoveDupLines pWhat
   /* RemoveDupLines Lines
   Syntax:
   RemoveDupLines (pWhat)
   Examples:
   put RemoveDupLines (pWhat) into pWhat
   Description:
   Returns any lines with a lined container that do not have a duplicate.
   This removes all duplicated lines. Each line must be an exact match for
   it to be stripped.  This uses the regular expression engine and replaceText.
   
   1
   1
   1
   2
   returns
   2
   
   Source:   
   Thierry Douez   th.douez@sunny-tdz.com
   RemoveDupLines */
  return replacetext( pWhat,  "(?m)^(.*)(\n?\n\1)+(\n|$)" , empty)
end RemoveDupLines


function GetCol pData,pStartCol,pOpt_EndCol,pOpt_Delim
   /* GetCol Table
   Syntax:
   GetCol (pData,pStartCol,[pOpt_EndCol],[pOpt_Delim])
   Examples:
   GetCol (pData,2)
   GetCol (pData,2,4,comma)
   Description:
   Gets one or more "columns" of data from a container. Assumes columns are
   tab-delimited unless a different character is provided in <pOpt_Delim>
   
   Source:   
   Ken Ray, sdtlib 1.0b
   GetCol */
   if pOpt_Delim = "" then put tab into tDelim
   else put pOpt_Delim into tDelim
   set the itemDel to tDelim
   if pOpt_EndCol = "" then put pStartCol into tEndCol
   else put pOpt_EndCol into tEndCol
   
   put "" into tRetVal
   repeat for each line tLine in pData
      put item pStartCol to tEndCol of tLine & cr after tRetVal
   end repeat
   return tRetVal
end GetCol


function GetExtension pPath
   /* GetExtension File
   Syntax:
   GetExtension (pPath)
   Examples:
   get GetExtension (pPath)
   Description:
   Returns the extension of a file. If there is no extension, it returns empty.
   
   Source:   
   Ken Ray, sdtlib 1.0b
   GetExtension */
   if matchText(pPath,"\.([^\.]*)$",tExtension) then
      return tExtension
   else
      return ""
   end if
end GetExtension

function FileInfo pFilePath,pOpt_InfoItem
   /* FileInfo File
   Syntax:
   FileInfo (pFilePath,[pOpt_InfoItem])
   Examples:
   get FileInfo (pFilePath)
   get FileInfo (pFilePath,"fileName")
   Description:
   Retrieves the file/folder information on a specific file/folder,
   either as a raw value or in a parseable array.
   
   If <pOpt_InfoItem> is empty, you will get back the line from the
   detailed files' in its entirety.
   
   If <pOpt_InfoItem> is one of "fileName","dataSize","resSize",
   "size" (a combination of "dataSize" and "resSize"),
   "createDate","modDate","accessDate","BUdate","ownerID", "groupID",
   "permissions","creator", "type", or "creatorType" (a combination of
   "creator" and "type"), only that value is returned.
   .    putFileInfo("/Users/ken/test.txt","creatorType")
   .    --> TTXTtext
   .
   If <pOpt_InfoItem> is "array", you get back all the items in an
   array that you can then use one of the info "keys" above to get at
   the value you're interested in, with "full" giving you the full
   detailed files line.
   .    putFileInfo("/Users/ken/test.txt","array") into tFileA
   .    put tFileA["creatorType"]
   .    --> TTXTtext
   
   Source:   
   Ken Ray, sdtlib 1.0b
   FileInfo */
   
   if pOpt_InfoItem <> "" then
      if pOpt_InfoItem is not among the items of "full,fileName,dataSize,resSize,createDate,modDate,accessDate,BUdate,ownerID,groupID,permissions,creatorType,size,creator,type,array" then
         return "StdLibError: '" & pOpt_InfoItem & "' is not a valid file property."
      end if
   end if
   set the itemDel to "/"
   put urlEncode(last item of pFilePath) into tItem
   delete last item of pFilePath
   put the directory into tOldDir
   set the directory to pFilePath
   put the detailed files into tDetailedList
   set the directory to tOldDir
   set the itemDel to ","
   put lineOffset(cr&tItem&",",cr&tDetailedList) into tLine
   put line tLine of tDetailedList into tDetailedInfo
   if pOpt_InfoItem = "" then return tDetailedInfo
   replace "," with tab in tDetailedInfo
   set the itemDel to tab
   put tDetailedInfo into tFileA["full"]
   put urlDecode(item 1 of tDetailedInfo) into tFileA["fileName"]
   put (item 2 of tDetailedInfo) into tFileA["dataSize"]
   put (item 3 of tDetailedInfo) into tFileA["resSize"]
   put (item 2 of tDetailedInfo) + (item 3 of tDetailedInfo) into tFileA["size"]
   put "createDate,modDate,accessDate,BUdate" into tDates
   replace "," with tab in tDates
   repeat with x = 4 to 7
      put item x of tDetailedInfo into tSecs
      if tSecs <> "" then convert tSecs to short date and time
      put tSecs into tFileA[(item x-3 of tDates)]
   end repeat
   put (item 8 of tDetailedInfo) into tFileA["ownerID"]
   put (item 9 of tDetailedInfo) into tFileA["groupID"]
   put (item 10 of tDetailedInfo) into tFileA["permissions"]
   put (item 11 of tDetailedInfo) into tFileA["creatorType"]
   put (char 1 to 4 of item 11 of tDetailedInfo) into tFileA["creator"]
   put (char 5 to 8 of item 11 of tDetailedInfo) into tFileA["type"]
   
   if pOpt_InfoItem = "array" then
      return tFileA
   else
      return tFileA[pOpt_InfoItem]
   end if
end FileInfo

function lastItem p,d
   /* lastItem Misc
   Syntax:
   lastItem (string,[delimeter])
   Examples:
   get lastItem (string)
   get lastItem (string,tab)
   Description:
   Returns the last item of a string, when the delimiter may be optionally set
   defaults is "/"
   
   Source:   
   Michael Doub
   lastItem */
   if d is not empty then
      set the itemDel to d
   else
      set the itemDel to "/"
   end if
   return last item of p
end lastItem


function AppPath pAppStack
   /* AppPath Misc
   Syntax:
   AppPath ([pAppStack])
   Examples:
   get AppPath ()
   get AppPath ([pAppStack])
   Description:
   Returns the full path to the folder that contains the curent application.
   But since an "application" means different things at runtime and in development,
   this function supports ways to identify which stack file to reference when
   getting the path:
   
   By default, AppPath() will use the fileName of the defaultStack.
   
   If you don't want to rely on that, you can be more explicit, spassing a param 
   to identify the app stack.
   
   Source:   
   Ken Ray, sdtlib 1.0b
   AppPath */
   /* Include
   AppStack
   */
   put AppStack(pAppStack) into tStack
   put the effective filename of stack tStack into tPath
   --
   if (the platform is "MacOS") AND ("dev" is not in the environment) then
      if IsOSX() then
         set the itemdel to "/"
         get offset(".app/Contents/MacOS/", tPath)
         if it > 0 then -- account for bundle:
            delete char it to len(tPath) of tPath
         end if
      end if
   end if
   --
   set the itemdel to "/"
   put empty into last item of tPath
   return tPath
end AppPath


Private function AppStack pAppStack
   -- Called by AppPath, this function returns the short name of the stack
   -- used as the current application.
   if there is a stack pAppStack then
      put the short name of stack pAppStack into tStack
   else
      put the short name of the defaultstack into tStack
   end if
   return tStack
end AppStack

#
# Name....... : CSV Parser
# Version.... : 1.0.0
# Authour.... : Shao Sean <info@shaosean.tk>
# Description : Library to parse CSV files
#
# 1.0.0 - initial release
#
#
#                          Public Domain Disclaimer
#
# This software was developed by Shao Sean and is available
# for use by the public without need of a license.
# THE SOFTWARE AND RELATED MATERIALS ARE PROVIDED "AS-IS" WITHOUT WARRANTY OR INDEMNITY
# OF ANY KIND INCLUDING ANY WARRANTIES OF USE, PERFORMANCE OR MERCHANTABILITY OR FITNESS
# FOR A PARTICULAR USE OR PURPOSE OR FOR ANY PURPOSE WHATSOEVER. USER BEARS ALL RISK RELATING
# TO USE, QUALITY AND PERFORMANCE OF THE SOFTWARE.
#

-- begin CSV_var
local sDataA
local sFields
local sLineBuffer
local ix
-- end CSV_var

function CSVtoArray pData
   /* CSVtoArray Table
   Syntax:
   CSVtoArray(pData,[firstRowIsHeaders])
   
   Examples:
   put CSVtoArray(pData) into  anArray
   put CSVtoArray(pData,true) into  anArray  -- with header row
   
   Description: 
   Parses the CSV data into a multi-dimensional array
   
   Input:
   pData                     raw csv data
   firstRowIsHeaders  optional; boolean
   
   Returns:
   array; first element is the row number, second element is column number/name
   
   Source: 
   Shao Sean
   CSVtoArray */
   
   /* Include
   CSV_var
   _parseLine
   _parseLineQ
   */
   local j = 1
   local tInQuotes
   
   put EMPTY into sDAtaA
   put EMPTY into sFields
   put EMPTY into sLineBuffer
   put 0 into ix
   
   replace QUOTE & QUOTE with numToChar(5) in pData
   
   --- first line is flagged as header line
   if (paramCount() = 2) AND (param(2) = TRUE) then
      put line 1 of pData into sFields
      delete line 1 of pData
   end if
   
   --- process the CSV data
   repeat for each line tLine in pData
      
      --- skip empty lines
      if (tLine is EMPTY) then
         next repeat
      end if
      
      --- no quotes, single line
      if (not tLine contains QUOTE) AND (tInQuotes is FALSE) then
         _parseLine tLine
         next repeat
      end if
      
      --- quotes
      put tLine & "\n" after sLineBuffer
      set the itemDelimiter to QUOTE
      if (the number of items of sLineBuffer MOD 2 = 0) then     -- multiple lines
         next repeat
      end if
      
      delete char -2 to -1 of sLineBuffer
      _parseLineQ sLineBuffer
   end repeat
   
   if (sLineBuffer is not EMPTY) then        -- process the last buffered quoted multi-line
      delete char -2 to -1 of sLineBuffer     -- remove the extra trailing "\n"
      _parseLineQ sLineBuffer
   end if
   
   return sDataA
end CSVtoArray



private command _parseLine pLine
   local j=1
   add 1 to ix
   repeat for each item tItem in pLine
      if (sFields is not EMPTY) then
         if (tItem = numToChar(5)) then
            put EMPTY into sDataA[ix][item j of sFields]
         else
            put tItem into sDataA[ix][item j of sFields]
            replace "\n" with LF in sDataA[ix][item j of sFields]
            replace QUOTE with EMPTY in sDataA[ix][item j of sFields]
            replace numToChar(4) with COMMA in sDataA[ix][item j of sFields]
            replace numToChar(5) with QUOTE in sDataA[ix][item j of sFields]
         end if
      else
         if (tItem = numToChar(5)) then
            put EMPTY into sDataA[ix][j]
         else
            put tItem into sDataA[ix][j]
            replace "\n" with LF in sDataA[ix][j]
            replace QUOTE with EMPTY in sDataA[ix][j]
            replace numToChar(4) with COMMA in sDataA[ix][j]
            replace numToChar(5) with QUOTE in sDataA[ix][j]
         end if
      end if
      add 1 to j
   end repeat
end _parseLine



private command _parseLineQ pLine
   local tInQuotes
   local k = 1
   local temp
   
   repeat for each item tItem in pLine
      if (char 1 of tItem = QUOTE) AND (char -1 of tItem = QUOTE) then     -- start of a quoted string with no commas
         put char 2 to -2 of tItem & COMMA after temp
      else if (char 1 of tItem = QUOTE) AND (char -1 of tItem <> QUOTE) then     -- start of a quoted string containing commas
         put TRUE into tInQuotes
         put char 2 to -1 of tItem & numToChar(4) after temp
      else if (char 1 of tItem <> QUOTE) AND (char -1 of tItem = QUOTE) then     -- end of a quoted string containing commas
         put FALSE into tInQuotes
         put char 1 to -2 of tItem & COMMA after temp
      else if (tInQuotes is TRUE) then
         put tItem & numToChar(4) after temp
      else
         put tItem & COMMA after temp
      end if
   end repeat
   _parseLine temp
   put EMPTY into sLineBuffer
end _parseLineQ


function centerOfRect recta
   /* centerOfRect Graphics
   Syntax:
   centerOfRect (x)
   Examples:
   get  centerOfRect ("0,0,200,200")
   Description:
   Calculates the point that's at the center of a rectangle.
   recta =  "left,top,right,bottom" of a rectangle or "the rect"
   Source:
   Michael Doub
   centerOfRect */
   put item 3 of recta - item 1 of recta into twidth
   put item 4 of recta - item 2 of recta into theight
   return round(item 1 of recta + twidth/2) , round(item 2 of recta + theight/2)
end centerOfRect

function isConnectedToInternet pURL, fail_dialog
   /* isConnectedToInternet Internet
   Syntax:
   isConnectedToInternet (pURL, [fail_dialog])
   Examples:
   if isConnectedToInternet ()
   if isConnectedToInternet (pURL) then ...
   if isConnectedToInternet (pURL, "Yes") then ...  -- Dialog on Connection problem
   Description:
   Test if connected to the internet.   Returns true or false
   Displaying a dialog is optional
   
   Source:
   Adapted from Chipp Walters, Rev List 19-DEC-2004
   isConnectedToInternet */
   if pURL is empty then put "http://www.google.com" into pURL
   get URL pURL
   put the result into tResult
   if tResult is not empty then
      if fail_dialog = "Yes" then
         answer information "Problem connecting to the internet: "& tResult
      end if
      return false
   else
      return true
   end if
end isConnectedToInternet

on ccValidate pNum,@CardType,@Validity
   /* ccValidate Misc
   Syntax:
   ccValidate pNum,CardType,Validity   # Command #
   Examples:
   ccValidate pNum,CardType,Validity
   Description:
   Given a credit card number, get the card type and if it is a valid number
   It does not check if the card is stolen, has expired or is otherwise suspect.
   
   Input:
   .   pNum - the credit card number
   
   Output:
   .    CardType = VISA,MASTERCARD,DISCOVER,AMERICANEXPRESS,DINNERSCLUB,JCB or
   .         UNKNOWN CARD TYPE
   .    Validity = "valid card number" or "invalid card number"
   
   Source:  
   Hugh Senior 
   ccValidate */
   replace space with "" in pNum
   replace "-" with "" in pNum
   if (pNum is NOT a number) then
      put "Not a card number" into CardType
      put "Unable to validate" into Validity
   else
      --| Card identification by regex...
      local isVisa ="^(?:4[0-9]{12}(?:[0-9]{3})?)$"
      local isMasterCard= "^(?:5[1-5][0-9]{14})$"
      local isDiscover ="^(?:6(?:011|5[0-9][0-9])[0-9]{12})$"
      local isAMEX ="^(?:3[47][0-9]{13})$"
      local isDinersClub ="^(?:3(?:0[0-5]|[68][0-9])[0-9]{11})$"
      local isJCB ="^(?:(?:2131|1800|35\d{3})\d{11})$"
      if matchText(pNum,isVisa) then put "VISA" into CardType
      else if matchText(pNum,isMasterCard) then put "MASTERCARD" into CardType
      else if matchText(pNum,isDiscover) then put "DISCOVER" into CardType
      else if matchText(pNum,isAMEX) then put "AMERICANEXPRESS" into CardType
      else if matchText(pNum,isDinersClub) then put "DINERSCLUB" into CardType
      else if matchText(pNum,isJCB) then put "JCB" into CardType
      else put "UNKNOWN CARD TYPE" into CardType
      --| Checksum verification by Luhn algorithm...
      put len(pNum) into tLen
      repeat with z = 1 to tLen
         put char -z of pNum into n
         if z mod 2 =0 then
            put n*2 into n
            if n <10 then add n to stdout
            else add (n mod 10) +1 to stdout
         else
            add n to stdout
         end if
      end repeat
      if (stdout mod 10 =0) then put "valid card number" into Validity
      else put "invalid card number" into Validity
   end if
end ccValidate

function Clip fLow,fN,fHigh
   /* Clip Math
   Syntax:
   Clip (fLow,fN,fHigh)
   Examples:
   get Clip (0,fN,100)
   Description:
   Clips the number fN to be within fLow and fHigh
   Clip */
   
   if fN<fLow  then return fLow
   if fN>fHigh then return fHigh
   return fN
end Clip

function deleteColumns pData,pColsToDelete,pDelim
   /* deleteColumns Table
   Syntax:
   deleteColumns (<data>,<cols>[,<delim>])
   Examples:
   put deleteColumns (data_string,"2,4") into data_string2
   put deleteColumns (data_string,"2,3","/") into data_string2
   Description:
   delete specified columns from a table
   
   .     data: Specifies the data to parse.
   .     cols: A comma separated list of columns or column ranges to be removed,
   .         for example "2,5,7"
   .         or a column range: "3-5"
   .         or a combination "2,4-5,7,9-11,"
   .     delim: Optional column separator for example "," or "|"
   .         if unspecified, defaults to tab.
   
   Source:
   based on a handler by Hugh Senior and Peter M. Brigham, Use-LC list
   deleteColumns */
   /* Include
   getItem
   */
   
   if pColsToDelete = empty then return pData
   replace space with empty in pColsToDelete
   repeat for each item pCol in pColsToDelete
      if "-" is in pCol then 
         put getItem(pCol,1,"-") into firstColNbr
         put getItem(pCol,2,"-") into lastColNbr
         repeat with i = firstColNbr to lastColNbr
            put i & comma after pColsToDeleteExpanded
         end repeat
      else
         put pCol & comma after pColsToDeleteExpanded
      end if
   end repeat
   put char 1 to -2 of pColsToDeleteExpanded into pColsToDelete
   if pDelim = empty then put tab into pDelim
   set the columnDelimiter to pDelim
   split pData by column
   put item 2 of extents(pData) into tMax
   repeat with n=1 to tMax
      if n is NOT among the items of pColsToDelete then
         add 1 to x
         put pData[n] into pData[x]
      end if
   end repeat
   repeat with n=x+1 to tMax
      delete local pData[n]
   end repeat
   combine pData by column
   return pData
end deleteColumns


function walkDir dirPath, invis
   /* walkDir File
   Syntax:
   walkDir (dirPath, invis)
   Examples:
   get walkDir (dirPath)
   get walkDir (dirPath, true)
   Description:
   This recursive function expects a folder path.
   It returns a file list for that folder and for each sub-folder it contains (pre-order search).
   if invis is NOT empty then invisible files are excluded.
   walkDir */
   put empty into tList
   set defaultFolder to dirPath
   put the long files into fList
   repeat for each line fLine in fList
      if invis is empty then
         if char 1 of fLine <> "." then
            put item 1 of fLine into fData
            put dirPath & "/" & fData & return after tList
         end if
      else
         put item 1 of fLine into fData
         put dirPath & "/" & fData & return after tList
      end if
   end repeat
   get the folders
   repeat for each line x in it
      if char 1 of x <> "." then
         put walkDir(dirPath & "/" & x) after tList
      end if
   end repeat
   return tList
end walkDir

-- begin RaspberryPi_var
/*
How to solve the Accessing the GPIO (of a raspberry pi) without "sudo" problem:
1)   edit /etc/rc.local   (sudo nano /etc/rc.local)
2)   add the following 2 lines near the end, but in front of the last line (exit 0)
           chgrp -R dialout /sys/class/gpio
           chmod -R g+rw /sys/class/gpio
3)   save the file
4)   reboot
*/

constant good_pins = "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,32" 
constant good_values = "0,1"
constant good_directions = "in,out"
global gpio
-- end RaspberryPi_var


on Pi_gpio_output nbr val
   /* Pi_gpio_output RaspberryPi
   Syntax:
   Pi_gpio_output nbr, val   # Command #
   Examples:
   Pi_gpio_output 2, 1
   Pi_gpio_output 2, 0
   Description:
   Output to the gpio nbr, with value of val
   nbr is one of the gpio pins:  "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,32" 
   val is 1 or 0
   
   Source:
   Michael Doub
   Pi_gpio_output */
   /* Include
   RaspberryPi_var
   Pi_gpio_init
   */
   
   local value_path
   if nbr is not among the items of good_pins then return "error: invalid pin nbr"
   if val is not among the items good_values then return "error: invalid value"
   if the platform is "Linux" then
      put ("/sys/class/gpio/gpio" & nbr & "/value") into value_path
      if there is not a file value_path then return "error:" &&  value_path && "does not exist"
       open file value_path for write
       write val to file value_path
       close file value_path
   end if
   put val into gpio[nbr]["value"]
   return empty
end Pi_gpio_output

on Pi_gpio_input nbr
   /* Pi_gpio_input RaspberryPi
   Syntax:
   Pi_gpio_input nbr   # Command #
   Examples:
   Pi_gpio_input 2
   
   Description:
   Input from the gpio nbr
   nbr is one of the gpio pins:  "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,32" 
   
   Source:
   Michael Doub
   Pi_gpio_input */
   /* Include
   RaspberryPi_var
   Pi_gpio_init
   */
   
   local value_path
   if nbr is not among the items of good_pins then return "error: invalid pin nbr"
   if the platform is "Linux" then
      put ("/sys/class/gpio/gpio" & nbr & "/value") into value_path
      if there is not a file value_path then return "error:" &&  value_path && "does not exist"
       open file value_path
       read from file value_path until EOF
       close file value_path
   end if
   return it
end Pi_gpio_input


on Pi_gpio_init nbr dir
   /* Pi_gpio_init RaspberryPi
   Syntax:
  Pi_gpio_init nbr, dir   # Command #
   Examples:
   Pi_gpio_init 2, "in"
   Pi_gpio_init 2, "out"
   Description:
   Initialize the gpio and set the direction of the operation
   nbr is one of the gpio pins:  "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,32" 
   dir is "in" or "out"
   
   Source:
   Michael Doub
   Pi_gpio_init */
   /* Include
   RaspberryPi_var
   Pi_gpio_output
   */
   local cmd, direction_path
   if nbr is not among the items of good_pins then return "error: invalid pin nbr"
   if lower(dir) is not among the items of good_directions then return "error: invalid direction"
   if the platform is "Linux" then
      put ("/sys/class/gpio/gpio" & nbr & "/direction") into direction_path
      if there is not a file direction_path then 
         put "echo" && nbr && "> /sys/class/gpio/export" into cmd
         get shell (cmd)
         if it is not empty then return "error:" & it
      end if
      if there is not a file direction_path then return "error:" &&  direction_path && "does not exist"
      open file direction_path for write
      write dir to file direction_path
      close file direction_path
   end if
   put dir into gpio[nbr][direction]
   return empty
end Pi_gpio_init

function FLCcalendar tStartDayNum,tM,tY
   /* FLCcalendar Misc
   Syntax:
   FLCcalendar (<startDay 1-7>, <Month 1-12>,<Year 1970-2037>)
   Examples:
   put random(7) into weekStartsOn
   put random(12) into tMonth
   put random(67) +1969 into tYear
   put FLCcalendar(weekStartsOn,tMonth,tYear) into cd fld "Calendar"
   Description:
   Gives a language-localized calendar with selectable first day of week
   display with mono-spaced font to have correct allignment
   
   tstartDayNum controls the starting day of the week.   1 will cause the week to start with Sun,
   2 will cause the week to start on Mon
   
   Source:
   Hugh Senior
   FLCcalendar */
   put the system monthNames into tMonthNames
   get the abbrev system WeekDayNames
   repeat for each line L in it
      if len(L) is 2 then put space & L into L
      put char 1 to 3 of L &cr after tAbbrevWeekDayNames
   end repeat
   delete last char of tAbbrevWeekDayNames
   # Verify params...
   put tM &"/1/"& tY into tCalendarMonth
   convert tCalendarMonth to dateItems
   if the result <>"" then return "Date error"
   put item 1 of tCalendarMonth into tY
   # Build Calendar title...
   put line (item 2 of tCalendarMonth) of tMonthNames && tY into monthHeader
   # Build Calendar day header line, starting from selected day of the week...
   put tAbbrevWeekDayNames into dayHeader
   put (line tStartDayNum to -1 of dayHeader)&cr&(line 1 to tStartDayNum -1 of dayHeader) into dayHeader
   replace cr with space in dayHeader
   # To centre the monthHeader...
   put char 1 to round((length(dayHeader)-length(monthHeader)) div 2) +1 of "                    " before monthHeader
   # Build Calendar...
   put empty into days
   if tStartDayNum is 1 then put 7 into tEndDayNum
   else put tStartDayNum -1 into tEndDayNum
   # Calculate position of first date...
   put (item 7 of tCalendarMonth) - (tStartDayNum)+1 into dayOffset
   if dayOffset < 1 then put (7+ dayOffset) into dayOffset
   repeat with dayNum = 1 to dayOffset -1
      put "    " after days
   end repeat
   # Complete Calendar...
   repeat while item 2 of tCalendarMonth is tM
      get " " & item 3 of tCalendarMonth & " "
      if length(it) is 3 then get " " & it
      if item 7 of tCalendarMonth is tEndDayNum then get it & cr
      put it after days
      add 1 to item 3 of tCalendarMonth
      convert tCalendarMonth from dateItems to long system date -- to force next line to update
      convert tCalendarMonth from long system date to dateItems
   end repeat
   return monthHeader & cr &  dayHeader & cr & days & cr
end FLCcalendar

function FormatMoney pAmt
   /* FormatMoney Text
   Syntax:
   FormatMoney(amt)
   Examples:
   put FormatMoney(10000000.00)
   Description:
   Formats a number with $ and , for money.
   Example  10000000.00 -->$10,000,000.00
   FormatMoney */
   
   split pAmt by "."
   -- pAmt[1] contains the dollars, pAmt[2] contains the cents
   if pAmt[2] = "" then put "00" into pAmt[2]
   if length(pAmt[2]) = 1 then put "0" after pAmt[2]
   
   put trunc(length(pAmt[1])/3) into tNumLoops
   put "" into tDollars
   repeat tNumLoops
      put "," & char -3 to -1 of pAmt[1] before tDollars
      delete char -3 to -1 of pAmt[1]
   end repeat
   
   put pAmt[1] & tDollars & "." & pAmt[2] into tRetVal
   -- remove a preceding comma if an even multiple of 3
   if char 1 of tRetVal = "," then delete char 1 of tRetVal
   
   return "$" & tRetVal
end FormatMoney

on createPath pPath
   /* createPath File
   Syntax:
   createPath pPath   # Command #
   Examples:
   createPath pPath
   Description:
   This handler creates all of the folders in the designated path.  if the last
   item of the path contains a "." this is assumed to be the filename and
   it is ignored.
   Source:
   Michael Doub
   createPath */
   /* Include
   err
   */
   set the itemDelimiter to "/"
    if the last item of pPath contains "." then delete the last item of pPath
   repeat with n = 1 to the number of items in pPath
      if item n of pPath is not empty AND there is no folder (item 1 to n of pPath) then
         create folder (item 1 to n of pPath)
         Err the result, "Couldn't create folder "& quote & item 1 to n of pPath & quote
      end if
   end repeat
end createPath


on DeleteCustomPropertyFromSet pObject, pSet, pProperty
   /* DeleteCustomPropertyFromSet Properties
   Syntax:
   DeleteCustomPropertyFromSet pObject, pSet, pProperty   # Command #
   Examples:
   DeleteCustomPropertyFromSet button "foo", "mySet", "myProperty"
   Description:
   shortcut for deleting a custom property from a custom propery set
   .   pObject is the owner of the properties
   .   pSet is the name of the custom property set
   .   pProperty is the name of the custom property
   
   Source:
   Michael Doub
   DeleteCustomPropertyFromSet */
   local tPropertiesA
   put the customProperties[pSet] of pObject into tPropertiesA
   delete variable tPropertiesA[pProperty]
   set the customProperties[pSet] of pObject to tPropertiesA
end DeleteCustomPropertyFromSet

on setCustomProp pObject,pSet,pProp,pValue
   /* setCustomProp Properties
   Syntax:
   setCustomProp pObject,pSet,pProp,pValue   # Command #
   Examples:
   setCustomProp pObject,pSet,pProp,pValue
   Description:
   Set the value of propterty pProp of set pSet to pValue
   Source:
   setCustomProp */
   /* Include
   getCustomProp
   */
   put the custompropertyset of pObject into oldPropSet
   set the custompropertyset of pObject to pSet
   set the pProp of pObject to pValue
   set the custompropertyset of pObject to oldPropSet
end setCustomProp

function getCustomProp pObject,pSet,pProp
   /* getCustomProp Properties
   Syntax:
   getCustomProp (pObject,pSet,pProp)
   Examples:
   get getCustomProp (pObject,pSet,pProp)
   Description:
   returns the value of propterty pProp of set pSet 
   Source:
   getCustomProp */
   /* Include
   setCustomProp
   */
   
   put the custompropertyset of pObject into oldPropSet
   set the custompropertyset of pObject to pSet
   put the pProp of pObject into pValue
   set the custompropertyset of pObject to oldPropSet
   return pValue
end getCustomProp

on DeleteCustomPropertySet pObject, pSet
   /* DeleteCustomPropertySet Properties
   Syntax:
   DeleteCustomPropertySet pObject, pSet   # Command #
   Examples:
   DeleteCustomPropertySet button "foo", "mySet"
   Description:
   shortcut for deleting a whole custom property set
   .   pObject is the owner of the properties
   .   pSet is the name of the custom property set
   
   Source:
   Michael Doub
   DeleteCustomPropertySet */
   
   local tSets
      put the customPropertySets of pObject into tSets
      set the wholeMatches to true
      delete line lineOffset(pSet,tSets) of tSets
      set the customPropertySets of pObject to tSets
end DeleteCustomPropertySet

on downloadSaveNGo pStackPath, pURL, pForce
   /* downloadSaveNGo Internet
   Syntax:
   downloadSaveNGo pStackPath, pURL   # Command #
   Examples:
   downloadSaveNGo pStackPath, pURL
   downloadSaveNGo pStackPath, pURL, true
   Description:
   This routine will load a pStackPath if there is a file present and the pForce
   parameter is not present.   If the file is not present or the pForce parameter is present
   the the file will be downloaded from pURL into pStackPath and then opened.
   
   Both pStackPath and pUrl are complete paths including the filename
   
   Source:
   downloadSaveNGo */
   
   if pForce <> true and there is a file pStackPath then
      open stack pStackPath
   else
      put URL pURL into URL ("binfile:" & pStackPath)
      put the result into tResult
      if tResult is not empty then
         answer warning tResult
      end if
      if there is a stack pStackPath then
         open stack pStackPath
      else
         answer warning "Can't find the file: " & pStackPath
      end if
   end if
end downloadSaveNGo


function lineOffsets str,@ctr
   /* lineOffsets Text Items
   Syntax:
   lineoffsets (string,container)
   Examples:
   put "Hello World" & cr & "World of Goo" & cr & "GoodBye Cruel World" & cr into x
   if lineoffsets("World",x) <> "1,2,3" then throw "problem"
   Description:
   returns a comma-delimited list of all the line offsets of str in cntr
   cntr is passed by reference to avoid unnecessary duplication
   of very large text blocks in memory
   
   cntr contents are not altered by this function
   lineOffsets */
   /* Include
   offsets
   */
   put offsets(str,ctr) into charList
   if charList = "0" then return "0"
   put "" into offsetList
   repeat for each item i in charList
      put the number of lines of (char 1 to i of ctr) & "," after offsetList
   end repeat
   delete char -1 of offsetList
   return offsetList
end lineOffsets

function itemOffsets str,@ctr, delim
   /* itemOffsets Text Items
   Syntax:
   itemOffsets str,@ctr, [delim]
   Examples:
   put "Hello World" & comma & "World of Goo" & comma & "GoodBye Cruel World" & cr into x
   if itemoffsets("World",x) <> "1,2,3" then throw "problem"
   put "Hello World" & tab & "World of Goo" & tab & "GoodBye Cruel World" & cr into x
   if itemoffsets("World",x,tab) <> "1,2,3" then throw "problem 2"
   Description:
   returns a comma-delimited list of all the item offsets of str in cntr
   cntr is passed by reference to avoid unnecessary duplication
   of very large text blocks in memory
   
   cntr contents are not altered by this function
   delim is the item delimeter, comma is default
   
   itemOffsets */
   /* Include
   offsets
   */
   
   put offsets(str,ctr) into charList
   if charList = "0" then return "0"
   put "" into offsetList
   repeat for each item i in charList
      if delim is not empty then set itemdel to delim
      put the number of items of (char 1 to i of ctr) & "," after offsetList
      set the itemdel to comma
   end repeat
   delete char -1 of offsetList
   return offsetList
end itemOffsets


function _Floor pValue
   /* _Floor Math
   Syntax:
   _Floor (pValue)
   Examples:
   if _Floor(1.1) <> 1 then throw "problem"
   if _Floor(1) <> 1 then throw "problem"
   Description:
   The floor  function gives you the nearest integer down.
   The floor of a number that is already an integer is the integer itself...no change.
   
   This is a builtin function for LiveCode 7.1 and higher
   _Floor */
   
   if pValue is an integer OR pValue > 0 then return trunc(pValue)
   else return trunc(pValue) - 1
end _Floor

function _Ceiling pValue
   /* _Ceiling Math
   Syntax:
   _Ceiling (pValue)
   Examples: 
   if _Ceiling(1.1) <> 2 then throw "problem"
   if _Ceiling(1) <> 1 then throw "problem"
   Description:
   The Ceiling  function gives you the nearest integer up.
   The floor of a number that is already an integer is the integer itself...no change.
   
   This is a builtin function for LiveCode 7.1 and higher
   _Ceiling */
   
   if pValue is an integer OR pValue < 0 then return trunc(pValue)
   else return trunc(pValue) + 1
end _Ceiling

function Hex fN
   /* Hex Math
   Syntax:
   Hex(nbr_between_0_and_255)
   Examples:
   if Hex(0) <> 0 then throw "problem"
   if Hex(255) <> "FF" then throw "problem"
   Description:
   return the hexadecimal value of fN, which is between 0 and 255:
   Hex */
   
   return (char (fN div 16)+1 of "0123456789ABCDEF") & (char (fN mod 16)+1 of "0123456789ABCDEF")
end Hex

function html2text pHtml
   /* html2text Text
   Syntax:
   html2text (text)
   Examples:
   html2text (text)
   Description:
   To strip HTML tags from text and return only the text
   html2text */
   put the htmlText of the templateField into tSaveData
   set the htmlText of the templateField to pHtml
   get the text of the templateField
   set the htmlText of the templateField to tSaveData
   return it
end html2Text

function getTaggedList tStartTag, tEndTag, @StringToSearch
   /* getTaggedList Text Items
   Syntax:
   getTaggedList (tStartTag, tEndTag, StringToSearch)
   Examples:
   put getTaggedList("<record>", "</record>", yourText) into theArray
   Description:
   returns an array of the contents between a start_tag and an end_tag,  
   Each element of the array is an occurance of the tag pair 
   getTaggedList */
   put empty into tArray
   put 0 into tStart1
   put 0 into tStart2
   put 1 into tElementNum
   put the number of chars in tStartTag into dChars
   repeat
      put offset(tStartTag,StringToSearch,tStart1) into tNum1
      put (tNum1 + tStart1) into tStart1
      if tNum1 < 1 then exit repeat
      put offset(tEndTag,StringToSearch,tStart2) into tNum2
      put (tNum2 + tStart2) into tStart2
      if tNum2 < 1 then exit repeat
      --if tNum2 < tNum1 then exit repeat
      put char (tStart1 + dChars) to (tStart2 - 1) of StringToSearch into zapped
      put zapped into tArray[tElementNum]
      add 1 to tElementNum
   end repeat
   return tArray
end getTaggedList

function getTaggedElement tStTag, tEdTag, @stngToSch
   /* getTaggedElement Text Items
   Syntax:
   getTaggedElement (tStTag, tEdTag, stngToSch)
   Examples:
   put getTaggedElement("<record>", "</record>", yourText) into theElement
   Description:
   returns the contents beween the first start_tag and end_tag
   getTaggedElement */
   
   put empty into zapped
   put the number of chars in tStTag into dChars
   put offset(tStTag,stngToSch) into tNum1
   put offset(tEdTag,stngToSch) into tNum2
   if tNum1 < 1 then
      return "error"
      exit getTaggedElement
   end if
   if tNum2 < 1 then
      return "error"
      exit getTaggedElement
   end if
   put char (tNum1 + dChars) to (tNum2 - 1) of stngToSch into zapped
   return zapped
end getTaggedElement

function PrintKeys @pArray,delim, theKeyList, pFullData
   /* PrintKeys Debugging
   Syntax:
   PrintKeys(pArray,[delim])
   Examples:
   put PrintKeys(pArray)
   put PrintKeys(pArray,"'")
   Description:
   Prints the keys of pArray 
   
   Source: 
   Bob Sneidar
   PrintKeys */
   put numtochar(11) into vertTab
   put numtochar(30) into altCr
   put the keys of pArray into theKeys
   sort theKeys numeric
   
   repeat for each line theKey in theKeys
      put "[" & theKey & "] " after theKeyList
      if theKey is not a number then
         replace "[" & theKey & "]" with "[" & quote & theKey & quote & "]" in theKeyList
      end if
      if pArray[theKey] is an array then
         put pArray[theKey] into theTempArray
         put PrintKeys(theTempArray,delim, theKeyList, pFullData) after theText
         put empty into the last word of theKeyList
         delete the last char of theKeyList
         put cr into the last char of theText
      else
         put "pArray " & the last word of theKeyList into theKeyName
         -- put "put " & theKeyName & " into theValue" into theCommand
         -- do theCommand
         put delim & the value of theKeyName  & delim into theValue
         replace tab with vertTab in theValue
         replace return with altCr in theValue
         put theKeyList & tab & theValue & comma after theText
         put empty into the last word of theKeyList
         delete the last char of theKeyList
      end if
   end repeat
   return theText
end PrintKeys

function withinTriangle x1,y1,x2,y2,x3,y3,px,py
   /* withinTriangle Graphics
   Syntax:
   withinTriangle (x1,y1,x2,y2,x3,y3,px,py)
   Examples:
   if withinTriangle(0,0,0,20,10,10,5,5) <> true then throw "problem"
   Description:
   x1 / y1 to x3 / y3 define the triangle,
   pX and pY are the point to check
   withinTriangle */
   /* include
   _area
   */
   
   local area1,area2
   put _area(x1,y1,x2,y2,px,py) + _area(x2,y2,x3,y3,px,py) + _area(x3,y3,x1,y1,px,py) into area1
   put _area(x1,y1,x2,y2,x3,y3) into area2
   return abs(area1-area2)<0.000000000001
end withinTriangle

Private function _area x1,y1,x2,y2,x3,y3
   return abs(x1*y2+x2*y3+x3*y1-x1*y3-x3*y2-x2*y1)/2
end _area



Function YxyToXYZ Yxz
   /* YxyToXYZ Color
   Syntax:
   YxyToXYZ ("YY,X,Y") 
   Examples:
   
   Description:
   Color space conversion: Yxy -->XYZ
   
   YY from 1 to 100
   X   from 0 to 1
   Y   from 0 to 1
   
   Input:
   .   "YY,X,Y"
   
   Output:
   .   "X,Y,Z"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   YxyToXYZ */
   
   set itemdel to comma
   put item 1 of Yxz into in_YY
   put item 2 of Yxz into in_x
   put item 3 of Yxz into in_y
   put in_x * (in_YY / in_y) into out_X
   put in_YY into out_Y
   put (1 - in_x - in_y) * (in_YY / in_y) into out_Z
   return out_X & comma & out_Y & comma & out_Z
end YxyToXYZ


Function XYZtoYxy  XYZ
   /* XYZtoYxy Color
   Syntax:
   XYZtoYxy  ("X,Y,Z") 
   Examples:
   
   Description:
   Color space conversion: XYZ -->Yxy
   
   .    X from 0 to 95.047       Observer. = 2°, Illuminant = D65
   .    Y from 0 to 100.000
   .    Z from 0 to 108.883
   
   Input:
   .   "X,Y,Z"
   
   Output:
   .   "Y,X,Z"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   XYZtoYxy */
   
   set itemdel to comma
   put item 1 of XYZ into X
   put item 2 of XYZ into Y
   put item 3 of XYZ into Z
   put Y into out_YY
   put X / ( X + Y + Z ) into out_X
   put Y / ( X + Y + Z ) into out_Y
   return out_YY & comma & out_X & comma & out_Y
end XYZtoYxy


Function XYZtoRGB XYZ
   /* XYZtoRGB Color
   Syntax:
   XYZtoRGB ("X,Y,Z") 
   Examples:
   Description:
   Color space conversion: XYZ --> RGB
   
   Input:
   .   "X,Y,Z"
   
   Output:
   .   "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   XYZtoRGB */
   
   set itemdel to comma
   put item 1 of XYZ into X
   put item 2 of XYZ into Y
   put item 3 of XYZ into Z
   put X / 100 into var_X               //X from 0 to  95.047      (Observer = 2°, Illuminant = D65)
   put Y / 100 into var_Y               //Y from 0 to 100.000
   put  Z / 100 into var_Z              //Z from 0 to 108.883
   
   put var_X *  3.2406 + var_Y * -1.5372 + var_Z * -0.4986 into var_R
   put var_X * -0.9689 + var_Y *  1.8758 + var_Z *  0.0415 into var_G
   put  var_X *  0.0557 + var_Y * -0.2040 + var_Z *  1.0570 into var_B
   
   if ( var_R > 0.0031308 ) then
      put 1.055 * ( var_R ^ ( 1 / 2.4 ) ) - 0.055 into var_R
   else
      put 12.92 * var_R into var_R
   end if
   if ( var_G > 0.0031308 ) then
      put 1.055 * ( var_G ^ ( 1 / 2.4 ) ) - 0.055 into var_G
   else
      put 12.92 * var_G into var_G
   end if
   if ( var_B > 0.0031308 ) then
      put 1.055 * ( var_B ^ ( 1 / 2.4 ) ) - 0.055 into var_B
   else 
      put 12.92 * var_B into var_B
   end if
   put abs(trunc(var_R * 255)) into R
   put abs(trunc(var_G * 255)) into G
   put abs(trunc(var_B * 255)) into B
   return R & comma & G & comma & B
end XYZtoRGB



Function RGBtoXYZ RGB
   /* RGBtoXYZ Color
   Syntax:
   RGBtoXYZ ("R,G,B") 
   Examples:
   Description:
   Color space conversion: RGB --> XYZ
   
    Input:
   .   "R,G,B"
   
   Output:
   .   "X,Y,Z"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   RGBtoXYZ */
   
   set itemdel to comma
   put item 1 of RGB into R
   put item 2 of RGB into G
   put item 3 of RGB into B
   put ( R / 255 )   into var_R     //R from 0 to 255
   put ( G / 255 ) into var_G       //G from 0 to 255
   put  ( B / 255 ) into var_B     //B from 0 to 255
   
   if ( var_R > 0.04045 ) then
      put  ( ( var_R + 0.055 ) / 1.055 ) ^ 2.4 into var_R
   else
      put  var_R / 12.92 into var_R
   end if
   if ( var_G > 0.04045 ) then
      put ( ( var_G + 0.055 ) / 1.055 ) ^ 2.4 into var_G
   else
      put var_G / 12.92 into var_G
   end if
   if ( var_B > 0.04045 ) then
      put ( ( var_B + 0.055 ) / 1.055 ) ^ 2.4 into var_B
   else
      put var_B / 12.92 into var_B
   end if
   
   put var_R * 100 into var_R
   put var_G * 100 into var_G
   put var_B * 100 into var_B
   
   //Observer. = 2°, Illuminant = D65
   put var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805 into X
   put  var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722 into Y
   put  var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505 into Z
   return X & comma & Y & comma & Z
end RGBtoXYZ


Function RGBtoHSV RGB
   /* RGBtoHSV Color
   Syntax:
   RGBtoHSV "(R,G.B") 
   Examples:
   Description:
   Color space conversion: RGB--> HSV
   
    Input:
   .   "R,G,B"
   
   Output:
   .   "H,S,V"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   RGBtoHSV */
   
   set itemdel to comma
   put item 1 of RGB into R
   put item 2 of RGB into G
   put item 3 of RGB into B
   put ( R / 255 ) into var_R                     //RGB from 0 to 255
   put ( G / 255 ) into var_G
   put ( B / 255 ) into var_B
   
   put min( var_R, var_G, var_B ) into var_Min    //Min. value of RGB
   put max( var_R, var_G, var_B ) into var_Max    //Max. value of RGB
   put var_Max - var_Min into del_Max             //Delta RGB value 
   
   put var_Max into V
   
   if ( del_Max = 0 ) then                    //This is a gray, no chroma...
      put 0 into H                               //HSV results from 0 to 1
      put 0 into S
   else                                    //Chromatic data...
      put del_Max / var_Max into S
      
      put ( ( ( var_Max - var_R ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_R
      put ( ( ( var_Max - var_G ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_G
      put ( ( ( var_Max - var_B ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_B
      if  ( var_R = var_Max ) then 
         put del_B - del_G into H
      else 
         if ( var_G = var_Max ) then 
            put ( 1 / 3 ) + del_R - del_B into H
         else 
            if ( var_B = var_Max ) then 
               put ( 2 / 3 ) + del_G - del_R into H
            end if
         end if
      end if
      if ( H < 0 ) then add 1 to H
      if ( H > 1 ) then subtract 1 from H
   end if
   return H & comma & S & comma & V
end RGBtoHSV


Function HSVtoRGB HSV
   /* HSVtoRGB Color
   Syntax:
   HSVtoRGB ("HSV") 
   Examples:
   Description:
   Color space conversion: HSV--> RGB
   
   Input:
   .   "H,S,V"
   
   Output:
   .   "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   HSVtoRGB */
   set itemdel to comma
   put item 1 of HSV into H
   put item 2 of HSV into S
   put item 3 of HSV into V
   if ( S = 0 ) then                       //HSV from 0 to 1
      put V * 255 into R
      put V * 255 into G
      put V * 255 into B
   else
      put H * 6 into var_h
      if ( var_h = 6 )  then put 0 into var_h      //H must be < 1
      put trunc( var_h ) into var_i            //Or ... var_i = floor( var_h )
      put V * ( 1 - S ) into  var_1
      put V * ( 1 - S * ( var_h - var_i ) ) into var_2 
      put V * ( 1 - S * ( 1 - ( var_h - var_i ) ) ) into var_3
      switch var_i
         case 0
            put  V  into var_R   
            put var_3 into var_G
            put var_1 into var_B
            break 
         case 1
            put var_2  var_R
            put V into var_G
            put var_1 into var_B
            break 
         case 2
            put var_1 into var_R
            put V into var_G     
            put var_3 into var_B
            break 
         case 3
            put var_1 into var_R
            put var_2 into var_G
            put V into var_B
            break 
         case 4
            put var_3 into var_R
            put var_1 into var_G
            put V into var_B	
            break
         default
            put V into   var_R  
            put var_1 into var_G
            put var_2 into var_B 
      end switch
      put abs(trunc(var_R * 255)) into R                //RGB results from 0 to 255
      put abs(trunc(var_G * 255)) into G
      put abs(trunc(var_B * 255)) into B
   end if
   return R & comma & G & comma & B
end HSVtoRGB


Function XYZtoLab XYZ, light
   /* XYZtoLab Color
   Syntax:
   XYZtoLab ("X,Y,Z", [light])
   Examples:
   Description:
   Color space conversion: XYZ --> CIE-L*ab
   
   Input:
   .   "X,Y,Z"
   .   light is one of :
   .         "D65/2","A/2","A/10","C/2","C/10","D50/2","D50/10","D55/2","D55/10","D65/2",
   .         "D65/10","D75/2","D75/10","F2/2","F2/10","F7/2","F7/10","F11/2","F11/10"
   
   Output:
   .   "L,a,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   XYZtoLab */
   /* Include
   getRef
   */
   set itemdel to comma
   put item 1 of XYZ into X
   put item 2 of XYZ into Y
   put item 3 of XYZ into Z
   if light is empty then put "D65/2" into light
   put getRef (light) into ref_xyz
   put X / item 1 of ref_xyz into var_X
   put Y / item 2 of ref_xyz into var_Y
   put Z / item 3 of ref_xyz into var_Z
   if var_X > 0.008856 then
      put var_x^(1/3) into var_X
   else
      put (7.787 * var_X) + (16/116) into var_X
   end if
   if var_Y >0.008856 then
      put var_y^(1/3) into var_Y
   else
      put (7.787 * var_Y) + (16/116) into var_Y
   end if
   if var_Z >0.008856 then
      put var_z^(1/3) into var_Z
   else
      put (7.787 * var_Z) + (16/116) into var_Z
   end if
   put (116 * var_Y) - 16 into CIE_L
   put 500 * (var_X - var_Y) into CIE_a
   put 200 * (var_Y - var_Z) into CIE_b
   return CIE_L & comma & CIE_a & comma & CIE_b
end XYZtoLab


Function LabtoXYZ lab1, light
   /* LabtoXYZ Color
   Syntax:
   LabtoXYZ (lab1, light) 
   Examples:
   Description:
   Color space conversion: CIE-L*ab --> XYZ
   
   Input:
   .   "L,a,B"
   .    light is one of :
   .         "D65/2","A/2","A/10","C/2","C/10","D50/2","D50/10","D55/2","D55/10",
   .         "D65/2","D65/10", "D75/2","D75/10","F2/2","F2/10","F7/2","F7/10","F11/2","F11/10"
   
   Output:
   .   "X,Y,Z"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   LabtoXYZ */
   /* Include
   getRef
   */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   
   put ( L1 + 16 ) / 116 into var_Y
   put a1 / 500 + var_Y into var_X
   put var_Y - b1 / 200 into var_Z
   
   if ( var_Y^3 > 0.008856 ) then
      put var_Y^3 into var_Y
   else
      put ( var_Y - 16 / 116 ) / 7.787 into var_Y
   end if
   if ( var_X^3 > 0.008856 ) then
      put var_X^3 into var_X
   else
      put ( var_X - 16 / 116 ) / 7.787 into var_X
   end if
   if ( var_Z^3 > 0.008856 ) then
      put  var_Z^3 into var_Z
   else
      put ( var_Z - 16 / 116 ) / 7.787 into var_Z
   end if
   
   if light is empty then put "D65/2" into light
   put getRef (light) into ref_xyz
   put item 1 of ref_xyz * var_X into X         
   put item 2 of ref_xyz * var_Y into Y     
   put item 3 of ref_xyz * var_Z into Z   
   return X & comma & Y & comma & Z
end LabtoXYZ


function LABtoLCH LAB
   /* LABtoLCH Color
   Syntax:
   LABtoLCH ("L,A,B") 
   Examples:
   Description:
   Color space conversion: CIE-Lab --> CIE-L*CH(degrees)
   
   Input:
   .    "L,A,B"
   
   Output:
   .    "L,C,H"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   LABtoLCH */
   
   set itemdel to comma
   put item 1 of LAB into L1
   put item 2 of LAB into a1
   put item 3 of LAB into b1
   put atan2(b1 , a1 ) into var_H //Quadrant by signs
   if ( var_H > 0 ) then
      put (var_H / Pi ) * 180 into var_H
   else             
      put 360 - ( abs( var_H ) / Pi ) * 180 into var_H
   end if
   put L1 into L
   put sqrt( A1 ^ 2 + b1 ^ 2 ) into C
   put var_H into H 
   return L & comma & C & comma & H
end LABtoLCH

function atan2inDegrees arg1, arg2
   return rad2deg (atan2(arg1,arg2))
end atan2inDegrees


function LCHtoLAB LCH
   /* LCHtoLAB Color
   Syntax:
   LCHtoLAB ("L,C,H") 
   Examples:
   Description:
   Color space conversion: CIE-LCH(degrees) -->CIE-L*ab
   
    Input:
   .    "L,C,H"
   
   Output:
   .    "L,A,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   LCHtoLAB */
   /* Include
   deg2rad
   */
   
   set itemdel to comma
   put item 1 of LCH into L
   put item 2 of LCH into C
   put item 3 of LCH into H
   -- CIE-H° from 0 to 360°
   put cos( deg2rad( H ) ) * C into a1
   put sin( deg2rad( H ) ) * C into b1
   return L & Comma & a1 & comma & b1
end LCHtoLAB


function RGBtoHSL RGB
   /* RGBtoHSL Color
   Syntax:
   RGBtoHSL ("R,G,B") 
   Examples:
   Description:
   Color space conversion: RGB --> HSL
   
   Input:
   .    "R,G,B
   
   Output:
   .    "H,S,L"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   RGBtoHSL */
   
   set itemdel to comma
   put item 1 of RGB into R
   put item 2 of RGB into G
   put item 3 of RGB into B
   put ( R / 255 ) into var_R                     //RGB from 0 to 255
   put ( G / 255 ) into var_G
   put ( B / 255 ) into var_B
   
   put min( var_R, var_G, var_B ) into var_Min   //Min. value of RGB
   put max( var_R, var_G, var_B )  into var_Max  //Max. value of RGB
   put var_Max - var_Min  into del_Max          //Delta RGB value
   put ( var_Max + var_Min ) / 2 into L
   
   if ( del_Max = 0 )  then                   //This is a gray, no chroma...
      put 0 into H                              //HSL results from 0 to 1
      put 0 into S
   else                                    //Chromatic data...
      if ( L < 0.5 ) then
         put del_Max / ( var_Max + var_Min ) into S
      else           
         put del_Max / ( 2 - var_Max - var_Min ) into S
      end if
      put ( ( ( var_Max - var_R ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_R
      put ( ( ( var_Max - var_G ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_G
      put ( ( ( var_Max - var_B ) / 6 ) + ( del_Max / 2 ) ) / del_Max into del_B
      
      if ( var_R = var_Max ) then
         put del_B - del_G into H
      else 
         if ( var_G = var_Max ) then
            put ( 1 / 3 ) + del_R - del_B into H
         else  
            if ( var_B = var_Max )then
               put ( 2 / 3 ) + del_G - del_R into H
            end if
         end if
      end if
      if ( H < 0 ) then add 1 to H
      if ( H > 1 ) then subtract 1 from H
   end if
   return H & comma & S & comma & L
end RGBtoHSL


function HSLtoRGB  HSL
   /* HSLtoRGB Color
   Syntax:
   HSLtoRGB  ("H,S,L") 
   Examples:
   Description:
   Color space conversion: HSL --> RGB
   
   Input:
   .    "H,S,L"
   
   Output:
   .    "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   HSLtoRGB */
   /* Include
   Hue_2_RGB
   */
   
   set itemdel to comma
   put item 1 of HSL into H
   put item 2 of HSL into S
   put item 3 of HSL into L
   if ( S = 0 )  then                     //HSL from 0 to 1
      put L * 255  into R                    //RGB results from 0 to 255
      Put L * 255 into G
      Put L * 255 into B
   else
      if ( L < 0.5 ) then 
         put  L * ( 1 + S ) into var_2
      else
         put ( L + S ) - ( S * L ) into var_2
      end if
      
      put 2 * L - var_2 into var_1
      
      put abs(255 * Hue_2_RGB( var_1, var_2, H + ( 1 / 3 ))) into R
      put abs(255 * Hue_2_RGB( var_1, var_2, H )) into G
      put abs(255 * Hue_2_RGB( var_1, var_2, H - ( 1 / 3 ))) into B
   end if
   return R & comma & G & comma & B
end HSLtoRGB

private function Hue_2_RGB v1, v2, vH      
   if ( vH < 0 ) then add 1 to vH
   if ( vH > 1 ) then subtract 1 from vH 
   if ( ( 6 * vH ) < 1 ) then return ( v1 + ( v2 - v1 ) * 6 * vH )
   if ( ( 2 * vH ) < 1 ) then return ( v2 )
   if ( ( 3 * vH ) < 2 ) then return ( v1 + ( v2 - v1 ) * ( ( 2 / 3 ) - vH ) * 6 )
   return ( v1 )
end Hue_2_RGB

private function getRef light
   if light is empty then put "D65/2" into light
   switch light
      case "A/2"
         put 109.850 into ref_x
         put 100 into ref_y
         put 35.585 into ref_z
         break
      case "A/10"
         put 111.144 into ref_x
         put 100 into ref_y
         put 35.200 into ref_z
         break
      case "C/2"
         put 98.074 into ref_x
         put 100 into ref_y
         put 118.232 into ref_z
         break
      case "C/10"
         put 97.285 into ref_x
         put 100 into ref_y
         put 116.145 into ref_z
         break
      case "D50/2"
         put 96.422 into ref_x
         put 100 into ref_y
         put 82.521 into ref_z
         break
      case "D50/10"
         put 96.720 into ref_x
         put 100 into ref_y
         put 81.427 into ref_z
         break
      case "D55/2"
         put 95.682 into ref_x
         put 100 into ref_y
         put 92.149 into ref_z
         break
      case "D55/10"
         put 95.799 into ref_x
         put 100 into ref_y
         put 90.926 into ref_z
         break
      case "D65/2"
         put 95.047 into ref_x
         put 100 into ref_y
         put 108.883 into ref_z
         break
      case "D65/10"
         put 94.811 into ref_x
         put 100 into ref_y
         put 107.304 into ref_z
         break
      case "D75/2"
         put 94.972 into ref_x
         put 100 into ref_y
         put 122.638 into ref_z
         break
      case "D75/10"
         put 94.461 into ref_x
         put 100 into ref_y
         put 120.641 into ref_z
         break
      case "F2/2"
         put 99.187 into ref_x
         put 100 into ref_y
         put 67.395 into ref_z
         break
      case "F2/10"
         put 103.280 into ref_x
         put 100 into ref_y
         put 69.026 into ref_z
         break
      case "F7/2"
         put 95.044 into ref_x
         put 100 into ref_y
         put 108.755 into ref_z
         break
      case "F7/10"
         put 95.792 into ref_x
         put 100 into ref_y
         put 107.687 into ref_z
         break
      case "F11/2"
         put 100.966 into ref_x
         put 100 into ref_y
         put 64.370 into ref_z
         break
      case "F11/10"
         put 103.866 into ref_x
         put 100 into ref_y
         put 65.672 into ref_z
         break
   end switch
   return ref_x & comma & ref_y & comma & ref_z
end getRef


Function DeltaC lab1, lab2
   /* DeltaC Color
   Syntax:
   DeltaC (lab1, lab2)
   
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
   .    Lab1 = "L1,A1,B1"
   .    Lab2 = "L2,A2,B2"
   
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   DeltaC */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   return sqrt((a2^2) + (b2^2)) \
         - sqrt((a1^2) + (b1^2))
end DeltaC

Function DeltaH lab1, lab2
   /* DeltaH Color
   Syntax:
   DeltaH (lab1, lab2)
   
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
   .    Lab1 = "L1,A1,B1"
   .    Lab2 = "L2,A2,B2"
   
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   DeltaH */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   put sqrt((a2^2) + (b2^2)) \
         - sqrt((a1^2) + (b1^2)) into xDE
   return sqrt((a2 - a1)^2 \
         + (b2 - b1)^2 \
         - (xDE ^2))
end DeltaH

Function DeltaE lab1, lab2
   /* DeltaE Color
   Syntax:
   DeltaE (lab1, lab2)
   
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
   .    "L1,A1,B1"
   .    "L2,A2,B2"
   
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   DeltaE */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   return sqrt(((L1 - L2)^2)  \
         + ((a1 - a2)^2) \
         + ((b1 - b2)^2))
end DeltaE

Function DeltaE1994 lab1, lab2, wht
   /* DeltaE1994 Color
   Syntax:
   DeltaE1994 (lab1, lab2, [wht])
   
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
    .    Lab1 = "L1,A1,B1"
   .    Lab2 = "L2,A2,B2"
   .    wht = L & comma & H & comma & C weighting factors 
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   DeltaE1994 */
   
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   if wht is empty then put "1,1,1" into wht
   put sqrt ((a1^2) + (b1^2)) into xC1
   put sqrt ((a2^2) + (b2^2)) into xC2
   put L2 - L1 into xDL
   put xC2 - xC1 into xDC
   put sqrt (((L1 - L2) * (L1 - L2)) \
         + ((a2 - a2) * (a1 - a2)) \
         + ((b2 - b2) * (b1 - b2))) into xDE
   if (sqrt(xDE) > (sqrt(abs(xDL))+sqrt(abs(xDC)))) then
      put sqrt((xDE*xDE)-(xDL*xDL)-(xDC*xDC)) into xDH
   else
      put 0 into xDH
   end if
   put 1 + (0.045 * xC1) into xSC
   put 1 + (0.015 * xC1) into xSH
   put xDL / item 1 of wht into xDL
   put xDC / (item 2 of wht * xSC) into xDL
   put xDH / (item 3 of wht * xSH) into xDH
   return sqrt(xDL^2 + xDC^2 +xDH^2)
end DeltaE1994

Function DeltaE2000 lab1, lab2, wht
   /* DeltaE2000 Color
   Syntax:
   DeltaE2000 (lab1, lab2, wht)
   
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
   .    Lab1 = "L1,A1,B1"
   .    Lab2 = "L2,A2,B2"
   .    wht = L & comma & H & comma & C weighting factors 
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   DeltaE2000 */
   /* Include
   deg2rad
   CieLab2Hue
   */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   if wht is empty then put "1,1,1" into wht
   put item 1 of wht into wht_L
   put item 2 of wht into wht_C
   put item 3 of wht into wht_H
   put sqrt( a1 * a1 + b1 * b1 ) into xC1
   put  sqrt( a2 * a2 + b2 * b2 ) into xC2
   put ( xC1 + xC2 ) / 2 into xCX
   put 0.5 * ( 1 - sqrt( ( xCX ^ 7 ) / ( ( xCX ^ 7 ) + ( 25 ^ 7 ) ) ) ) into xGX
   put ( 1 + xGX ) * a1 into xNN
   put sqrt( xNN * xNN + b1 * b1 ) into xC1
   put CieLab2Hue( xNN, b1 ) into xH1
   put ( 1 + xGX ) * a2 into xNN
   put sqrt( xNN * xNN + b2 * b2 ) into xC2
   put CieLab2Hue( xNN, b2 ) into xH2
   put L2 - L1 into xDL
   put xC2 - xC1 into xDC
   if ( ( xC1 * xC2 ) = 0 ) then
      put 0 into xDH
   else 
      put  round( xH2 - xH1, 12 ) into  xNN
      if ( abs( xNN ) <= 180 ) then
         put xH2 - xH1 into xDH
      else 
         if ( xNN > 180 ) then
            put xH2 - xH1 - 360 into xDH
         else             
            put xH2 - xH1 + 360 into xDH
         end if
      end if
   end if
   put 2 * sqrt( xC1 * xC2 ) * sin( deg2rad( xDH / 2 ) ) into  xDH
   put ( L1 + L2 ) / 2 into xLX
   put ( xC1 + xC2 ) / 2 into xCY
   if ( ( xC1 *  xC2 ) = 0 ) then
      put xH1 + xH2 into xHX
   else 
      put abs( round( xH1 - xH2, 12 ) ) into xNN
      if ( xNN >  180 ) then
         if ( ( xH2 + xH1 ) <  360 ) then 
            put  xH1 + xH2 + 360 into xHX
         else
            put xH1 + xH2 - 360 into xHX
         end if
      else 
         put xH1 + xH2 into xHX
      end if
      put xHX /  2 into xHX
   end if
   put 1 - 0.17 * cos( deg2rad( xHX - 30 ) ) + 0.24 \
         * cos( deg2rad( 2 * xHX ) ) + 0.32 \
         * cos( deg2rad( 3 * xHX + 6 ) ) - 0.20 \
         * cos( deg2rad( 4 * xHX - 63 ) ) into xTX
   put 30 * exp( - ( ( xHX  - 275 ) / 25 ) * ( ( xHX  - 275 ) / 25 ) ) into xPH
   put 2 * sqrt( ( xCY ^ 7 ) / ( ( xCY ^ 7 ) + ( 25 ^ 7 ) ) ) into xRC
   put 1 + ( ( 0.015 * ( ( xLX - 50 ) * ( xLX - 50 ) ) ) \
         / sqrt( 20 + ( ( xLX - 50 ) * ( xLX - 50 ) ) ) ) into xSL
   put 1 + 0.045 * xCY into xSC
   put 1 + 0.015 * xCY * xTX into xSH
   put  - sin( deg2rad( 2 * xPH ) ) * xRC into xRT
   put  xDL / ( wht_L * xSL ) into xDL
   put xDC / ( wht_C * xSC ) into xDC 
   put xDH / ( wht_H * xSH ) into xDH
   return sqrt( xDL ^ 2 + xDC ^ 2 + xDH ^ 2 + xRT * xDC * xDH )
end DeltaE2000

Function deltaCMC lab1, lab2, wht
   /* deltaCMC Color
   Syntax:
   deltaCMC (lab1, lab2, wht)
   Examples:
   Description:
   Calculate distance between to colors in LAB color space
   
   Input:
   .    Lab1 = "L1,A1,B1"
   .    Lab2 = "L2,A2,B2"
   .    wht = L & comma & H & comma & C weighting factors 
   Output:
   .    the distance
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   deltaCMC */
   /* Include
   CieLab2Hue
   deg2rad
   */
   
   set itemdel to comma
   put item 1 of lab1 into L1
   put item 2 of lab1 into a1
   put item 3 of lab1 into b1
   put item 1 of lab2 into L2
   put item 2 of lab2 into a2
   put item 3 of lab2 into b2
   if wht is empty then put "1,1,1" into wht
   put item 1 of wht into wht_L
   put item 2 of wht into wht_C
   put item 3 of wht into wht_H
   
   put sqrt( ( a1 ^ 2 ) + ( b1 ^ 2 ) ) into xC1
   put sqrt( ( a2 ^ 2 ) + ( b2 ^ 2 ) ) into xC2
   put sqrt( ( xC1 ^ 4 ) / ( ( xC1 ^ 4 ) + 1900 ) ) into xff
   put CieLab2Hue( a1, b1 ) into xH1
   
   if ( xH1 < 164 or xH1 > 345 ) then
      put 0.36 + abs( 0.4 * cos( deg2rad(  35 + xH1 ) ) ) into xTT
   else
      put 0.56 + abs( 0.2 * cos( deg2rad( 168 + xH1 ) ) ) into xTT
   end if
   if ( L1 < 16 ) then
      put 0.511 into xSL
   else
      put ( 0.040975 * L1 ) / ( 1 + ( 0.01765 * L1 ) ) into xSL
   end if
   put ( ( 0.0638 * xC1 ) / ( 1 + ( 0.0131 * xC1 ) ) ) + 0.638 into xSC
   put ( ( xff * xTT ) + 1 - xff ) * xSC into xSH
   put sqrt( ( a2 - a1 ) ^ 2 + ( b2 - b1 ) ^ 2 - ( xC2 - xC1 ) ^ 2 ) into xDH
   put ( L2 - L1 ) / wht_L * xSL into xSL
   put ( xC2 - xC1 ) / wht_C * xSC into xSC
   put xDH / xSH into xSH
   return sqrt( xSL ^ 2 + xSC ^ 2 + xSH ^ 2 )
end deltaCMC

private Function CieLab2Hue var_a, var_B            -- Function returns CIE-H° value
   /* Include
   rad2deg
   */
   put 0 into var_bias
   if ( var_a >= 0 and var_B = 0 ) then return 0
   if ( var_a < 0 and var_B = 0 ) then return 180
   if ( var_a = 0 and var_B > 0 ) then return 90
   if ( var_a = 0 and var_B < 0 ) then return 270
   if ( var_a > 0 and var_B > 0 ) then put 0 into var_bias
   if ( var_a < 0) then put 180 into var_bias
   if ( var_a > 0 and var_B < 0 ) then put 360 into var_bias
   return ( rad2deg( atan( var_B / var_a ) ) + var_bias )
end CieLab2Hue

Function rad2deg rad
   /* rad2deg Math
   Syntax:
   rad2deg (rad)
   Examples:
    rad2deg (rad)
    Description:
    Covert radians to degrees
    Source:
    Michael Doub
rad2deg */
   return rad * (180/pi)
end rad2deg

Function deg2rad deg 
   /* deg2rad Math
   Syntax:
   deg2rad (deg)
   Examples:
   deg2rad (deg) 
Description:
Convert degrees tp radians
Source:
Michael Doub
deg2rad */
   return deg * (pi/180)
end deg2rad



Function RGBtoLab RGB
   /* RGBtoLab Color
   Syntax:
   RGBtoLab ("R,G,B") 
   Examples:
   Description:
   Color space conversion: RGB --> CIE-L*ab
   
   Input:
   .   "R,G,B"
   
   Output:
   .   "L,a,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   RGBtoLab */
   /* Include
   XYZtoLab
   RGBtoXYZ
   */
   
   return XYZtoLab(RGBtoXYZ (RGB))
end RGBtoLAb


Function LABtoRGB Lab
   /* LABtoRGB Color
   Syntax:
   LABtoRGB ("L,a,b") 
   Examples:
   Description:
   Color space conversion: CIE-L*ab --> RGB
   
   Input:
   .   "L,a,B"
   
   Output:
   .   "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   LABtoRGB */
   /* Include
   XYZtoRGB
   LabtoXYZ
   */
   
   return XYZtoRGB(LabtoXYZ(Lab))
end LABtoRGB



Function Harmony RGB, degrees
   /* Harmony Color
   Syntax:
   Harmony ("R,G,B", degrees)
   Examples:
   Description:
   This function converts RGB into LCH and adds the angle position 
   on the color wheel and returns that RGB value
      
      Input:
      .    RGB = "R,G,B"
      .    degrees 1 to 360
      Output:
      
      See http://www.easyrgb.com/index.php?X=MATH
      Source:
      Michael Doub
      Harmony */
      /* Include
      LABtoLCH
      RGBtoLAB
      LABtoRGB
      LCHtoLAB
      */
      
      put LABtoLCH(RGBtoLAB(RGB)) into LCH
      set itemdel to comma
      put item 1 of LCH into L
      put item 2 of LCH into C
      put item 3 of LCH into H
      put H + degrees into newH
      if newH < 0 then add 360 to newH
      if newH > 360 then subtract 360 from newH
      return LABtoRGB(LCHtoLAB(L & comma & C & comma & newH)) 
end Harmony


function triadic RGB
   /* triadic Color
   Syntax:
   triadic ("R,G,B")
   Examples:
   Description:
   This is the typical configuration of three colors that are equally spaced 
   from each other on the color wheel.   H +/- 120 degrees
   
   Input: 
   .   "R,G,B"
   
   Output:
   .   "R,G,B" & return & "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   triadic */
   /* Include
   Harmony
   */
   
   put Harmony (RGB, 120) & return into x
   put Harmony (RGB, -120) after x
   return x
end triadic


function splitcom RGB
   /* splitcom Color
   Syntax:
   splitcom ("R,G,B")
   Examples:
   Description:
   This color scheme combines the two colors on either side of a color’s complement.
   H +/- 150 degrees
   
   Input: 
   .   "R,G,B"
   
   Output:
   .   "R,G,B" & return & "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   splitcom */
   /* Include
   Harmony
   */
   
   put Harmony (RGB, 150) & return into x
   put Harmony (RGB, -150) after x
   return x
end splitcom


function analogous RGB
   /* analogous Color
   Syntax:
   analogous ("R,G,B")
   Examples:
   Description:
   Uses the colors of the same color temperature near each other on the wheel.
   H +/- 30 degrees
   
   Input: 
   .   "R,G,B"
   
   Output:
   .   "R,G,B" & return & "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   analogous */
   /* Include
   Harmony
   */
   
   put Harmony (RGB, 30) & return into x
   put Harmony (RGB, -30) after x
   return x
end analogous


function Complement RGB
   /* Complement Color
   Syntax:
   Complement ("R,G,B")
   Examples:
   Description:
   This is the color opposite on the color wheel.
   H 180 degrees
   
   Input: 
   .   "R,G,B"
   
   Output:
   .   "R,G,B"
   
   See http://www.easyrgb.com/index.php?X=MATH
   Source:
   Michael Doub
   Complement */
   /* Include
   Harmony
   */
   
   return Harmony (RGB, 180)
end Complement

function iff Condition, trueResponce, falseResponce
   /* iff ShortCut
   Syntax:
   iff (<Condition>, <trueResponce>, <falseResponce>)
   Examples:
   return iff(myValue is not empty, myValue, myDefault)
   Description:
   If the Condition argument is true,  the trueResponce argument will be returned, 
   otherwise if returns the falseResponce argument.
   iff */
   
   if Condition is true then   
      -- everything else but "true" is considered false!
      return trueResponce
   else
      return falseResponce
   end if
end iff


function myOwner
   /* myOwner Reference
   Syntax:
   myOwner()
   Examples:
   myOwner()
   Description:
   Returns a reference to the next outer group or card or the next outer stack 
   containing the control with the script from which myOwner was called.
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   myOwner */
   /* Include
   OwnerOf
   */
   
   return OwnerOf(the long id of the target)
end myOwner


function OwnerOf ControlRef
   /* OwnerOf Reference
   Syntax:
   OwnerOf (ControlRef)
   Examples:
   OwnerOf (the target)
   
   Description:
   Returns a reference to the next outer group or card or the next outer stack 
   containing the control referenced by ControlRef. 
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   OwnerOf */
   
   if (ControlRef is empty)    then throw "MissingArgument: no 'ControlRef' given"
   if (there is no ControlRef) then throw "InvalidArgument: given control does not exist"
   
   put the long id of ControlRef into ControlRef        // normalize "ControlRef"
   
   if (ControlRef begins with "stack") then
      local StackName; put the short name of ControlRef into StackName
      
      delete char 1 to 7+(the number of chars of StackName)+5 of ControlRef
      return ControlRef                   // will be the containing stack or empty
   else
      set the wholeMatches to true
      return word 5 to -1 of ControlRef     // may refer to a group, card or stack
   end if
end OwnerOf


function myCard
   /* myCard Reference
   Syntax:
   myCard()
   Examples:
   myCard()
   Description:
   Returns a reference to the card containing the control with the script from which 
   myCard was called. 
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   myCard */
   /* Include
   CardOf
   */
   return CardOf(the long id of the target)
end myCard


function CardOf ControlRef
   /* CardOf Reference
   Syntax:
   CardOf (ControlRef)
   Examples:
   CardOf(the target
   Description:
   Returns a reference to the currently active card of the stack containing the control 
   referenced by ControlRef. 
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   CardOf */
   
   if (ControlRef is empty)    then throw "MissingArgument: no 'ControlRef' given"
   if (there is no ControlRef) then throw "InvalidArgument: given control does not exist"
   
   put the long id of ControlRef into ControlRef        // normalize "ControlRef"
   
   if (ControlRef begins with "stack") \
         then throw "InvalidArgument: 'CardOf' must not be applied to stacks"
   
   set the wholeMatches to true
   return word WordOffset("card",ControlRef) to -1 of ControlRef
end CardOf


function myStack
   /* myStack Reference
   Syntax:
   myStack()
   Examples:
   myStack()
   Description:
   Returns a reference to the MainStack of the stack containing the control with the script 
   from which myMainStack was called. 
   
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   myStack */
   /* Include
   StackOf
   */
   return StackOf(the long id of the target)
end myStack


function StackOf ControlRef
   /* StackOf Reference
   Syntax:
   StackOf (ControlRef)
   Examples:
   StackOf (the target)
   Description:
   Returns a reference to the stack containing the control referenced by ControlRef. 
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   StackOf */
   if (ControlRef is empty)    then throw "MissingArgument: no 'ControlRef' given"
   if (there is no ControlRef) then throw "InvalidArgument: given control does not exist"
   
   put the long id of ControlRef into ControlRef        // normalize "ControlRef"
   return replaceText(ControlRef, "^.*? of stack","stack")  // even for substacks
end StackOf

function myMainStack
   /* myMainStack Reference
   Syntax:
   myMainStack()
   Examples:
   myMainStack()
   Description:
   Returns a reference to the MainStack of the stack containing the control 
   with the script from which myMainStack was called.
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   myMainStack */
   /* Include
   MainStackOf
   */
   
   return MainStackOf(the long id of the target)
end myMainStack

function MainStackOf ControlRef
   /* MainStackOf Reference
   Syntax:
   MainStackOf (ControlRef)
   Examples:
   MainStackOf (the target)
   Description:
   Returns a reference to the MainStack of the stack containing the control referenced by ControlRef.
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   MainStackOf */
   
   if (ControlRef is empty)    then throw "MissingArgument: no 'ControlRef' given"
   if (there is no ControlRef) then throw "InvalidArgument: given control does not exist"
   
   put the long id of ControlRef into ControlRef        // normalize "ControlRef"
   return replaceText(ControlRef, "^.* of stack","stack")   // even for substacks
end MainStackOf


function myCurrentCard
   /* myCurrentCard Reference
   Syntax:
   myCurrentCard()
   Examples:
   myCurrentCard()
   Description:
   Returns a reference to the currently active card of the stack containing the control with the script from which myMainStack was called.
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   myCurrentCard */
   /* Include
   currentCardOf
   */
   
   return currentCardOf(the long id of the target)
end myCurrentCard


function currentCardOf ControlRef
   /* currentCardOf Reference
   Syntax:
   currentCardOf (ControlRef)
   Examples:
   currentCardOf (the target)
   Description:
   Returns a reference to the currently active card of the stack containing the control referenced by ControlRef.
   
   Source: 
   Andreas Rozek, http://www.rozek.mobi/LiveCode/BasicLib/index_scr_en.html
   currentCardOf */
   /* Include
   StackOf
   */
   
   local currentStack; put StackOf(ControlRef) into currentStack
   
   local activeCard; put the currentCard of currentStack into activeCard
   if (matchText(activeCard, "^card id [0-9]+$")) then
      return activeCard & " of " & currentStack
   else
      return the long id of card activeCard of currentStack
   end if
end currentCardOf



on fldPopulate cardRef, @aRecordData, theExclusions
   /* fldPopulate Fields
   Syntax:
   fldPopulate cardRef, aRecordData, [theExclusions]   # Command #
   Examples:
   fldPopulate cardRef, aRecordData
   fldPopulate cardRef, aRecordData, theExclusions
   Description:
   This routine populates properly named controls from date in an array.  The array keys 
   are assumed to be the same with the contols having the following prefixes:
   
   .   Fields: “fld_”
   .   Checkboxes: “btn_” 
   .        and the value must be true or false
   .   Combobox & Option Menu style buttons: “mnu_”
   .        and the value must be one of the choices for the menu
   .   Radio button groups: “rdo_” 
   .        and the value must be one of the button names in the group
   .   Datagrids: can be named as you please, 
   .        and the value must be an encoded array
   
   Source:
   Bob Sneidar
   fldPopulate */
   
     if aRecordData is not an array then exit fldPopulate
     put the keys of aRecordData into theKeyList
   
     repeat for each line theKey in theKeyList
           -- skip exclusions
           if theKey is in theExclusions then
                 next repeat
           end if
      
           put "fld_" & theKey into theFieldName
           put "btn_" & theKey into theButtonName
           put "mnu_" & theKey into theMenuName
           put "rdo_" & theKey into theRadioName
           put theKey into theDGName
           put aRecordData [theKey] into theValue
      
           if theValue is "NULL" then
                 put empty into theValue
           end if
      
      if there is a field theFieldName of cardRef then
         put theValue into field theFieldName of cardRef
         next repeat
      end if
      
      if there is a button theButtonName of cardRef and \
            the style of button theButtonName of cardRef is "checkbox" then
         set the hilite of button theButtonName of cardRef to theValue
         next repeat
      end if
      
      if there is a button theMenuName  of cardRef then
         if (the menuMode of button theMenuName of cardRef is "combobox" or \
               the menuMode of button theMenuName of cardRef is "option") then
            put lineOffset(theValue, the text of button theMenuName of cardRef ) into theFoundLine
            set the menuHistory of button theMenuName  of cardRef to theFoundLine
            next repeat
         end if
      end if
      
      if there is a group theRadioName of cardRef then
         set the hilitedButtonName of group theRadioName  of cardRef to theValue
         next repeat
      end if
      
      if there is a group theDGName then
         try
            put arrayDecode(theValue) into theDGData
            set the dgData of group theDGName  of cardRef to theDGData
         catch theError
         end try
      end if
      
     end repeat
end fldPopulate

on fldExtract cardRef, @aRecordData
   /* fldExtract Fields
   Syntax:
   fldExtract cardRef, aRecordData   # Command #
   Examples:
   fldExtract cardRef, aRecordData
   Description:
   This routine extracts data from properly named controls and inserts them into 
   an array.  The array keys are assumed to be the same with the contols having 
   the following prefixes:
   
   .   Fields: “fld_”
   .   Checkboxes: “btn_”
   .        and the value must be true or false
   .   Combobox & Option Menu style buttons: “mnu_”
   .        and the value must be one of the choices for the menu
   .   Radio button groups: “rdo_” 
   .        and the value must be one of the button names in the group
   .   Datagrids: can be named as you please, 
   .        and the value must be an encoded array
   
   Source:
   Bob Sneidar
   fldExtract */
   
     put the keys of aRecordData into theKeyList
   
     repeat for each line theKey in theKeyList
           put "fld_" & theKey into theFieldName
           put "btn_" & theKey into theButtonName
           put "mnu_" & theKey into theMenuName
           put "rdo_" & theKey into theRadioName
           put theKey into theDGName
      
      if there is a field theFieldName  of cardRef then
         put field theFieldName  of cardRef into aRecordData[theKey] 
         next repeat
      end if
      
      if there is a button theButtonName  of cardRef and the style of button theButtonName of cardRef  is "checkbox" then
         put the hilite of button theButtonName  of cardRef into  aRecordData[theKey] 
         next repeat
      end if
      
      if there is a button theMenuName of cardRef  then
         if (the menuMode of button theMenuName of cardRef is "combobox" or the menuMode of button theMenuName of cardRef is "option") then
            put the menuHistory of button theMenuName of cardRef  into theFoundLine
            put line theFoundLine of the text of button theMenuName of cardRef  into aRecordData[theKey] 
            next repeat
         end if
      end if
      
      
      if there is a group theRadioName  of cardRef then
         put the hilitedButtonName of group theRadioName  of cardRef into aRecordData[theKey]
         next repeat
      end if
      
      if there is a group theDGName  of cardRef then
         put the dgData of group theDGName  of cardRef into theDGData
         put arrayEncode(theDGData) into aRecordData[theKey] 
      end if
      
   end repeat
end fldExtract

function removeLines linesToRemove,@theData
   /* removeLines Lines
   Syntax:
   removeLines (linesToRemove,theData)
   Examples:
   put removeLines(the hilitedLines of fld 2,fld 2) into fld 1
   Description:
   This routine removes the designated lines.  LinesToRemove is a comma seperated
   list of line numbers with theData.
   Source:
   Michael Doub
   removeLines */
     put 0 into lineCounter
     split linesToRemove with comma as set
     repeat for each line L in theData
           add 1 to lineCounter
           if linesToRemove[lineCounter] then next repeat
           put L & cr after R
     end repeat
     return char 1 to -2 of R
end removeLines

on removeLinesInPlace linesToRemove,@theData
   /* removeLinesInPlace Lines
   Syntax:
   removeLinesInPlace inesToRemove,theData   # Command #
   Examples:
   put the text of fld 2 into x
   removeLinesInPlace the hilitedLines of fld 2,x
   set the text of fld 2 to x
   Description:
   This routine removes the designated lines of the specified container.  
   It modifies the container in place.   LinesToRemove is a comma seperated
   list of line numbers with theData.
   Source:
   Michael Doub
   removeLinesInPlace */
     put numToChar(11) into delim
     repeat for each item L in linesToRemove
           put delim into line L of theData
     end repeat
     filter theData without delim
end removeLinesInPlace

function extractLines linesToExtract,@theData
   /* extractLines Lines
   Syntax:
   extractLines (linesToRemove,theData)
   Examples:
   put extractLines(the hilitedLines of fld 2,fld 2) into fld 1
   Description:
   This routine extracts the designated lines.  LinesToRemove is a comma seperated
   list of line numbers with theData.  The lines will be extracted in the order 
   of the items in LinesToExtract.
   Source:
   Michael Doub
   extractLines */
     repeat for each item L in linesToExtract
           put line L of theData & return after R
     end repeat
     return char 1 to -2 of R
end extractLines


function PrintArray pArray
   /* PrintArray Debugging
   Syntax:
   PrintArray (pArray)
   Examples:
   PrintArray (pArray)
   Description:
   Formats an array for viewing
   
   Input:
   .    and array
   
   Output:
   .    formated text (readable)
   
   Source:
   Livecode UI
   PrintArray */
   /* Include
   dumpArrayRecurse
   */
   
   if (the keys of pArray) is empty then
      put "not an array"
      exit PrintArray
   end if
   local pLevel, pCounter, pList
   put 0 into pLevel
   put 0 into pCounter
   put empty into pList
   return dumpArrayRecurse(pArray, pLevel, pCounter, pList)
end PrintArray

private function dumpArrayRecurse pArray, pLevel, @pCounter, @pList
   local tOrderedKeys
   put the keys of pArray into tOrderedKeys
   sort lines of tOrderedKeys numeric
   repeat for each line tKey in tOrderedKeys
      add 1 to pCounter
      repeat for pLevel
         put tab after line pCounter of pList
      end repeat
      put (tKey && "= ") after line pCounter of pList
      if (the keys of pArray[tKey]) is empty then
         put line 1 of pArray[tKey] after line pCounter of pList
      else
         put dumpArrayRecurse(pArray[tKey], (pLevel + 1), pCounter, pList) into pList
      end if
   end repeat
   return pList
end dumpArrayRecurse

on DefineQuickFiles  pHandle, pFileName, pType, pPath
   /* DefineQuickFiles quickFile
   Syntax:
   DefineQuickFiles pArray pHandle, pFileName, [pType], [pPath]   # Command #
   Examples:
   DefineQuickFiles "settings", "mySetting.settings"
   DefineQuickFiles "myData", "myData.data", "perm", "Resources/Database"
   Description:
   initializes the data structures used by the quickFile library routines.
   
   Input:
   .  pHandle is string used to access the file via the library routines
   .  pFileName is the filename.extenstion for the actual file
   .  pType is the type of file
   .      "pref" will be placed in the standard location for preference data (default)
   .      "perm" will be placed in the standard location for non-temporary data
   .      "temp" will be place in the standard location for temporary data
   .      "stack"  will be placed in the same folder as the stack
   .  pPath is an extention to the paths defined by type (exclude leading and trailing slashes)
   
   Source:
   Michael Doub
   DefineQuickFiles */
   /* Include
   getfilepath
   */
   if pType is not empty then
      if lower(pType) is not among the items "pref,perm,temp,stack" then 
         return "Error: Bad Type Parameter"
      end if
   else
      put "pref" into pType
   end if
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   put the uQuickFilePaths of me into tArray
   if pPath <> empty then
      put getFilePath(pType) & "/" & pPath & "/" & pFileName into tArray[pHandle]
   else
      put getFilePath(pType) & "/" & pFileName into tArray[pHandle]
   end if
   set the uQuickFilePaths of me to tArray
   set the custompropertyset of me to temp
   return empty
end DefineQuickFiles

on LoadQuickFile pHandle @pArray
   /* LoadQuickFile QuickFile
   Syntax:
   LoadQuickFile pHandle pArray   # Command #
   Examples:
   LoadQuickFile "Pref", pArray
   Description:
   This handler will load the file associated with pHandle into pArray.  If anyfolder in the path
   of the file is missing, it will be created.
   
   Input:
   .  pHandle is string used to access the file via the library routines
   .  pArray is where the date will be loaded
   
   Source:
   Michael Doub
   LoadQuickFile */
   /* Include
   DefineQuickFiles
   SaveQuickFile
   createPath
   */
   
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   put the uQuickFilePaths of me into tArray
   set the custompropertyset of me to temp
   if pHandle is not among the lines of the keys of tArray then return "Error:" && pHandle && "definition not found"
   put tArray[pHandle] into thePath
   set itemdel to "/"
   createPath(item 1 to -2 of thePath)
   if there is not a file thepath then
      put empty into pArray
      put arrayEncode(pArray) into it
      put it into URL ("binfile:" & thePath)
   else
      put URL ("binfile:" & thePath) into it
      put arrayDecode(it)  into pArray
   end if
   return empty
end LoadQuickFile

on SaveQuickFile pHandle @pArray
   /* SaveQuickFile QuickFile
   Syntax:
    SaveQuickFile pHandle pArray   # Command #
   Examples:
   SaveQuickFile "Pref", pArray
   Description:
   This handler will save pArray into the file associated with pHandle.  
   
   Input:
   .  pHandle is string used to access the file via the library routines
   .  pArray is  the date to be saved
   
   Source:
   Michael Doub
   SaveQuickFile */
   /* Include
   DefineQuickFiles
   LoadQuickFile
   createPath
   */
   
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   put the uQuickFilePaths of me into tArray
   set the custompropertyset of me to temp
   if pHandle is not among the lines of the keys of tArray then return "Error:" && pHandle && "definition not found"
   put tArray[pHandle] into thePath
   if there is not a file thePath then
      createPath(item 1 to -2 of thePath)
   end if
   put arrayEncode(pArray) into it
   put it into URL ("binfile:" & thePath)
   return empty
end SaveQuickFile

on deleteQuickFile pHandle 
   /* deleteQuickFile QuickFile
   Syntax:
   deleteQuickFile pHandle    # Command #
   Examples:
   deleteQuickFile "Pref"
   Description:
   This handler will delete the file associated with pHandle. 
   
   .  pHandle is string used to access the file via the library routines
   
   Source:
   Michael Doub
   
   deleteQuickFile */
   /* Include
   DefineQuickFiles
   LoadQuickFile
   SaveQuickFile
   */
   
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   put the uQuickFilePaths of me into tArray
   set the custompropertyset of me to temp
   if pHandle is not among the lines of the keys of tArray then return "Error:" && pHandle && "definition not found"
   put tArray[pHandle] into thePath
   delete file thePath
   return empty
end deleteQuickFile

private function getFilePath pType
   switch the platform
      case "iphone"
         switch lower(pType)
            case "pref"
               put   specialfolderpath("engine")  into x
               break
            case  "perm"
               put   specialfolderpath("documents")  into x
               break
            case "temp"
               put   specialfolderpath("temporary")  into x
               break
            case "stack"
               put   specialfolderpath("engine")  into x
               break
         end switch
         break
      case "android"
         switch lower(pType)
            case "pref"
               put   specialfolderpath("engine")  into x
               break
            case  "perm"
               put   specialfolderpath("documents")  into x
               break
            case "temp"
               put   specialfolderpath("cache")  into x
               break
            case "stack"
               put   specialfolderpath("engine")  into x
               break
         end switch
         break
      case "Win32"
         switch lower(pType)
            case "pref"
               set itemdel to "/"
               put  item 1 to -2 of (the effective fileName of this stack) into x
               break
            case  "perm"
               put   specialfolderpath("documents")  into x
               break
            case "temp"
               put   specialfolderpath("temporary")  into x
               break
            case "stack"
               set itemdel to "/"
               put  item 1 to -2 of (the effective fileName of this stack) into x
               break
         end switch
         break
      case "MacOS"
         switch lower(pType)
            case "pref"
               put   specialfolderpath("preferences")  into x
               break
            case  "perm"
               put   specialfolderpath("documents")  into x
               break
            case "temp"
               put   specialfolderpath("temporary")  into x
               break
            case "stack"
               set itemdel to "/"
               put  item 1 to -2 of (the effective fileName of this stack) into x
               break
         end switch
         break
   end switch
   return x
end getFilePath

function ISOdate pDate
   /* ISOdate Date
   Syntax:
   ISOdate (pDate)
   Examples:
   answer ISOdate ("02/27/2010")
   get ISOdate(the short date)
   put ISOdate("Nov 3, 2014")
   Description:
   returns the ISO 8601 date format: yyyy-mm-dd
   Source:
   Hugh Senior
   ISOdate */
   if pDate is empty then put the short date into pDate
    convert pDate to dateItems
    if the result <>"" then return "invalid date"
    put item 1 of pDate into tYear
    set the numberFormat to "00"
    put item 2 of pDate +0 into tMonth
    put item 3 of pDate +0 into tDay
    put tYear & "-" & tMonth &"-"& tDay into ISOdate
    return ISOdate
end ISOdate

function FindinStyledText pString, @tA, pLine, pRun, pStartChar
   /* FindinStyledText StyledText
   Syntax:
   FindinStyledText (pString, @tA, [pLine], [pRun], [pStartChar])
   Examples:
   FindinStyledText ("test", @tA)
   FindinStyledText ("test", @tA,2,1,1)
   Description:
   This routine searchs the styled text array for a string.  The string MAY cross
   a run bountry.  
   
   Input:
   pString - the string to be found
   tA - the array of styledText
   pLine - the optional starting index in to tA.  In other words the starting line within
   .            the text.  Defaults to 1
   pRun - the optional starting run index within pLine, Defaults to 1
   pStartChar - the optional starting character within run pRun, Defaults to 1
   
   Returned:
   rline,rRun,rStartChar or empty if not found
   
   rLine - the index within tA of the found text
   rRun - the index within tA of the fount run
   rStartChar - the starting char within the run of the text found
   
   Source:
   Michael Doub
   FindinStyledText */
   
   if pRun = empty then put 1 into pRun
   if pStartChar = empty then put 1 into pStartChar
   if pLine = empty then put 1 into pLine
   
   --Put only the unstyled text to be searched into tData
   repeat with pgh = pLine to the number of lines in the keys of tA
      repeat with run = pRun to the number of lines in the keys of tA[pgh]["runs"]
         if run = pRun and pStartChar <> 1 then
            put char pStartChar to -1 of tA[pgh]["runs"][run]["text"] after tData
         else
            put tA[pgh]["runs"][run]["text"] after tData
         end if
      end repeat
      put cr after tData
   end repeat
   
   put the lineoffset(pString, tData) into tFoundInLine
   if tFoundInLine = 0 then return empty  -- Not found
   
   put (tFoundInLine + pLine) -1 into rLine  -- rLine is the line with the string
   put line tFoundInLine of tData into tLine
   put the offset (pString, tLine) into tStartChar
   put pStartChar + tStartChar -1 into rStartChar
   
   repeat with run = pRun to the number lines in the keys of tA[rLine]["runs"]
      if rStartChar <= the length of tA[rLine]["runs"][run]["text"] then
         put run into rRun
         exit repeat
      else
         subtract the length of tA[rLine]["runs"][run]["text"] from rStartChar
      end if
   end repeat
   return rLine,rRun,rStartChar
end FindinStyledText

function ISOnow 
   /* ISOnow Date
   Syntax:
   ISOnow ()
   Examples:
   put ISOnow()
   
   Description:
   returns the ISO 8601 date time format: yyyy-mm-dd hh:mm:ss
   Source:
   Michael Doub adapted from ISOdate
   ISOnow */
   put the seconds into pDate
    convert pDate from seconds to dateItems
    put item 1 of pDate into tYear
    set the numberFormat to "00"
    put item 2 of pDate +0 into tMonth
    put item 3 of pDate +0 into tDay
   put item 4 of pDate +0 into hh
   put item 5 of pDate +0 into mm
   put item 6 of pDate +0 into ss
    put tYear & "-" & tMonth &"-"& tDay && hh & ":" & mm & ":" & ss into ISOdate
    return ISOdate
end ISOnow

on commandkeyDown pKey 
   /* commandkeyDown System
   Syntax:
   commandkeyDown   # Command #
   Examples:
   commandkeyDown
   Description:
   This is just a handler for cut, copy, paste and undo
   
   . to paste plain text
   .    (matching the formatting of the target field)
   . Mac: command-control-V
   . Win: control-alt-V
   
   put this into a frontscript where it will operate everywhere in LC
   
   Source:
   paste code by Peter M. Brigham, pmbrig@gmail.com
   commandkeyDown */
      switch pKey 
           case "x" 
                cut 
                break 
           case "v"
         if the tool is not "browse tool" then pass commandKeyDown
         switch the platform
            case "MacOS"
               put the controlkey is down into pastePlain
               break
            case "Win32"
               put the altkey is down into pastePlain
               break
            default
               paste
               exit to top
         end switch
         if not pastePlain then pass commandKeyDown
         if the clipboard is not "text" then pass commandKeyDown
         if the selectedField is empty then pass commandKeyDown
         if the long name of the target contains "revNewScriptEditor"
         then pass commandKeyDown
         -- now plain text is needed
         put the clipboarddata["text"] into the selectedchunk
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



function truncate str,n, appenditem  --mdd
   /* truncate Text
   Syntax:
   truncate (str,n,[appenditem])
   Examples:
   put truncate ("this is a test of how to truncate",14) --> "This is a test"
   put truncate ("this is a test of how to truncate",17, "...")  -->"This is a test..."
   put truncate ("this is a test of how to truncate",15 ,numtochar(201))
   Description:
   truncate a string to no more than n characters.   If appenditem is present
   it str will be truncated to allow str and appenditem be concatinated together
   and still be no more that n characters.
   Source:
   adapted from Peter M. Brigham, pmbrig@gmail.com
   truncate */
   
   if appenditem is not empty then
      if length(str)+length(appenditem) <= n then return str & appenditem
      return char 1 to n - length(appenditem) of str & appenditem
   else
      if length(str) <= n then return str
      return char 1 to n of str
   end if
end truncate   --mdd

function regexpLineOffset regexp @thedata startLine
   /* regexpLineOffset Text Items
   Syntax:
   regexpLineOffset (regexp, thedata, [startline])
   Examples:
   regexpLineOffset ("^\s*(?i)function.*", thedata)
   regexpLineOffset ("^\s*(?i)function.*", thedata, 20)  --starts the search at line 20
   Description:
   This is similar to lineoffset except it takes a true regular expression as the search 
   pattern.   The actual linenumber of the match is returned.  Optionally you can specify
   the starting line of the search
   
   The linenumber found is returned, 0 is returned if not found
   Source:
   Michael Doub
   regexpLineOffset */
   
   if startLoc = empty then put 1 into startLine
   repeat with theLine = startLine to the number of lines in thedata
      get MatchText(line theLine of thedata,regexp)
      if it then return theLine
   end repeat
   return 0
end regexpLineOffset


function sr str
   /* sr ShortCut
   Syntax:
   sr (string)
   Examples:
   sr ("  Hello World!   ") --> "Hello World!"
   Description:
   sr = "strip returns" -- actually, strips all white space fore and aft
   place this handler in a library stack, where it will be available everywhere
   Source:
   sr */
   return word 1 to -1 of str
end sr


function expandError tErr
   /* expandError System
   Syntax:
   expandError (tErr)
   Examples:
   expandError (tErr)
   Description:
   expands LC runtime error numbers, with explanatory text
   
   Source:
   adapted from Peter M. Brigham, pmbrig@gmail.com
   expandError */
   /* Include
   sr
   */
   
   repeat for each line e in tErr
      put item 1 of e into errNbr
      put item 2 of e into tLineNbr
      put item 3 of e into tCharNbr
      put item 4 to -1 of e into tHint
      put "• line" && tLineNbr & "," && "char" && tCharNbr & ": " into tErrMsg
      put "error #" & errNbr & ", " after tErrMsg
      put sr(line errNbr of the cErrorsList of card 1 of stack "revErrorDisplay") \
            after tErrMsg
      if tHint <> empty then
         put " — hint:" && tHint after tErrMsg
      end if
      put tErrMsg & cr after errorlist
   end repeat
   return sr(errorlist)
end expandError


on err pResultString, pDisplayMessage, pDontExitFlag
   /* err ShortCut
   Syntax:
   err pResultString, [pDisplayMessage], [pDontExitFlag]   # Command #
   Examples:
   err pResultString
   err pResultString, "This is Broken"
   err pResultString, "This is Broken", true
   Description:
   puts up an answer dialog displaying an error string
   or optionally a user-generated error notification.
   call it after doing anything that might throw an error in the result
   Adding any value into pDontExitFlag will prevent exiting to top
   
   Source:
   based on a handler from Richard Gaskin, Fourth World Software
   err */
   /* Include
   expandError
   */
   
   if pResultString is empty then exit err
   if pDisplayMessage = empty then
      put pResultString into pDisplayMessage
      answer warning pDisplayMessage with "translate" or "OK" as sheet
      if it is "OK" then
         exit to top
      end if
      put expandError(pResultString) into pDisplayMessage
   end if
   answer warning pDisplayMessage as sheet
   if pDontExitFlag is empty then exit to top
end err


on exportFile2 container, saveToWhere, isBinaryFile
   /* exportFile2 File
   Syntax:
   exportFile2 container, [saveToWhere], [isBinaryFile]   # Command #
   Examples:
   exportFile2 tData, "/valid/path/to/file"
   exportFile2 tImageData, validPathName, true
   exportFile2 tData, "Name your text file:"
   put the result into tUserFilePath
   
   Description:
   MacOS:
   if first char of saveToWhere = "/" then treats saveToWhere as a valid filepath
   otherwise treats saveToWhere as a prompt for an ask file dialog.
   
   Win32:
   if char char 2 to 3  of saveToWhere is ":/" then treats saveToWhere as a valid filepath
   otherwise treats saveToWhere as a prompt for an ask file dialog.
   
   if saveToWhere is empty then default ask file prompt will be "Name your file:"
   
   if isBinaryFile = true then exports as binary file else if isBinaryFile = false or 
   empty, exports as data file (converting end of line characters according to platform)
   
   The pathname chosen by the user will be returned in the result including the "file:" 
   or "binfile:" prefix
   
   Source:
   exportFile2 */
   
   if isBinaryFile = empty then put false into isBinaryFile
   put false into tPath
   put the platform into jump
   switch jump
      case "Win32"
         if char 2 to 3 of saveToWhere = ":/" then put true into tPath
         break
      case "MacOS"
         if char 1 of saveToWhere = "/" then put true into tPath
         break
   end switch
   if tPath = false then
      if saveToWhere is empty then 
         put "Name your file:" into tPrompt
      else
         put saveToWhere into tPrompt
          if char -1 of tPrompt <> ":" then put ":" after tPrompt
      end if
      ask file tPrompt
      if it = empty then exit exportFile2
      put it into saveToWhere
   end if
   
   if isBinaryFile then
      put "binfile:" before saveToWhere
   else
      put "file:" before saveToWhere
   end if
   put container into URL saveToWhere
   if the result <> empty then
      return "Error in exportFile:" && the result
   else
      return  saveToWhere -- in case it needs to be stored by your script
   end if
end exportFile2


on NoDuplicates @tList,tDelim
   /* NoDuplicates Text Items
   Syntax:
   NoDuplicates @tList,[tDelim]      # Command #
   Examples:
   assuming theList starts as a comma-delimited list
   
   NoDuplicates theList,comma      
   NoDuplicates theList
   
   following which theList will contain the original list
   stripped of empty and duplicate items
   Description:
   strips duplicate (and empty) lines/items from a list
   
   NOTE: tList is referenced, so the original list will be changed.
   
   .    if tDelim = empty then looks first for the presence of cr in tList,
   .             if found, defaults to cr as the delimiter
   .    if no cr found, looks for the presence of comma in tList,
   .             if found, defaults to comma as the delimiter
   .    if neither found, exits without changing tList
   .             (user should have specified another delim)
   
   note: the order of the list will likely be changed, may require re-sorting
   note: the split command is inherently case-sensitive
   (irrespective of the value of the caseSensitive property),
   so "Chuck" and "chuck" will not be considered duplicates
   
   if you need case insensitive, use the noDupes() function instead
   
   Source:
   Peter Hayworth
   NoDuplicates */
   
   if tDelim = empty then
      if cr is in tList then
         put cr into tDelim
      else if comma is in tList then
         put comma into tDelim
      else
         answer "NoDuplicates: no delimiter specified" as sheet
         exit NoDuplicates
      end if
   end if
   replace tDelim with cr in tList
   filter tList without empty
   split tList by cr and cr
   put the keys of tList into tList
   replace cr with tDelim in tList
end NoDuplicates


function noDupes tList,tDelim,tCaseSensitive
   /* noDupes Text Items
   Syntax:
   noDupes (tList,[tDelim],[tCaseSensitive])   
   Examples:
   assuming theList starts as a comma-delimited list
   
   noDupes (theList)
   noDupes (theList,comma)   
   noDupes (theList,comma,true)   
   
   following which theList will contain the original list
   stripped of empty and duplicate items
   
   Description:
   strips duplicate (and empty) lines/items from a list
   
   .   if tDelim = empty then looks first for the presence of cr in tList,
   .        if found, defaults to cr as the delimiter
   .   if no cr found, looks for the presence of comma in tList,
   .        if found, defaults to comma as the delimiter
   .   if neither found, returns empty (user should have specified another delim)
   
   returns a list with same delim as input list
   order of list will likely be changed, may require re-sorting
   the *command* NoDuplicates (q.v.) scales better with very large lists
   but is inherently case-sensitive, ie, will retain both "Chuck" and "chuck"
   
   Source:
   noDupes */
   
   if tCaseSensitive = empty then put false into tCaseSensitive
   set the caseSensitive to tCaseSensitive
   if tList = empty then return empty
   if tDelim = empty then
      if cr is in tList then
         put sr into tDelim
      else if comma is in tList then
         put comma into tDelim
      else
         return empty
      end if
   end if
   set the itemdelimiter to tDelim
   repeat for each item i in tList
      if i = empty then next repeat
      put 1 into aFinal[i]
   end repeat
   put the keys of aFinal into finalList
   replace cr with tDelim in finalList
   return finalList
end noDupes


on nudgeTextSize theObject,theDirection
   /* nudgeTextSize Fields
   Syntax:
   nudgeTextSize theObject,theDirection   # Command #
   Examples:
   nudgeTextSize fld "x",+1
   Description:
   Increases the textsize of the entire text of any field,
   even if the field has varying textsizes already.
   
   .   theObject = a full object reference, eg, the long id
   .   theDirection = +1 or -1
   
   Source:
   Michael Doub and Malte Brill
   nudgeTextSize */
   /* include
   getDelimiters()
   */
   
   if theDirection is not among the items of "1,-1" then exit nudgeTextSize
   put the htmlText of theObject into theHtml
   put getDelimiters() into tDelim
   replace "size="&quote with "size="&tDelim in theHTML
   set the itemdel to tDelim
   if the number of items of theHTML<>1 then
      put 0 into itemCount
      repeat for each item theItem in theHTML
         add 1 to itemCount
         if itemCount=1 then
            put theItem into newHTML
            next repeat
         end if
         put 1 into counter
         put offset (">", theItem) into tClose
         put offset ("<" , theItem) into tOpen
         if tClose <> 0 then -- found it
            if tOpen <> 0 and tOpen > tClose then
               -- found "<" and after ">" this is ok
               repeat forever
                  add 1 to counter
                  if char counter of theItem=quote then exit repeat
               end repeat
               put char 1 to counter-1 of theItem into theSize
               put theSize + theDirection into theSize
               put theSize into char 1 to counter-1 of theItem
            end if
         end if
         put quote&theItem after newHTML
      end repeat
      set the htmlText of theObject to newHTML
   end if
   set the textSize of theObject to \
         the effective textSize of theObject + theDirection
end nudgeTextSize

function getDelimiters tText,nbr
   /* getDelimiters Text Items
   Syntax:
   getDelimiters (tText,[nbr])
   Examples:
   put getDelimiters(tText,2) into tDelims
   put line 1 of tDelims into lineDivider
   put line 2 of tDelims into itemDivider
   
   Description:
   Returns a cr-delimited list of <nbr> characters not found in the variable tText
   Use for delimiters for, eg, parsing text files, loading arrays, etc.
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   getDelimiters */
   
   if tText = empty then return "Error: no text specified."
   if nbr = empty then put 1 into nbr -- default 1 delimiter
   put "2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26" into baseList
   -- low ASCII values, excluding CR, LF, tab, etc.
   put the number of items of baseList into maxNbr
   if nbr > maxNbr then return "Error: max" && maxNbr && "delimiters."
   repeat with tCount = 1 to nbr
      put true into failed
      repeat with i = 1 to the number of items of baseList
         put item i of baseList into testNbr
         put numtochar(testNbr) into testChar
         if testChar is not in tText then
            -- found one, store and get next delim
            put false into failed
            put testChar into line tCount of delimList
            exit repeat
         end if
      end repeat
      if failed then
         if tCount = 0 then
            return "Error: cannot get any delimiters."
         else if tCount = 1 then
            return "Error: can only get one delimiter."
         else
            return "Error: can only get" && tCount && "delimiters."
         end if
      end if
      delete item i of baseList
   end repeat
   return delimList
end getDelimiters


on replaceItem tItem, @tList, tItemNbr, tDelim
   /* replaceItem Text Items
   Syntax:
   replaceItem tItem, tList, tItemNbr, [tDelim]   # Command #
   Examples:
   replaceItem tItem, tList, 1, comma
   Description:
   Replaces item tItemNbr of tList with tItem
   
   .   If tDelim = empty, defaults to tab as the delimiter
   .   tList is referenced, so the original list will be changed
   
   This is most useful when itemDelim is non-standard, you
   don't have to set it then reset it in calling script
   Source:
   replaceItem */
   
   if tItemNbr = empty then exit replaceItem
   if tDelim = empty then put tab into tDelim
   set the itemdelimiter to tDelim
   put tItem into item tItemNbr of tList
end replaceItem


on ArrayToFile pArray, pFilePath
   /* ArrayToFile File
   Syntax:
   ArrayToFile pArray, pFilePath   # Command #
   Examples:
   ArrayToFile pArray, pFilePath
   Description:
   Saves an array to a disignated file path.  Check the result for errors
   
   Use arrayFromFile to restore
   Source:
   Phil Davis, LC-use list
   ArrayToFile */
   /* Include
   arrayFromFile
   */
   
   if (the keys of pArray = empty) then
      return "Bad param in saveArrayToFile"
   end if
   if pFilePath = empty then
      ask file "Name and locate the file to save:" as sheet
      if it is empty then exit ArrayToFile
      put it into pFilePath
   end if
   put base64encode(arrayEncode(pArray)) into tFileData
   put tFileData into url ("file:" & pFilePath)
   if the result <> empty then -- an error occurred
      return "Error while saving file:" && the result
   end if
end ArrayToFile

function ArrayFromFile pFilePath
   /* ArrayFromFile File
   Syntax:
   ArrayFromFile (pFilePath)
   Examples:
   put  ArrayFromFile (pFilePath) into pArray
   Description:
   Saves an array to a disignated file path.  Check the result for errors
   
   Use ArrayToFile to save the original array
   Source:
   Phil Davis, LC-use list
   ArrayFromFile */
   /* Include
   ArrayToFile
   */
   
   if not (there is a file pFilePath) then
      answer "File not found:" & cr & pFilePath
      exit to top
   end if
   get url ("file:" & pFilePath)
   if the result <> empty then
      answer "Could not read array file:" & cr & pFilePath
      exit to top
   end if
   -- we got the file, unpack, decode, and return it
   put base64decode(it) into tArrayData
   if the result <> empty then
      answer "Could not base64decode:" & cr & pFilePath
      exit to top
   end if
   wait 0 seconds
   put arrayDecode(tArrayData) into tArrayA
   if the result <> empty then
      answer "Could not arrayDecode:" & cr & pFilePath
      exit to top
   end if
   wait 0 seconds
   return tArrayA
end arrayFromFile


on shakeStack tStackName
   /* shakeStack Misc
   Syntax:
   shakeStack  [tStackName]   # Command #
   Examples:
   if fld "number" is not a number then
      shakestack
      select text of fld "number"
   end if
   Description:
   Shakes stack L-R.  Use for bad input by user in a custom input stack
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   shakeStack */
   
   if tStackName = empty then put the short name of this stack into tStackName
   put the loc of stack tStackName into tLoc
   put tLoc into tLeft
   put tLoc into tRight
   subtract 6 from item 1 of tLeft
   add 6 to item 1 of tRight
   repeat 3 times
      put the loc of stack tStackName into currentLoc
      move stack tStackName from currentLoc to tLeft
      move stack tStackName from tLeft to tRight
   end repeat
   move stack tStackName from tRight to tLoc
end shakeStack

-- begin Shuffle_var
local _shuffleArray, _shuffleIndex
-- end Shuffle_var

on shuffleLines @pSource
   /* shuffleLines Lines
   Syntax:
   shuffleLines theLines   # Command #
   Examples:
   shuffleLines theLines
   Description:
   A command to Shuffles lines of pSource randomly
   
   from a function by Alex Tweedly, use-LC list
   converted to a command referencing the source list to avoid duplicating 
   large lists in memory and using Random() for better randomization
   
   Relatively efficient on large lists, time increases linearly, not geometrically
   Source:
   by Peter M. Brigham, pmbrig@gmail.com
   shuffleLines */
   /* Include
   Shuffle_var
   _shuffle
   Random
   */
   
   
   put the number of lines of pSource into tNum
   -- fill an array with 'self' numbers
   repeat with i = 1 to tNum
      put i into tA[i]
   end repeat
   repeat with n = tNum down to 1
      put Random(n) into tRand
      put tA[tRand] into _shuffleArray[n]
      put tA[n] into tA[tRand]
   end repeat
   put 0 into _shuffleIndex
   sort lines of pSource by _shuffle()
end shuffleLines

private function _shuffle
   -- utility function for shuffleLines
   
   add 1 to _shuffleIndex
   return _shuffleArray[_shuffleIndex]
end _shuffle

function _Random n
   /* _Random Math
   Syntax:
   _Random (n)
   Examples:
   _Random (10000)
   Description:
   Returns a (more random) random number between 1 and n works for n up to ~ 4.29 billion
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   _Random */
   
   put (the long seconds mod 1) into ss
   -- long seconds returns up to 6 digits after the decimal, ie, down to microseconds
   -- we want to use only the fractional part of the long seconds, so mod 1 does that
   --    mod 1 gives something like "0.051632" (could be fewer than 6 digits)
   --    if the long seconds happens to be an integer, mod 1 gives "0"
   delete char 1 to offset(".",ss) of ss
   set the randomseed to ss + 1000
   return (random(4294967295) wrap n)
   -- 4294967295 (= 2^32 - 1) is the largest argument permissible for random()
end _Random


function anagram tString
   /* anagram Text
   Syntax:
   anagram (tString)
   Examples:
   anagram (tString)
   Description:
   Returns all the anagrams of the string tString
   Source:
   Geoff Canyon, use-LiveCode list
   anagram */
   /* Include
   _permute
   NoDuplicates
   */
   
   put the length of tString into N
   if N > 8 then
      answer "Long words will take a long time to anagram!" with "proceed" \
            or "cancel" as sheet
      if it is "cancel" then exit to top
   end if
   put _permute(N-1,185) into permList
   repeat with c = 1 to N
        replace numtochar(c+184) with char c of tString in permList
   end repeat
   NoDuplicates permList
   sort permList
   return permList
end anagram

private function _permute N,B
   -- utility function for anagram()
   -- returns all the permutations of N+1 ASCII characters
   --     beginning at a given ASCII value
   
   -- N is the depth to permute
   -- B is the ASCII value to start from
   -- so P2(1,49) returns 21 cr 12
   -- P2(2,53) returns 675 cr 765 cr 756 cr 576 cr 657 cr 567
   -- breakpoint
   if N = 0 then return numToChar(B) & cr
   put _permute(N - 1,B) into T
   add B to N
   repeat with i = B to N - 1
      put T into T2
      replace numToChar(i) with numToChar(N) in T2
      replace cr with numToChar(i) & cr in T2
      put T2 after R
   end repeat
   replace cr with numToChar(N) & cr in T
   return R & T
end _permute


function arrayToTabTable tArray
   /* arrayToTabTable Table
   Syntax:
   arrayToTabTable (tArray)
   Examples:
   put arrayToTabTable (tArray) into foo
   Description:
   Returns a tab-delimited table from a two-dimensional array
   .    See tabTableToArray
   
   tArray["_column_names_"] may contain a tab-delim list of column names
   .     and tArray["_row_names_"] may contain a cr-delim list of row names
   .     in which case array is tArray[tRowName][tColName]
   if these are empty then
      .     array is tArray[n][i], where n = rowNumber, i = columnNumber
      
      Source:
      Peter M. Brigham, pmbrig@gmail.com
      arrayToTabTable */
      /* Include
      tabTableToArray
      */
      
      put the keys of tArray into tKeys
      put the number of lines of tKeys into nbrLines
      if nbrLines = 0 then return empty -- not an array
      filter tKeys without "_column_names_"
      filter tKeys without "_row_names_"
      put the number of lines of the keys of tArray[line 1 of tKeys] into nbrCols
      if nbrCols = 0 then return empty -- not a 2-dimensional array
      set the itemdelimiter to tab
      put tArray["_column_names_"] into colNames
      if colNames <> empty then
         -- column headers and row names are stored.
         -- first row must be column headers, first col must be row names
         put tArray["_row_names_"] into rowNames
         put colNames into tTable
         repeat for each line tRowName in rowNames
            put tRowName into tableRow
            repeat for each item tCol in colNames
               if tCol = empty then next repeat
               put tArray[tRowName][tCol] into tElement
               if tCol is not among the lines of the keys of tArray[tRowName] then next repeat
               put tab & tElement after tableRow
            end repeat
            put cr & tableRow after tTable
         end repeat
      else
         repeat with n = 1 to nbrLines
            repeat with i = 1 to nbrCols
               put tArray[n][i] into item i of line n of tTable
            end repeat
         end repeat
      end if
      return tTable
end arrayToTabTable


function tabTableToArray tTable,withHeaders
   /* tabTableToArray Table
   Syntax:
   tabTableToArray (tTable,[withHeaders])
   Examples:
   put tabTableToArray (tTable) into foo
   put tabTableToArray (tTable,true)
   Description:
   Returns a 2-dimensional array from a tab-delimited table
   .    See arrayToTabTable
   
   if withHeaders = true then first line is treated as column titles
   and first column is treated as row titles, data is stored as 
   tArray[rowName][colName]
   
   headers are stored in tArray["_row_names_"] and tArray["_column_names_"]
   
   if withHeaders = false (default) then array is tArray[n][i], 
   where n = rowNumber, i = columnNumber
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   tabTableToArray */
   /* Include
   arrayToTabTable
   */
   
   if tab is not in tTable then return empty
   if withHeaders = empty then put false into withHeaders
   set the itemdelimiter to tab
   if withHeaders then
      put line 1 of tTable into colHdrsList
      delete line 1 of tTable
      put (the number of items of colHdrsList) into nbrItems
      repeat for each line tLine in tTable
         put item 1 of tLine & cr after rowHdrs
         repeat with i = 2 to nbrItems
            put item i of tLine into tArray[item 1 of tLine][item i of colHdrsList]
         end repeat
      end repeat
      put line 1 to -1 of rowHdrs into tArray["_row_names_"]
      put colHdrsList into tArray["_column_names_"]
   else
      -- first get the max number of items in the lines
      -- in case of empty trailing items in some lines
      put 0 into maxItems
      repeat for each line tLine in tTable
         put max(maxItems,the number of items of tLine) into maxItems
      end repeat
      repeat with n = 1 to the number of lines of tTable
         repeat with i = 1 to maxItems
            put item i of line n of tTable into tArray[n][i]
         end repeat
      end repeat
   end if
   return tArray
end tabTableToArray


function toTitleCase str, exception
   /* toTitleCase Text
   Syntax:
   toTitleCase (str,excpt)
   Examples:
   toTitleCase ("hello)  -->  "Hello"
   toTitleCase ("this is a test")  -->  "This is a Test"
   toTitleCase ("this is a test","test")  -->  "This is a test"
   toTitleCase ("this is a test",",is")  -->  "This is A test"
   
   Description:
   Capitalizes the first letter of each word not in the exception list:
   "the,a,an,and,after,as,at,but,by,for,from,in,is,into,of,off,on,or,
   onto,over,than,to,via,with"
   
   exception is a comma seperated list of exceptions to be added to the 
   exceptions above.  if the first item of exception is empty then the entire
   list will be replaced with the remainder of what is in exception.
   Source:
   adapted from Peter M. Brigham, pmbrig@gmail.com
   toTitleCase */
   
   put "the,a,an,and,after,as,at,but,by,for,from,in,is,into,of,off,on,or," \
         & "onto,over,than,to,via,with" into exceptionList
   if exception <> empty then
      repeat for each item x in exception
         if x is empty then
            put empty into exceptionList
            next repeat
         end if
         if x is not among the items of exceptionList then put comma & x after exceptionList
      end repeat
   end if
   -- edit this as needed
   put toLower(str) into str
   put toUpper(char 1 of str) into char 1 of str
   repeat with n = 2 to the number of words of str
      put word n of str into tWord
      if tWord is among the items of exceptionList then next repeat
      put toUpper(char 1 of word n of str) into char 1 of word n of str
   end repeat
   return str
end toTitleCase


function truncateInMiddle str, n, breakIndex
   /* truncateInMiddle Text
   Syntax:
   truncateInMiddle (str, n, [breakIndex])
   Examples:
   Description:
   truncates a string in the middle, with an ellipsis between the start and the end
   
   .   str = string to be truncated
   .   n = total length of the shortened string
   .   breakIndex = number of the character to break on (defaults to n/2)
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   truncateInMiddle */
   
   
   if n = empty then return str
   if breakIndex = empty then put n div 2 into breakIndex
   if breakIndex > n then return str
   put char 1 to breakIndex of str into firstPart
   put char (breakIndex - n + 1) to -1 of str into lastpart
   return firstPart & numtochar(201) & lastpart -- ellipsis = option-semicolon, numtochar(201)
end truncateInMiddle


function userCanSeeControl tObjRef
   /* userCanSeeControl Properties
   Syntax:
   userCanSeeControl (tObjRef)
   Examples:
   userCanSeeControl (tObjRef)
   Description:
   Tests tObjRef visability -- returns true or false
   
   The visible of a control may be true but the control may not actually be visible,
   if it is contained in a group that is not visible or if it is hidden behind another object
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   userCanSeeControl */
   /* Include
   controlAndGroupVisible
   */
   
   if not controlAndGroupVisible(tObjRef) then return false
   -- if tObjRef is not visible and in a visible group hierarchy then we're done
   -- now test to see if it is behind another control:
   put the layer of tObjRef into objLayer
   put the rect of tObjRef into objRect
   put (item 1 of objRect),(item 2 of objRect) into ul
   put (item 3 of objRect),(item 2 of objRect) into ur
   put (item 1 of objRect),(item 4 of objRect) into ll
   put (item 3 of objRect),(item 4 of objRect) into lr
   repeat with n = the number of controls down to objLayer + 1
      put the long name of control n into testObject
      if word 1 of testObject = "group" then
         if the opaque of testObject = false then
            next repeat
            -- continue considering a group only if it could obscure tObjRef
         end if
      end if
      if not controlAndGroupVisible(testObject) then next repeat
      -- ignore if testObject can't obscure anything
      if not (ul is within the rect of testObject) then next repeat
      if not (ur is within the rect of testObject) then next repeat
      if not (ll is within the rect of testObject) then next repeat
      if not (lr is within the rect of testObject) then next repeat
      -- tObjRef is within the rect of a visible control (testObject)
      --     with higher layer, so:
      return false
   end repeat
   -- all objects with higher layers fail to hide tObjRef so:
   return true
end userCanSeeControl

function controlAndGroupVisible tObjRef
   /* controlAndGroupVisible Properties
   Syntax:
   controlAndGroupVisible (tObjRef)
   Examples:
   controlAndGroupVisible (tObjRef)
   Description:
   test whether the object and all its containing groups have visible = true
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   controlAndGroupVisible */
   
   if not the visible of tObjRef then return false
   put the long owner of tObjRef into tOwner
   if word 1 of tOwner = "card" then
      return the vis of the long owner of tOwner
   end if
   return controlAndGroupVisible(tOwner)
end controlAndGroupVisible


function wordOffsets str,tContainer,matchWhole
   /* wordOffsets Text Items
   Syntax:
   wordOffsets (str,tContainer,[matchWhole])
   Examples:
    put "Hello World" & cr & "World of Goo" & cr &"GoodBye Cruel World" & cr into x
    if wordoffsets("World",x) <> "2,3,8" then throw "problem"
    
   Description:
   returns a comma-delimited list of all the wordOffsets of str in tContainer
   
   . if matchWhole = true then only whole words are located
   .    else will find word matches everywhere str is part of a word in tContainer
   .    note that in LC words will include adjacent puncutation,
   .       so using matchWhole = true may exclude too many "words"
   
   duplicates are stripped out
   eg wordOffsets("co","the common coconut") = 2,3   not   2,3,3
   note: to get the last wordOffset of a string in a container (often useful)
   .    use "item -1 of wordOffsets(...)"
   
   Source:
   by Peter M. Brigham, pmbrig@gmail.com
   wordOffsets */
   
   if matchWhole = empty then put false into matchWhole
   put offsets(str,tContainer) into offList
   if offList = 0 then return 0
   repeat for each item i in offList
      put the number of words of (char 1 to i of tContainer) into wdNbr
      if matchWhole then
         if word wdNbr of tContainer <> str then next repeat
      end if
      put 1 into A[wdNbr]
      -- using an array avoids duplicates
   end repeat
   put the keys of A into wordList
   sort lines of wordList ascending numeric
   replace cr with comma in wordList
   return wordList
end wordOffsets

function offsets str,tContainer,includeOverlaps
   /* offsets Text Items
   Syntax:
   offsets (str,tContainer,[includeOverlaps])
   Examples:
   put "Hello World" & cr & "World of Goo" & cr & "GoodBye Cruel World" & cr into x
   if offsets("World",x) <> "7,13,40" then throw "problem"
   Description:
   returns a comma-delimited list of all the offsets of str in tContainer
   returns 0 if not found
   
   third param is optional:
   .     offsets("xx","xxxxxx") returns "1,3,5" not "1,2,3,4,5"
   .     ie, by default, overlapping offsets are not counted
   .     if you want overlapping offsets then pass "true" in 3rd param
   
   note: to get the last occurrence of a string in a container (often useful)
   .     use "item -1 of offsets(...)"
   Source:
   by Peter M. Brigham, pmbrig@gmail.com
   offsets */
   
   if str is not in tContainer then return 0
   if includeOverlaps = empty then put false into includeOverlaps
   put empty into offsetList
   put 0 into startPoint
   repeat
      put offset(str,tContainer,startPoint) into thisOffset
      if thisOffset = 0 then exit repeat
      add thisOffset to startPoint
      put startPoint & comma after offsetList
      if not includeOverlaps then
         add length(str)-1 to startPoint
      end if
   end repeat
   return item 1 to -1 of offsetList -- delete trailing comma
end offsets


function asciiHashCode tString, howlong, tPassword
   /* asciiHashCode Compression/Encription
   Syntax:
   asciiHashCode (tString, [howlong], [tPassword])
   Examples:
   asciiHashCode ("This is a test")
   asciiHashCode ("This is a test", 13)
   asciiHashCode ("This is a test",, "password")
   Description:
   Returns an alphanumeric string of length howlong
   .    (up to 20 chars, default = 12) that is a hash of the input string
   
   uses SHA-1 for high-end (though not perfect) cryptographic security
   
   allows adding a password as input so that the hash can be duplicated only
   .    with the correct password
   
   if tPassword is empty, the hash is stable and is dependent
   .   only on the content of tString
   
   with an output length of 13, the number of unique strings is
   .    ~ 2 * 10^23, greater than the number of stars in the universe,
   .    so the chance of random duplication is essentially 0
   .    default length of 12 should actually be sufficient   :-)
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   asciiHashCode */
   
   if howlong = empty then put 12 into howlong
   try
      put sha1digest(tString & tPassword) into tDigest
   catch tErr
      put md5digest(tString & tPassword) into tDigest
      -- if LC version < 4.6
   end try
   put "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" \
               into codeChars
   put length(codeChars) into howManyCodeChars
   repeat with i = 1 to the number of chars of tDigest
      put i wrap howlong into whichChar
      add chartonum(char i of tDigest) to A[whichChar] 
   end repeat
   repeat with j = 1 to howlong
      put A[j] wrap howManyCodeChars into thisCharNum
      put char thisCharNum of codeChars into char j of finalCodeString
   end repeat
   -- now mix the characters
   put howlong div 2 into halfway
   repeat with i = 1 to halfway
      put char -1 of finalCodeString into moveChar
      delete char -1 of finalCodeString
      put moveChar after char 2*i - 1 of finalCodeString
   end repeat
   return finalCodeString
end asciiHashCode



command fillimageWithColor pImage, pColor
   /* fillimageWithColor Image
   Syntax:
   fillimageWithColor pImage, pColor   # Command #
   Examples:
   put long id of img 1 into pImage --- THE TARGET IMAGE
     put "255,0,0" into pColor --- THE RGB COLOR
     fillimageWithColor pImage, pColor
   Description:
   Fills an image with a solid color.
   
   pImage is the long ID of the image to be filled
   pColor is the RGB color    "r,g,b"
   Source:
   Scott Rossi,Tactile Media via use-livecode list
   fillimageWithColor */
   
     put binaryEncode("CCCC",0,item 1 of pColor,item 2 of pColor,item 3 of pColor) into theData
     repeat (width of pImage * height of pImage)
           put theData after theColorData
     end repeat
     set imageData of pImage to theColorData
end fillimageWithColor

on setPostMarkAPIKEY  theKey
   /* setPostmarkAPIKEY Postmark
   Syntax:
   setPostmarkAPIKEY  theKey   # Command #
   Examples:
   setPostmarkAPIKEY  "cb4e9db4-fa22-4a22-b831-6a35fqf9bf9c"
   Description:
   This command initializes the APIKey that you should get from your postmark account.
   
   The APIKEY is stored as a custom property in your library stack under the 
   custompropertyset: "Library"
   
   This must be set before trying to call the sendPostMarkEmail
   Source:
   Michael Doub
   setPostmarkAPIKEY */
   /* Include
   sendPostMarkEmail
   */
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   set the uPostMarkAPIKey of me to theKey
   set the custompropertyset of me to temp
end setPostmarkAPIKEY

on sendPostMarkEmail pMessageJSON
   /* sendPostMarkEmail Postmark
   Syntax:
   sendPostMarkEmail "JSON_structure" | json_array   # Command #
   Examples:
   put "mike@doub.com" into tA["To"]
   put "test@mydomain.com" into tA["From"]
   put "test array" into tA["Subject"]
   put "This is a test from an array" into tA["TextBody"]
   sendPostMarkEmail tA
   
   Description:
   This commands sends an email using the Postmark email service:  
   https://postmarkapp.com/
   
   An error will be thrown if the APIKEY was not initialized with setPostmarkAPIKEY before this call.
   
   Input:  
   .    pMessageJSON - this can be either a JSON structure as defined by the PostMark 
   .           Documentatio: http://developer.postmarkapp.com/developer-send-api.html  
   .           or an array that will be processed by arrayToJSON to produce that 
   .            JSON structure so the naming of the keys is significant
   
   Return:
   .     the responce from the postmarkapi.com endpoint will be in "the result"
   Source:
   Michael Doub
   sendPostMarkEmail */
   /* Include
   setPostmarkAPIKEY
   arrayToJson
   */
   put the custompropertyset of me into temp
   set the custompropertyset of me to "Library"
   put the uPostMarkAPIKey of me into tAPIKEY
   set the custompropertyset of me to temp
   if tAPIKey is empty then throw "Error: missing postmark APIKEY"
   get the keys of pMessageJSON
   if it <> empty then
      put arrayToJson(pMessageJSON) into outgoing
   else
      put pMessageJSON into outgoing
   end if
   set the httpHeaders to "Accept: application/json" & return \ 
         & "Content-Type: application/json" & return \
         & "X-Postmark-Server-Token: " & tAPIKEY
   post outgoing to "https://api.postmarkapp.com/email"
   return it
end sendPostMarkEmail

function Clean fs
   /* Clean Text
   Syntax:
   Clean ("Text String")
   Examples:
   Clean ("Text String")
   Description:
   Remove leading and trailing returns tabs and spaces
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   Clean */
   
   repeat while char 1 of fs is in return&tab&space
      delete char 1 of fs
   end repeat
   repeat while char -1 of fs is in return&tab&space
      delete char -1 of fs
   end repeat
   return fs
end Clean

function Thousands fn,posDel,fractionDel
   /* Thousands Text
   Syntax:
   Thousands (number_string, [posDel],[fractionDel])
   Examples:
   Thousands ("1234567.89012345") --> "1'234'567.890 123 45"
    Thousands ("1234567.89012345", comma, comma) --> "1,234,567.890,123,45"
    Thousands ("123.456")  --> "123.456"
   Description:
   Returns the number with apostrophes marking groups of three digits in the integer 
   part and spaces marking groups of three digits in the decimal part.
   
   The ability to control the delimers on the right and left side of the decimal is optional
  Source:
  http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   Thousands */
   
   local ldoto  -- offset of the decimal point
   local lint   -- length of the integer part
   local ldec   -- length of the decimal part
   local ich    -- index into character string fn
   local ll     -- length of fn
   local lnrapostrophes  -- number of apostrophes to be inserted
   local lnrspaces       -- number of spaces to be inserted
   Local pDel,fDel
   
   -- number n of apostrophes for length lint of integer part:
   -- lint  0  1  2  3  4  5  6  7  8  9 10 11 12 ...
   -- n     0  0  0  0  1  1  1  2  2  2  3  3 ...
   -- n = (lint-1) div 3 if lint >0 and 0 if lint = 0
   -- number n of spaces for length ldec of decimal part:
   -- ldec  0  1  2  3  4  5  6  7  8  9 10 11 12 ...
   -- n     0  0  0  0  1  1  1  2  2  2  3  3  ...
   --    --> same formula.
   if posDel = empty then put "'" into posDel
   if fractionDel = empty then put space into fractionDel
   put length(fn) into ll
   put offset(".",fn) into ldoto
   if ldoto=0 then  -- it is an integer
      put ll+1-4 into ich
      put ll into lint
      put 0 into ldec
   else
      put ldoto-4 into ich
      put ldoto-1 into lint
      put ll-ldoto into ldec
   end if
   -- do the apostrophes first:
   if lint>0 then put (lint-1) div 3 into lnrapostrophes else put 0 into lnrapostrophes 
   repeat
      if ich<=0 then exit repeat
      put posDel after char ich of fn
      subtract 3 from ich
   end repeat
   -- now do the spaces in the decimal part:
   if ldec>0 then put (ldec-1) div 3 into lnrspaces else put 0 into lnrspaces 
   if lnrspaces=0 then return fn -- this is the most common case:  the number has less than three decimal places if any.
   put lnrapostrophes+ldoto+3 into ich
   repeat with i=1 to lnrspaces
      put fractionDel after char ich of fn
      add 4 to ich
   end repeat
   return fn
end Thousands

function UnThousands fn
   /* UnThousands Text
   Syntax:
   UnThousands ("string")
   Examples:
   get Thousands ("1234567.89012345") --> "1'234'567.890 123 45"
   get UnThousands(it) -->  "1234567.89012345"
   Description:
   Inverse of Thousands
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   UnThousands */
   replace "'" with "" in fn; replace " " with "" in fn
   return fn
end UnThousands

function Padded fs,fn
   /* Padded Text
   Syntax:
   Padded ("String",desired_length)
   Examples:
   Padded ("String",10) --> "String    "
   Description:
   Pads a stringwith blanks at the end to make its length equal to a specified length.
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   Padded */
  
   repeat with i=1 to fn-length(fs)
      put space after fs
   end repeat
   return fs
end Padded


function Indent fs,fn
   /* Indent Text
   Syntax:
   Indent (fs,fn)
   Examples:
   Indent (fs,5)
   Description:
   Puts fn spaces before every line of fs.
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   Indent */
   
   put "" into lIndent
   repeat with i=1 to fn
      put space after lIndent
   end repeat
   repeat with i=1 to the number of lines of fs
      put lIndent before line i of fs
   end repeat
   return fs
end Indent


on MultiSortFields 
   /* MultiSortFields Fields
   Syntax:
   MultiSortFields  fld "A", fld "B", [fld "C"] ...   # Command #
   Examples:
   MultiSortFields  fld "A", fld "B"
   Description:
   Sort lines of a set of fields according to one field
   
   The first field will be sorted by line, the others will be rearranged accordingly.
   
   Assumption:  all fields have the same number of lines
   
   If some lines are numbers, the comparison for sorting can be numeric or text.
   Numbers will "float" to the top and be sorted there numerically.
   
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   MultiSortFields */
   /* Include
   MultipleSorted
   */`
   
   put "" into lFields
   repeat with i=1 to the paramcount
      put "field "&quote&param(i)&quote&"," after lFields
   end repeat
   delete last char of lCommand
   do "put MultipleSorted("&lFields&") into lv"
   repeat with i=1 to the paramcount
      do "put lv["&i&"] into field "&quote&param(i)&quote
   end repeat
end MultiSortFields


Private function MultipleSorted  -- parameters
 
  --  Call:  in two stages:
  --  put multiplesorted(field "A",field "B", field "C") into lv
  --  put lv[1] into field "SA"; put lv[2] into field "SB"; put lv[3] into field "SC"
 
  put the paramcount into nParams
  repeat with i=1 to nParams
    put "" into ArrayOfSorted[i]
  end repeat
  -- do a simple insertion sort:
  put 0 into iLinesPlaced; put 0 into lCurrentLine
  repeat for each line lLineToBeInserted in param(1)
    put false into lLinePlaced;   add 1 to lCurrentLine
    -- go find where in the corresponding sorted result to place it:
    put 0 into lCurrentPlacedLine
    repeat for each line lLineFromPlaced in ArrayOfSorted[1]
      add 1 to lCurrentPlacedLine
      if lLineToBeInserted < lLineFromPlaced  then  -- found a place to put this line
        put lLineToBeInserted&return before line lCurrentPlacedLine of ArrayOfSorted[1]
        repeat with iOtherText = 2 to nParams  -- the lines of the other fields
          put (line lCurrentLine of param(iOtherText))&return before line lCurrentPlacedLine of ArrayOfSorted[iOtherText]
        end repeat
        put true into lLinePlaced
        exit repeat
      end if
    end repeat
    if not lLinePlaced then  -- put it at the end
      put lLineToBeInserted&return after ArrayOfSorted[1]
      repeat with iOtherText=2 to nParams
        put (line lCurrentLine of param(iOtherText))&return after ArrayOfSorted[iOtherText]
      end repeat
    end if
    add 1 to iLinesPlaced; -- put "{"&ArrayOfSorted[1]&"}"
  end repeat
  return ArrayOfSorted
end MultipleSorted


function ISODateTime
   /* ISODateTime Date
   Syntax:
   ISODateTime()
   Examples:
   ISODateTime()
   Description:
   Returns the date and time as   YYYY-MM-DD HH:MM:SS W
   where W is the number of the day in the week (1=Monday, 7=Sunday)
   
   The dateitems conversion returns a USA weekday number.
   
   .    Convert this to standard weekday number:
   .    Day:                        M  T  W  T  F  S  S      Day of the week
   .    nr:                           2  3  4  5  6  7  1      USA number, what we get from the 
   .                                                                   dateitems
   .    real:                        1  2  3  4  5  6  7      Standard number, what we want
   .                                                                   we will need to use modular arithmetic, 
   .                                                                   so consider:
   .    real -1:                   0  1  2  3  4  5  6      this looks like the result of a mod 7 operation
   .    nr+5:                      7  8  9 10 11 12  6   and this gives real-1 after a mod 7
   .    (nr+5) mod 7 +1:   1  2  3  4  5  6  7       done!
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   ISODateTime */
   /* Include
   */
   
   
   put the long time into t; convert t to dateitems  -- this works no matter what the user's preferences are.
   -- Dateitems results in YYYY,MM,DD,HH,MM,SS,WD
   -- the numbers returned must also be prefixed with "0" if less than 10.
   put item 1 of t into lY
   put item 2 of t into lM;  if lM  < 10 then put "0" before lM
   put item 3 of t into lD;  if lD  < 10 then put "0" before lD
   put item 4 of t into lHH; if lHH < 10 then put "0" before lHH
   put item 5 of t into lMM; if lMM < 10 then put "0" before lMM
   put item 6 of t into lSS; if lSS < 10 then put "0" before lSS
   put item 7 of t into lW;  put (lW +5)mod 7 +1 into lW
   return lY&"-"&lM&"-"&lD&" "&lHH&":"&lMM&":"&lSS&" "&lW
end ISODateTime

function ISOtoSeconds ft
   /* ISOtoSeconds Date
   Syntax:
   ISOtoSeconds (ft)
   Examples:
   ISOtoSeconds (ft)
   Description:
   Converts a date-time in format YYYY-MM-DD hh:mm:ss into the 
   number of seconds since midnight 1 January 1970
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   ISOtoSeconds */

   replace "-" with "," in ft; replace ":" with "," in ft; replace space with "," in ft; put ft&",0" into ft
   convert ft to seconds
   return ft
end ISOtoSeconds
 
function SecondsToISO fs
   /* SecondsToISO Date
   Syntax:
   SecondsToISO (fs)
   Examples:
    SecondsToISO (fs)
   Description:
   Converts a number of seconds since midnight of 1 Januray 1970 to a date 
   of format YYYY-MM-DD hh:mm:ss
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   SecondsToISO */
   
   
   convert fs to dateitems
   repeat with i=2 to 6
      if item i of fs < 10 then put "0" before item i of fs
   end repeat
   return item 1 of fs&"-"&item 2 of of fs&"-"&item 3 of fs&space&item 4 of fs &":"&item 5 of fs &":"&item 6 of fs
end SecondsToISO



on RecurseOverFolders fFolderPath,fFileHandler,fFolderHandler,fCaller
   /* RecurseOverFolders File
   Syntax:
   RecurseOverFolders fFolderPath,fFileHandler,fFolderHandler,fCaller   # Command #
   Examples:
   RecurseOverFolders fFolderPath,fFileHandler,fFolderHandler,fCaller
   Description:
   fFolderPath is the path to the folder we want to recurse over,
   fFileHandler is the handler to call for each file, with the file path as argument
   fFolderHandler is the handler to call for each folder, with the folder path as argument
   fCaller is the name of the object where the call-back handlers are located.
   
   items are handled in the alphabetical order of the Finder items whose name starts 
   with "z" are excluded,  the call to FolderItems excludes invisible files and "Icon(13)" files.
   
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   RecurseOverFolders */
   /* Include
   RecurseOverFoldersDoFolders
   */
   
   put the defaultfolder into lDefaultFolder
   if there is a folder fFolderPath then
      put fFolderPath into lRootFolder
      set the defaultfolder to lRootFolder
      put 1 into lFolderDepth
      RecurseOverFoldersDoFolders lRootFolder,lFolderDepth,fFileHandler,fFolderHandler,fCaller
   else
      answer "No such folder..."
   end if
   set the defaultfolder to lDefaultFolder
end RecurseOverFolders

on RecurseOverFoldersDoFolders fFolderPath,fFolderDepth,fFileHandler,fFolderHandler,fCaller
  -- get the alphabetical mixed list of files and folders:
  put empty into lItems
  FolderItems fFolderPath,lItems
  put the keys of lItems into lItemKeys; put (the number of lines of lItemKeys)/2 into nItems
  -- lItems[i,1] is either "f" for a file, or "d" for a directory (folder)
  -- lItems[i,2] is the name of the item
  repeat with iItem=1 to nItems
    if char 1 of lItems[iItem,2] = "z" then next repeat
    if lItems[iItem,1] = "f" then
      put fFileHandler & space & quote&fFolderPath&(lItems[iItem,2])&quote&","&fFolderDepth into lCall; send lCall to fCaller
    else
      put fFolderHandler & space & quote&fFolderPath&(lItems[iItem,2])&"/"&quote&","&fFolderDepth into lCall; send lCall to fCaller 
      RecurseOverFoldersDoFolders fFolderPath&(lItems[iItem,2])&"/",fFolderDepth+1,fFileHandler,fFolderHandler,fCaller
    end if
  end repeat
end RecurseOverFoldersDoFolders

function RelativePath fStartFolder,fDestinationFolder
   /* RelativePath FIle
   Syntax:
   RelativePath (fStartFolder,fDestinationFolder)
   Examples:
   RelativePath (fStartFolder,fDestinationFolder)
   Description:
   Computes the path difference from position fStartFolder to fDestinationFolder in the 
   file tree.  We are at fStartFolder, how to get to fDestinationFolder?  This relative path 
   can be of the form "../../folder/folder" if we have to go up to a common parent first.
   Both positions are given as paths without file names e.g.  "folder/folder/...folder/"
   and it is assumed that at least the first folder is common (but it is not necessarily the 
   root of the file system).
   
   The algorithm tries to find the first point at which the paths differ.
   During the comparison we may reach the end of one of the paths, i.e. the shorter path
   is completely contained in the longer one.  If the destination is longer, then we just use 
   the remaining part of the destination, since it is inside the start folder.  An example is:
   .       start:              a/b/c/
   .       destination:    a/b/c/d/e/f/
   .       relative path:  d/e/f/
   
   If the start is longer, then it is inside the destination and all we need to do is go up the
   tree to that point.  An example is:
   .       start:              a/b/c/d/e/f/
   .       destination:    a/b/c/
   .       relative path:  ../../../
   
   In the remaining case a difference is found somewhere before reaching the end of 
   either path.  Then first one has to go back up from the start folder to this common 
   point and then down to the destination.  An example is:
   .       start:              a/x/y/
   .       destination:    a/b/c/d/e/f/
   .       relative path:  ../../b/c/d/e/f/
   
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   RelativePath */
   
   
   
   local lRelativePath      -- where we prepare the result
   local nStartItems        -- the number of folders in the start folder path
   local nDestinationItems  -- the number of folders in the destination folder path
   local lComparing         -- the index of the item in both paths that is being compared
   
   set the itemdelimiter to "/"
   put the number of items of fStartFolder into nStartItems
   put the number of items of fDestinationFolder into nDestinationItems    
   put 0 into lComparing
   put empty into lRelativePath
   
   repeat
      add 1 to lComparing
      if lComparing > nStartItems then
         -- everything up to here was the same and the destination is longer:
         -- the relative part is just the rest of the destination path:
         repeat while lComparing <= nDestinationItems
            put (item lComparing of fDestinationFolder)&"/" after lRelativePath
            add 1 to lComparing
         end repeat
         exit repeat  -- we have finished.
      else
         if lComparing > nDestinationItems then
            -- everything up to here was the same and the destination is shorter,
            -- we just need to go up the tree a little because we started inside the destination
            repeat while lComparing <= nStartItems
               put "../" after lRelativePath
               add 1 to lComparing
            end repeat
            exit repeat  -- we have finished.
         else
            if item lComparing of fStartFolder <> item lComparing of fDestinationFolder then
               -- the paths are different at this point.
               -- first go up the tree from inside the start folder up to this common point:
               repeat with j=0 to nStartItems-lComparing
                  put "../" after lRelativePath
               end repeat
               -- now go down the destination path:
               repeat while lComparing <= nDestinationItems
                  put (item lComparing of fDestinationFolder)&"/" after lRelativePath
                  add 1 to lComparing
               end repeat
               exit repeat  -- we have finished.
            end if
         end if
      end if
   end repeat
   return lRelativePath
end RelativePath

function Overlap fRect1,fRect2
   /* Overlap Graphics
   Syntax:
   Overlap (fRect1,fRect2)
   Examples:
    Overlap (the rect of graphic "fRect1", the rect of graphic "fRect2")
   Description:
   Returns true if the rectangles overlap.
   It is easier to compute when two rectangles do not overlap:
   the left of one must be to the right of the right of the other, or
   the right must be to the left of the left, or ...
   at least one of these must be true.
   Source:
   http://www.robertcailliau.eu/Alphabetical/L/LiveCode/General%20Routines/
   Overlap */
   
   return not (item 1 of fRect1 > item 3 of fRect2 or\
   item 2 of fRect1 > item 4 of fRect2 or\
   item 3 of fRect1 < item 1 of fRect2 or\
   item 4 of fRect1 < item 2 of fRect2 )
end Overlap

on positionLineInFld  pline, obj, pWhere
   /* positionLineInFld Fields
   Syntax:
   positionLineInFld linenbr,long_ID_of_Field,["Top"\"Center"\"Bottom"]   # Command #
   Examples:
   positionLineInFld 20,the long ID of fld "foo"
   positionLineInFld 20,the long ID of fld "foo", "Center"
   Description:
   Sets the scroll of a field so the line specified is in the specifed 
   location within the visiable field.  Both fixed and non-fixed line 
   heights are supported.
   Source:
   Michael Doub with a special thanks to James Hale for his help.
   positionLineInFld */
   set the lockscreen to true
   put the height of obj  into tFieldHeight
   
   put 0 into tScroll
   if pline > 1 then
      repeat with x = 1 to pLine
         --         put x,\
         --         the spacebelow of line x-1 of obj,\
         --         the spaceabove of line x of obj ,\
         --         the formattedheight of line x of obj,\
         --         tScroll & return after msg
         Add the spacebelow of line x-1 of obj to tScroll
         Add the spaceabove of line x of obj to tScroll
         Add the formattedheight of line x of obj to tScroll
      end repeat
   else
      set the vscroll of obj to 0
   end if
   
   switch pWhere
      case "Top"
         subtract the formattedheight of line pline of obj from tScroll
         break
      case "Center"
         subtract  (tFieldHeight / 2) from tScroll
         subtract (the formattedheight of line pline of obj /2) from tScroll
         subtract the spaceabove  of line pline of obj  from tScroll
         add the topmargin of obj to tScroll
         break
      case "Bottom"
         subtract the formattedheight of line pline of obj from tScroll
         -- tScroll  is now the top of the line
         select line  -1 of  obj
         select line pLine of  obj
         select empty
         put the scroll of obj into bScroll -- this is the top of the last  wrapped line
         put the formattedheight of line pline of obj -(bScroll - tScroll) into lastLineHeight
         Add lastLineHeight to bScroll
         subtract tFieldHeight from bScroll
         add the bottommargin of obj to bScroll
         set the vscroll of obj  to trunc(bScroll)
         put bScroll into tScroll
         break
      default
         put tScroll - the formattedheight of line pline of obj  into tScroll
   end switch
   set the vscroll of obj  to trunc(tScroll)
   -- put the  vscroll of obj after msg
   set the lockscreen to false
end positionLineInFld

on DummyTextData obj, cmd
   /* DummyTextData Debugging
   Syntax:
   DummyTextData obj, cmdArray   # Command #
   Examples:
   put true into cmd["colorize"]
   DummyTextData long id of fld "Foo", cmd
   Description:
   This handler generates a dummy data for texting fields.  Random
   ColorNames are used as the words of the text.  Random amounts of
   the min and max values are used unless min and max are equal
   The keys of the input array should be self explainitory to their function
   the keys and defaults are:
   
   lines, 10
   minTextSize, 10
   maxTextSize, 18 
   minSentence,  5 
   maxSentence,   8 
   minIndent,  0 
   maxIndent,   20 
   colorize,   false 
   IndentEvery,  3 
   spaceBeforeEvery,  3 
   minAbove,  0 
   maxAbove,   5 
   spaceAfterEvery,   6 
   minBelow,   0
   maxBelow,   5
   periods,  true
   
   Source:
   Michael Doub
   DummyTextData */
   set the lockscreen to true
   if cmd is not an array then put empty into cmd["lines"]
   if cmd["lines"] is empty then put 10 into cmd["lines"]
   if cmd["minTextSize"] is empty then put 10 into cmd["minTextSize"]
   if cmd["maxTextSize"] is empty then put 18 into cmd["maxTextSize"]
   if cmd["minSentence"] is empty then put 5 into cmd["minSentence"]
   if cmd["maxSentence"] is empty then put 8 into cmd["maxSentence"]
   if cmd["minIndent"] is empty then put 0 into cmd["minIndent"]
   if cmd["maxIndent"] is empty then put 20 into cmd["maxIndent"]
   if cmd["colorize"] is empty then put false into cmd["pColorize"]
   if cmd["IndentEvery"] is empty then put 3 into cmd["IndentEvery"]
   if cmd["spaceAboveEvery"] is empty then put 3 into cmd["spaceAboveEvery"]
   if cmd["minAbove"] is empty then put 0 into cmd["minAbove"]
   if cmd["maxAbove"] is empty then put 5 into cmd["maxAbove"]
   if cmd["spaceBelowEvery"] is empty then put 6 into cmd["spaceBelowEvery"]
   if cmd["minBelow"] is empty then put 0 into cmd["minBelow"]
   if cmd["maxBelow"] is empty then put 5 into cmd["maxBelow"]
   if cmd["periods"] is empty then put true into cmd["periods"]
     put the colornames into theWords
   put empty into tArray
   repeat with L = 1 to cmd["lines"]
      if cmd["maxSentence"] <>cmd["minSentence"] then
         put random(cmd["maxSentence"]-cmd["minSentence"])+cmd["minSentence"] into sentence_count
      else
         put cmd["maxSentence"] into sentence_count
      end if
      repeat with W = 1 to sentence_count
         put line random(the number of lines in theWords) of theWords & space \
               into tA[L]["runs"][W]["text"]
         if cmd["maxTextSize"] <> cmd["minTextSize"] then
            put random (cmd["maxTextSize"]-cmd["minTextSize"])+cmd["minTextSize"] into text_size
         else
            put cmd["minTextSize"] into text_size
         end if
         put text_size into tA[L]["runs"][W]["style"]["textSize"]
      end repeat
      if cmd["periods"] then
         put "." into char -1 of tA[L]["runs"][W]["text"]
      else
         delete char -1 of tA[L]["runs"][W]["text"]
      end if
      if cmd["IndentEvery"] <> 0 then
         if L mod cmd["IndentEvery"] = 0 then
            if cmd["maxIndent"] > 0 then 
               if (cmd["maxIndent"] <> cmd["minIndent"]) then
                  put random (cmd["maxIndent"] - cmd["minIndent"]) + cmd["minIndent"] into the_Indent
               else
                  put cmd["minIndent"] into the_Indent
               end if
            end if
            put the_Indent into tA[L]["style"]["leftindent"]
         end if
      end if
      if cmd["spaceAboveEvery"] <> 0 then
         if L mod cmd["spaceAboveEvery"] = 0 then
            if (cmd["maxAbove"] <> cmd["minAbove"]) then
               put random (cmd["maxAbove"] - cmd["minAbove"]) + cmd["minAbove"] into the_above
            else
               put cmd["minAbove"] into the_above
            end if
            put the_above into tA[L]["style"]["spaceabove"]
         end if
      end if 
      if cmd["spaceBelowEvery"] <> 0 then
         if L mod cmd["spaceBelowEvery"] = 0 then
            if (cmd["maxBelow"] <> cmd["minBelow"]) then
               put random (cmd["maxBelow"] - cmd["minBelow"]) + cmd["minBelow"] into the_Below
            else
               put cmd["minBelow"] into the_Below
            end if
            put the_Below into tA[L]["style"]["spacebelow"]
         end if
      end if
   end repeat
   set the styledtext of obj to tA
   if cmd["colorize"] then
      put the text of obj into tA
      repeat with i = 1 to the number of words in tA
         put word i of tA into thecolor
         if the char -1 of thecolor = "." then delete char -1 of thecolor
         set the textcolor of word i of obj to thecolor
      end repeat
   end if
   set the lockscreen to false
end DummyTextData 


on positionCharInFld  pChar, obj, pWhere
   /* positionCharInFld Fields
   Syntax:
   positionCharInFld charNbr,long_ID_of_Field,["Top"\"Center"\"Bottom"]   # Command #
   Examples:
   positionCharInFld 20,the long ID of fld "foo"
   positionCharInFld 20,the long ID of fld "foo", "Center"
   Description:
   Sets the scroll of a field so the character specified is in the desired 
   location within the visiable field.  Both fixed and non-fixed line 
   heights are supported.
   Source:
   Michael Doub
   positionCharInFld */
   /* Include
   SoftLineBreaks
   */
   set the lockscreen to true
   put chartonum(char pChar of (text of obj)) into look
   put the number of lines of char 1 to pChar of (the text of obj) into pLine
   put the number of chars in line 1 to pline -1 of (the text of obj) + 1 into lineStartChars
   put the number of chars of (line 1 to pLine of (the text of obj))+1 into CharInLines -- account for the return on current line
   put the topmargin of obj into FieldTopMargin
   put empty into LineDetails
   put SoftLineBreaks (obj, pline,true) into LineDetails
   add 1 to item 2 of line -1 of LineDetails -- account for the cr of this line
   put the height of obj  into tFieldHeight
   put 0 into tScroll
   if pline > 1 then
      repeat with x = 1 to pLine
         Add the spacebelow of line x-1 of obj to tScroll
         Add the spaceabove of line x of obj to tScroll
         Add the formattedheight of line x of obj to tScroll
      end repeat
      subtract the formattedheight of line x of obj from tScroll  -- points to top of pLine
   else
      Add the spaceabove of line x of obj to tScroll
   end if
   -- now get to the top of the desired line
   if the number of lines in LineDetails > 1 then
      if pChar = 1 then
         put 1 into TargetChar
      else
         put pChar - lineStartChars into TargetChar
      end if
      repeat with x= 1 to the number of lines in LineDetails
         if TargetChar >= item 1 of line x of LineDetails and \
               TargetChar <= item 2 of line x of LineDetails then 
            put item 3 of line x of LineDetails into targetLineHeight
            exit repeat
         else
            add item 3 of line x of LineDetails to tScroll
         end if
      end repeat
   end if
   -- tScroll now points to the top of the soft line, 
   switch pWhere
      case "Top"
         break
      case "Center"
         subtract  (tFieldHeight / 2) from tScroll
         add (targetLineHeight/2) to tScroll
         break
      case "Bottom"
         subtract tFieldHeight  from tScroll
         add targetLineHeight to tScroll
         add bottommargin of obj to tScroll
         break
      default
         put tScroll - the formattedheight of line pline of obj  into tScroll
   end switch
   set the vscroll of obj  to trunc(tScroll)
   set the lockscreen to false
end positionCharInFld

function SoftLineBreaks obj, pline, plineSize
   /* SoftLineBreaks Fields
   Syntax:
   SoftLineBreaks (obj, pline, [plineSize])
   Examples:
   put  SoftLineBreaks (long id of fld "foo", pline) into x
   put  SoftLineBreaks (long id of fld "foo", pline, true) into x
   Description:
   This fuction returns information about how the text within a field
   has been soft wrapped.
   
   Each line represents a line that has been softwrapped with the field
   The lines contain the starting character and ending character of the
   .   soft wrapped line.  This implies that the last character of a soft
   .   wrapped line is a space or a tab
   Optionally, the line height of the softwrapped line is included.
   
   So you pass in a field id and a line number.  Lets say it wraps into 3
   lines in the field and you want the ontional lineSize.  The following 
   will be returned:
   .    1,36,24
   .    37,63,24
   .    64,85,22
   
   Note that the final CR of a line is NOT included in the last line.
   
   Source:
   Michael Doub
   SoftLineBreaks */
   
   if pLineSize is empty then put false into plineSize
   put 1 & comma into rData
   put the formattedText of line pline of obj into temp
   repeat for each line x in temp
      put the number of characters in x into tLen
      put item 1 of line -1 of rData + tLen -1 into tEnd
      put tEnd after rData
      if plineSize then 
         get the formattedrect of char item 1 of line - 1 of rData to \
               item 2 of line - 1 of rData of line pline of obj
         put comma & item 4 of it - item 2 of it after rData
      end if
      put cr & tEnd + 1 & comma after rData
   end repeat
   delete line -1 of rData
   return rData
end SoftLineBreaks

function  lineRanges obj
   /* lineRanges Fields
   Syntax:
   lineRanges (obj)
   Examples:
   lineRanges (long id of fld "foo")
   Description:
   This routine returns data for each visable line within the requested
   field.  One line of comma seperated information is returned for each
   line within the field,  The items returned in order are:
   .    - char number within the field of first char in the visiable line
   .    - char number within the field of last char in the visiable line
   .    - the height of the visiable line
   .    - a descriptor of the wrap-position:
   .            "<" indicates that this is the first line of soft wrapped line
   .            ">" indicates that this is the last line of soft wrapped line
   .            "-" indicates that this is a middle line of soft wrapped line
   .                     there maybe multiple  soft wrapped lines between the 
   .                     first and last visiable line
   .             "^" indicates that this line was NOT wrapped
   .     - spaceabove  for this line
   .     - spacebelow  for this line
   Source:
   Michael Doub
   lineRanges */
   /* Include
   SoftLineBreaks
   */
   put 0 into oS
   put empty into rData
   repeat with L = 1 to the number of lines of (text of obj)
      put SoftLineBreaks (obj, L, true) into thelist
      repeat with x = 1 to the number of lines in thelist
         put "-" into item 4 of line x of thelist
         put 0 into item 5 of line x of thelist
         put 0 into item 6 of line x of thelist
         add os to item 1 of line x of thelist
         add os to item 2 of line x of thelist
      end repeat
      if the number of lines in thelist = 1 then
         put "^" into item 4 of line 1 of thelist
         put the spaceabove line L of obj + 0 into item 5 of line 1 of thelist
         put the spacebelow line L of obj + 0 into item 6 of line 1 of thelist
      else
         put "<" into item 4 of line 1 of thelist
         put the spaceabove line L of obj + 0 into item 5 of line 1 of thelist
         put ">" into item 4 of line -1 of thelist
         put the spacebelow line L of obj + 0 into item 6 of line -1 of thelist
      end if
      put item 2 of line -1 of thelist into y
      put char y + 1 of (text of obj) into z
      if z = cr then
         add 1 to item 2 of the line -1 of theList
      end if
      put item 2 of the line -1 of thelist into os
      put thelist & cr after rData
   end repeat
   delete char -1 of rData
   return rData
end lineRanges

function PageRanges obj
   /* PageRanges Fields
   Syntax:
   PageRanges (long id of a fld) 
   Examples:
   put PageRanges (long id of fld "T") into tList
   Description:
   This is a function that performs the same function as the pageRanges property
   of a field with the exception that does take into account the spaceabove and
   spacebelow attributes of lines.  
   Source:
   Michael Doub
   PageRanges */
   /* Include
   lineRanges
   */
   put 0 into tScroll
   put 1 & comma into rData
   put the height of obj  into tFieldHeight
   --subtract the topmargin of obj from tFieldHeight
   --subtract the bottommargin of obj from tFieldHeight
   put the topmargin of obj into tTopMargin
   put lineRanges (obj) into tLineRanges
   
   -- Add item 7 to tLineRanges that is the running bottom of the line
   repeat with x = 1 to the number of lines in tLineRanges
      put item 4 of line x of tLineRanges into jump
      put item 7 of line x-1 of tLineRanges into item 7 of line x of tLineRanges -- last one
      switch jump
         case "<"
            add item 5 of line x of tLineRanges to item 7 of line x of tLineRanges  --spaceabove
            add item 3 of line x of tLineRanges to item 7 of line x of tLineRanges -- itself
            break
         case "-"
            Add item 3 of line x of tLineRanges to item 7 of line x of tLineRanges --  itself
            break
         case ">"
            add item 3 of line x of tLineRanges to item 7 of line x of tLineRanges -- itself
            Add item 6 of line x of tLineRanges to item 7 of line x of tLineRanges -- spacebelow
            break
         case "^"
            add item 5 of line x of tLineRanges to item 7 of line x of tLineRanges  --spaceabove
            add item 3 of line x of tLineRanges to item 7 of line x of tLineRanges -- itself
            Add item 6 of line x of tLineRanges to item 7 of line x of tLineRanges -- spacebelow
            break
      end switch
   end repeat
   
   put 1 into thepage
   put 0 into offst
   repeat with x = 1 to the number of lines in tLineRanges
      put item 7 of line x of tLineRanges - offst into totalHeight
      if totalHeight < tFieldHeight then
         put thepage into item 8 of line x of tLineRanges
      else
         add 1 to thepage
         put item 7 of line x-1 of tLineRanges into offst
         put thepage into item 8 of line x of tLineRanges
         put item 2 of line x-1 of tLineRanges & cr after rData
         put item 1 of line x of tLineRanges & comma after rData
      end if
   end repeat
   put item 2 of line -1 of tLineRanges after rData 
   return rData
end PageRanges



function ConvertXMLToArray pXML, pStoreEncodedAs, pUseValueKey, pForceNumberIndexForNodes
   /* ConvertXMLToArray Misc
   Syntax:
   ConvertXMLToArray (pXML, [pEncodedAs], [pUseValueKey], [pForceIndexForNodes])
   Examples:
   put ConvertXMLToArray (pXML) into tArray
   put ConvertXMLToArray (pXML), "utf8", true)
   Description:
   Converts an XML tree into a LiveCode multi-dimensional array.
   .
   .    pXML :  The xml to convert.
   .    pEncodedAs:  the Encoding of the XML. Must be a value that can 
   .            be passed to uniDecode. Default is "utf8".
   .    pUseValueKey  By default node values are stored in a key named 
   .            after the node. This means you can't have a node with attributes 
   .            and a node value. Pass in true if you want to store node values in 
   .            a '@value' key. This will allow a key to have both attributes 
   .            (in @attributes key) and a value (in @value key).
   .    pForceIndexForNodes A comma delimited list of node 
   .            names that should always have numbered indexes (NODE[index]) 
   .            added to them. This makes it easier to loop over results that may 
   .            have 1 or more results.
   .
   A nodes attributes will be stored as an array of it's "@attributes" key.
   Node names will retain the sequence information (i.e. node[1], node[2], etc.).
   This information is necessary to determine order that keys should be 
   processed in.   for example:
   .    set the itemDelimiter to "["
   .    put the keys of theArray into theKeys
   .    sort theKeys numeric by the last item of each
   .
   .    returns:  Array
   Source:
   Trever Devore,    https://gist.github.com/trevordevore/5584753
   ConvertXMLToArray */
   /* Include
   _ConvertXMLNodeToArray
   */
   local theArray,theResult,theRootNode,theTreeID
   local theXMLEncoding
   
   ## Create an XML tree from XML text
   put revCreateXMLTree(pXML, true, true, false) into theTreeID
   
   if theTreeID is an integer then
      ## Determine the encoding of the XML, default to UTF-8
      put matchText(pXML, "<\?xml (.*)encoding=" & quote & "(.*)" & quote & "\?>", versionMatch, theXMLEncoding) into theResult -- returns encoding="ISO-8859-1" standalone="no" (original from Trevor)
      --put matchText(pXML, "<?xml (.)encoding=" & quote & "([^" & quote & "])", versionMatch, theXMLEncoding) into theResult -- returns encoding="ISO-8859-1"
      if theXMLEncoding is empty then put "utf-8" into theXMLEncoding
      
      ## Now convert to array. 
      ## The 1st dimension has one key which is the name of the root node.
      put revXMLRootNode(theTreeID) into theRootNode
      if theRootNode is not empty and not(theRootNode begins with "xmlerr,") then
         put _ConvertXMLNodeToArray(theTreeID, theRootNode, theXMLEncoding, pStoreEncodedAs, pUseValueKey, pForceNumberIndexForNodes) into theArray[theRootNode]
      end if
      
      revDeleteXMLTree theTreeID
   end if
   
   return theArray
end ConvertXMLToArray


function ConvertArrayToXML pArray, pArrayEncoding, pStoreEncodedAs
   /* ConvertArrayToXML Misc
   Syntax:
   ConvertArrayToXML (pArray, [pArrayEncoding], [pStoreEncodedAs])
   Examples:
   put ConvertArrayToXML (pArray) into foo
   put  ConvertArrayToXML(pArray, "English", "utf8")
   Description:
   Converts a multi-dimensional array to an XML tree.
   .     pArray :  The array to convert.
   .     pArrayEncoding: The encoding used in the array. 
   .               Must be a value that can be passed to uniEncode. 
   .               Default is the current platform encoding.
   .      pStoreEncoded: the Encoding to use in the XML. Must be a value 
   .               that can be passed to uniDecode. Default is "utf8".
   .
   The array should consist of one key in the 1st dimension. This key 
   becomes the root node in the XML tree.   Attributes of a node should 
   be stored as an array in an @attributes key.  Sequence information for 
   multiple nodes with the same name should be included in the node name 
   using brackets (i.e. node[1], node[2], node[3]).
   .
   .      returns:  XML Tree id (integer) or error message.
   .                    put revXMLText(XML_Tree_ID, ,true)  -- to view
   
   Source:
   Trever Devore,    https://gist.github.com/trevordevore/5584753
   ConvertArrayToXML */
   /* Include
   _SortArrayKeysWithXMLOrdering
   _ConvertArrayDimensionToXML
   */
   
   local theError,theRootNode,theXML,theXMLTree
   
   ## if pArrayEncoding is empty then current platform encoding is assumed
   if pStoreEncodedAs is empty then put "UTF-8" into pStoreEncodedAs
   
   ## Create XML for root node. Note that we take extra steps in order to support
   ## converting an array that only represents part of a tree rather than the entire tree.
   ## In this case there may be multiple nodes at the root level.
   put line 1 of the keys of pArray into theRootNode 
   set the itemDelimiter to "["
   put "<" & item 1 of theRootNode & "/>" into theXML
   
   ## Create XML needed to create tree
   put format("<?xml version=\"1.0\" encoding=\"%s\"?>%s", \
         pStoreEncodedAs, theXML) into theXML
   put revCreateXMLTree(theXML, true, true, false) into theXMLTree
   
   if theXMLTree is an integer then
      ## Loop over all nodes at root level
      put false into stripMetaKeys
      put _SortArrayKeysWithXMLOrdering(the keys of pArray, stripMetaKeys) into theNodes
      
      ## Create tree using helper function
      repeat for each line theKey in theNodes
         put theKey into theNode
         replace space with "-" in theNode
         _ConvertArrayDimensionToXML pArray[theKey], theXMLTree, slash & theNode, \
               pArrayEncoding, pStoreEncodedAs
         put the result into theError
         
         if theError is not empty then exit repeat
      end repeat
      
      if theError is not empty then
         ## something went wrong, clean bad tree
         revDeleteXMLTree theXMLTree
      end if
   else
      put theXMLTree into theError
   end if
   
   if theError is not empty then
      return theError
   else
      return theXMLTree
   end if
end ConvertArrayToXML
 
 

private command _ConvertArrayDimensionToXML pArray, pTreeID, pNode, pArrayEncoding, pStoreEncodedAs
   /**
* \brief Helper function for ConvertArrayToXML.
*
* Converts the multi-dimensional array pArray to nodes in pTreeID. Calls itself recursively.
*
* \return Error message.
*/
/* Include
_SortArrayKeysWithXMLOrdering
_EncodeString
*/
   local theError,theKey,theKeys,theNode
   
   ## A workaround for fact that Revolution does not return
   ## keys in the order we created them
   put false into stripMetaKeys
   put _SortArrayKeysWithXMLOrdering(the keys of pArray, stripMetaKeys) into theNodes
   
   ## Arrays might have sequencing info in name 
   ## (i.e. step[1], step[2], ... )
   set the itemDelimiter to "["
   
   repeat for each line theArrayKey in theNodes
      put theArrayKey into theFullNode
      replace space with "-" in theFullNode
      put item 1 of theFullNode into theNode
      
      ## Look for attributes. These will be added as attributes to pNode.
      if theNode is "@attributes" or theNode is "@attr" then
         repeat for each line theKey in the keys of pArray[theArrayKey]
            put theKey into theAttr
            replace space with "-" in theAttr
            
            revSetXMLAttribute pTreeID, pNode, theAttr, \
                  _EncodeString(pArray[theArrayKey][theKey], \
                  pArrayEncoding, pStoreEncodedAs)
            if the result begins with "xmlerr," then 
               put the result && "(setting attribute" && theKey && "for node" && pNode & ")" into theError
            end if
            
            if theError is not empty then exit repeat
         end repeat
         
      else if theNode is "@value" then
         ## This XML tree is using complex structure. Node is the value of the parent node
         revPutIntoXMLNode pTreeID, pNode, _EncodeString(pArray[theArrayKey], pArrayEncoding, pStoreEncodedAs)
         if the result begins with "xmlerr," then
            put the result && "(adding child node" && theNode && "to node" && pNode & ")" into theError
         end if
         
      else
         if the keys of pArray[theArrayKey] is not empty then
            ## Node has children. Add node to XML tree then call self recursivly to create children nodes. 
            revAddXMLNode pTreeID, pNode, theNode, empty
            if the result begins with "xmlerr," then
               put the result && "(adding node" && theNode & ")" into theError
            end if
            
            if theError is empty then
               _ConvertArrayDimensionToXML pArray[theArrayKey], pTreeID, pNode & slash & theFullNode, \
                     pArrayEncoding, pStoreEncodedAs
               put the result into theError
            end if
         else
            ## Node has no children but possibly a value. Create node and add value (which may be empty).
            revAddXMLNode pTreeID, pNode, theNode, \
                  _EncodeString(pArray[theArrayKey], pArrayEncoding, pStoreEncodedAs)
            if the result begins with "xmlerr," then
               put the result && "(adding child node" && theNode && "to node" && pNode & ")" into theError
            end if
         end if
      end if 
      
      if theError is not empty then exit repeat
   end repeat
   
   return theError
end _ConvertArrayDimensionToXML
 
Private function _ConvertXMLTreeToArray pXMLTree, pStoreEncodedAs, pUseValueKey, pForceNumberIndexForNodes
   /**
   * \brief Converts and revXML created XML Tree to an array.
   *
   * \param pXMLTree The xml tree id.
   * \param pStoreEncodedAs See docs for ConvertXMLToArray.
   * \param pUseValueKey See docs for ConvertXMLToArray.
   * \param pForceNumberIndexForNodes See docs for ConvertXMLToArray.
   *
   * See docs for ConvertXMLToArray.
   *
   * \return Array
   */
   /* Include
   ConvertXMLToArray
   */
   return ConvertXMLToArray(revXMLText(pXMLTree), pStoreEncodedAs, pUseValueKey, pForceNumberIndexForNodes)
end _ConvertXMLTreeToArray
 

private function _ConvertXMLNodeToArray pTreeID, pNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, pForceNumberIndexForNodes
   /**
   * \brief Helper function for ConvertXMLToArray.
   *
   * Converts an XML node to a multi-dimensional array. Calls itself recursively.
   *
   * \return Array
   */
   /* Include
   _EncodeString
   */
   local theArrayA,theAttributes,theChildNode,theKey
   
   ## Look for attributes of the node. Store as array in "@attributes" key
   put revXMLAttributes(pTreeID, pNode, tab, cr) into theAttributes
   if theAttributes is not empty then
      put _EncodeString(theAttributes, pXMLTreeEncoding, pStoreEncodedAs) into theAttributes
      split theAttributes by cr and tab -- create array
      put theAttributes into theArrayA["@attributes"]
   end if
   
   ## Look for children nodes. 
   set the itemDelimiter to slash
   put revXMLFirstChild(pTreeID, pNode) into theChildNode
   if theChildNode is empty or theChildNode begins with "xmlerr," then
      put _EncodeString(revXMLNodeContents(pTreeID, pNode), pXMLTreeEncoding, pStoreEncodedAs) into theValue
      if word 1 to -1 of theValue is empty and the keys of theArrayA is not empty then
         ## Empty node that has attributes
         return theArrayA
      else if pUseValueKey then
         ## Force value into @value
         put theValue into theArrayA["@value"]
         return theArrayA
      else
         ## Single Node with value: Return value. Attributes are ignored.
         return theValue
      end if
   else
      ## Child nodes were found. Recursively call self and store result in array.
      set the wholeMatches to true
      replace comma with cr in pForceNumberIndexForNodes
      repeat while theChildNode is not empty and not (theChildNode begins with "xmlerr,")
         put the last item of theChildNode into theKey
         if theKey is among the lines of pForceNumberIndexForNodes then
            ## Oops, key that needs index doesn't have one. Only 1 entry in XML.
            put "[1]" after theKey
         end if      
         put _ConvertXMLNodeToArray(pTreeID, theChildNode, pXMLTreeEncoding, pStoreEncodedAs, pUseValueKey, \
               pForceNumberIndexForNodes) into theArrayA[theKey]
         put revXMLNextSibling(pTreeID, theChildNode) into theChildNode
      end repeat
      
      return theArrayA
   end if
end _ConvertXMLNodeToArray
 
private function _EncodeString pString, pInEncoding, pOutEncoding
   /**
   * \brief Helper function for converting the encoding of strings when converting to and from XML.
   *
   * \return String
   */
   ## convert utf-8 to utf8 for uniencode/decode
   replace "-" with empty in pInEncoding
   replace "-" with empty in pOutEncoding
   
   if pInEncoding is not empty then
      -- if pOutEncoding is empty then pString will be converted to the current platform encoding
      return uniDecode(uniEncode(pString, pInEncoding), pOutEncoding)
   else
      if pOutEncoding is not empty then
         -- if pInEncoding is empty then pString is assumed to be in the current platform encoding
         return uniDecode(uniEncode(pString, pInEncoding), pOutEncoding)
      else
         return pString
      end if
   end if
end _EncodeString

private function _EscapePredefinedXMLEntities pStr
   /**
   * \brief Escapes the predefined XML entities in a string.
   *
   * \param pStr The string to escape the characters in.
   *
   * \return String
   */
   replace "&" with "&amp;" in pStr
   replace "<" with "&lt;" in pStr
   replace ">" with "&gt;" in pStr
   replace "'" with "&apos;" in pStr
   replace quote with "&quot;" in pStr
   return pStr
end _EscapePredefinedXMLEntities



Private function _UnescapePredefinedXMLEntities pStr
   /**
* \brief Unescapes predefined xml entities in a string.
*
* \param pStr The strin to unescape the characters in.
*
* \return String
*/
    replace "&amp;" with "&" in pStr
    replace "&lt;" with "<" in pStr
    replace "&gt;" with ">" in pStr
    replace "&apos;" with "'" in pStr
    replace "&quot;" with quote in pStr
    return pStr
end _UnescapePredefinedXMLEntities



Private function _SortArrayKeysWithXMLOrdering pKeys, pStripMetaKeys
   /**
   * \brief Helper function for sorting keys of an array based on order in the XML document the array was created from.
   *
   * \param pKeys List of keys or array whose keys you want to sort.
   * \param pStripMetaKeys By default any meta keys (keys starting with "@") will be stripped. Pass in false to bypass this behavior.
   *
   * LiveCode array keys are never guaranteed to be in order you created them in 
   * so we must come up with some other way of maintaining proper sequence. 
   * For arrays representing XML, the XML syntax is used (i.e. node[1], node[2], etc.). 
   * This handler will sort keys that use this syntax for representing sequence.
   *
   * \return String
   */
   local theKeys
   
   put pStripMetaKeys is not false into pStripMetaKeys
   
   if pKeys is an array then
      put the keys of pKeys into pKeys
   end if
   
   set the itemDelimiter to "["
   sort pKeys numeric by the last item of each -- 1], 2], 3], etc.
   
   if pStripMetaKeys then
      filter pKeys without "@*"
   end if
   
   return pKeys
end _SortArrayKeysWithXMLOrdering



command AddFolderToArchive pZipArchivePath, pRootFolderPath, pIncludeRootFolderInArchiveItemNames, pFilesToExclude, pExtensionsThatArentCompressed, pFolderPath
   /* AddFolderToArchive Zip
   Syntax:
   AddFolderToArchive pZipArchivePath, pRootFolderPath, [pIncludeRootFolderInArchiveItemNames], [pFilesToExclude], [pExtensionsThatArentCompressed], [pFolderPath]   # Command #
   Examples:
   revZipOpenArchive pZipArchivePath, "write"
   AddFolderToArchive pZipArchivePath, pRootFolderPath
   revZipCloseArchive pZipArchivePath
   Description:
   Creates a zip file from a directory. 
   
   The ZIP archive should already have been opened with revZipOpenArchive.  Any 
   make sure to use revZipCloseArchive to save the changes
   
   .     pZipArchivePath:   The path to save the zip archive to. This should already have 
   .             been opened with revZipOpenArchive.
   .     pRootFolderPath:   The path to the folder to save in the zip archive.
   .     pIncludeRootFolderInArchiveItemNames:  Pass in true to include the name of 
   .            pRootFolderPath in the zip archive.
   .     pFilesToExclude:   A list of Files that should not be included in the archive.  One 
   .            filename per line.
   .     pExtensionsThatArentCompressed:   list of File extensions that should be added 
   .            without any compression.   One extention per line, do not include the "."
   .     pFolderPath:   Used when calling itself recursively. Pass in empty.
   
   Returns: empty or an Error Message
   Source:
   Trevor Devore, https://gist.github.com/trevordevore/5246242  Revision 1
   AddFolderToArchive */
   /* Include
   filesInFolder
   foldersInFolder
   */
   
   local theArchiveItemName,theCharNo,theError,theFile
   local theFiles,theFolder,theFolders
   
   put pIncludeRootFolderInArchiveItemNames is true into pIncludeRootFolderInArchiveItemNames
   set the wholeMatches to true
   
   replace comma with cr in pExtensionsThatArentCompressed
   
   if pFolderPath is empty then
      put pRootFolderPath into pFolderPath  
      if pIncludeRootFolderInArchiveItemNames then
         set the itemdel to slash	# we want folder to be reflected in archive item name
         delete item -1 of pRootFolderPath
      end if
   end if
   
   put filesInFolder(pFolderPath, true, true) into theFiles
   filter theFiles without "*/.DS_Store"
   set the itemdel to "."
   
   repeat for each line theFile in theFiles
      if theFile is among the lines of pFilesToExclude then next repeat
      
      put theFile into theArchiveItemName
      put offset(pRootFolderPath, theArchiveItemName) into theCharNo
      if theCharNo is 0 then return "file is not in expected folder"
      
      delete char 1 to (the number of chars of pRootFolderPath + 1) of theArchiveItemName	# strip root folder up to slash (zip item names shouldn't start with a slash)
      
      if item -1 of theArchiveItemName is among the lines of pExtensionsThatArentCompressed then
         revZipAddUncompressedItemWithFile pZipArchivePath, theArchiveItemName, theFile
      else
         revZipAddItemWithFile pZipArchivePath, theArchiveItemName, theFile
      end if
      if the result is not empty then
         put the result into theError
         exit REPEAT
      end if
   end REPEAT
   
   if theError is empty then
      put foldersInFolder(pFolderPath, true, true) into theFolders
      repeat for each line theFolder in theFolders
         AddFolderToArchive pZipArchivePath, pRootFolderPath, pIncludeRootFolderInArchiveItemNames, pFilesToExclude, pExtensionsThatArentCompressed, theFolder
         put the result into theError
         if theError is not empty then
            exit REPEAT
         end if
      end REPEAT
   end if
   
   return theError
end AddFolderToArchive


command DecompressArchiveToFolder pZipArchivePath, pOutputFolder, pItemsToExclude, pCallbackHandler
   /* DecompressArchiveToFolder Zip
   Syntax:
   DecompressArchiveToFolder pZipArchivePath, pOutputFolder, [pItemsToExclude], [pCallbackHandler]   # Command #
   Examples:
   revZipOpenArchive pZipArchivePath, "read"
   DecompressArchiveToFolder pZipArchivePath, pOutputFolder
   revZipCloseArchive pZipArchivePath
   Description:
   Decompresses a ZIP archive to a folder. 
   
   The ZIP archive should already have been opened with revZipOpenArchive.
   
   .   pZipArchivePath:  The path to the zip archive. This should already have been 
   .          opened with revZipOpenArchive.
   .   pOutputFolder:  The path to the folder to save the zip archive to.
   .   pItemsToExclude:  List of files that won't be extracted from the ZIP archive.
   .          A list of Files that should not be included in the archive.  One filename
   .          per line
   .   pCallbackHandler : The handler to call with progress updates.  
   .         total items, total archives
   
   Returns: empty or error message
   
   Source:
   DecompressArchiveToFolder */
   /* Include
   _fileCreateAllFoldersInPath
   _fileExtractDirectory
   _ZipErrorMsg
   _CardOf
   */
   
   local theError
   
   if the last char of pOutputFolder is slash then delete the last char of pOutputFolder
   
   set the wholeMatches to true
   put the fileType into theFileType
   set the fileType to empty
   
   put revZipEnumerateItems(pZipArchivePath) into theArchiveItems
   put the number of lines of theArchiveItems into theItemCount
   
   repeat for each line theArchiveItem in theArchiveItems
      add 1 to i
      
      if theArchiveItem is among the lines of pItemsToExclude then next repeat
      
      put pOutputFolder & slash & theArchiveItem into theFilePath
      if the last char of theFilePath is "/" then
         ## Directory
         _fileCreateAllFoldersInPath theFilePath, pOutputFolder
         put _ZipErrorMsg("creating directory" && theFilePath, the result) into theError
      else
         put _fileExtractDirectory(theFilePath) into theDirectoryPath
         
         if theDirectoryPath is not pOutputFolder then
            _fileCreateAllFoldersInPath theDirectoryPath, pOutputFolder
            put _ZipErrorMsg("creating parent directory" && theDirectoryPath, the result) into theError
         end if
         
         if theError is empty then
            if pCallbackHandler is not empty then
               put _CardOf(the long ID of the target) into theCard
               if theCard is not empty then
                  dispatch pCallbackHandler to theCard with i, theItemCount
               else
                  dispatch pCallbackHandler with i, theItemCount
               end if
               --                    put "dispatch" && quote & pCallbackHandler && "i, theItemCount" & quote && "to theCard" into theDo
               --               do theDo
            end if
            
            revZipExtractItemToFile pZipArchivePath, theArchiveItem, theFilePath
            put _ZipErrorMsg("archive:" && theArchiveItem & ", filepath:" && theFilePath, the result) into theError
         end if
      end if
      
      if theError is not empty then exit REPEAT
   end REPEAT
   
   set the fileType to theFileType
   
   return theError
end DecompressArchiveToFolder


private function _ZipErrorMsg pPrefix, pError
    if pError is not empty then
        answer quote & pError & quote
        if pPrefix begins with "ziperr," then
            delete char 1 to 7 of pPrefix
        end if
        return pPrefix & ": " & pError
    else
        return empty
    end if
end _ZipErrorMsg


private function _CardOf pControl
    local theCharNo
    
    put the long ID of pControl into pControl ## force the long id
    
    if word 1 of pControl is "stack" then
        put empty into pControl -- has no card
    else
        if word 1 of pControl is not "card" then
            put offset(" of card ", pControl) into theCharNo
            if theCharNo > 0 then
                delete char 1 to (theCharNo + 3) of pControl
            else
                put empty into pControl
            end if
        end if
    end if
    return pControl
end _CardOf


private command _fileCreateAllFoldersInPath pPath, pRootPath, pPerms
   /* Include
   _stripDoubleSlash
   fileIsFolder
   _fileSetPermissions
   */
   local theCheck,theError,thePathSegment
   
   ## Watch for double slashes /Folder/To//Something//
   ## You will not enter a never ending loop if you aren't careful.
   _stripDoubleSlash pPath
   _stripDoubleSlash pRootPath
   
   ## Get rid of trailing slashes
   ## We can safely ignore UNC paths starting with "//"
   ## Neither pPath or pRootPath with values of just "//" would be valid
   repeat until the last char of pPath is not slash
      delete the last char of pPath        
   end repeat
   if the number of chars of pRootPath > 1 and the last char of pRootPath is slash then
      repeat forever
         delete the last char of pRootPath
         if the last char of pRootPath is not slash or the number of chars of pRootPath is 1 then
            exit repeat
         end if
      end repeat
   end if
   
   ## Permissions
   if pPerms is not "shared" then put "user" into pPerms
   set the itemDelimiter to slash
   
   if pPath is empty or the number of items of pPath is 1 then
      put "cannot create folder (invalid path)" into theError
   end if
   
   ## VALIDATE pRootPath
   if theError is empty then
      if pRootPath is empty then
         put item 1 to 2 of pPath into pRootPath ## "/NODE"
      end if
      
      if theError is empty then
         if last char of pRootPath is not slash then put slash after pRootPath ## Makes it easier to deal with "/" path
         
         if not fileIsFolder(pRootPath) then
            put "root path does not exist" into theError
         end if
      end if
   end if
   
   ## VALIDATE ANCESTORY OF PATH
   if theError is empty then
      put char 1 to -2 of pRootPath into theCheck ## -2 gets rid of trailing slash
      if char 1 to (number of chars of theCheck) of pPath is not theCheck then 
         put "path is not a child of root path" into theError
      end if
   end if
   
   ## CREATE FOLDERS
   if theError is empty then
      if number of items of pPath > number of items of pRootPath then
         put pRootPath & item (number of items of pRootPath + 1) of pPath into thePathSegment
         
         if not fileIsFolder(thePathSegment) then
            create folder thePathSegment
            if the result is not empty then
               put "error creating folder (" & the result & ")" into theError
            else
               if pPerms is "shared" then
                  _fileSetPermissions thePathSegment, "execute", "execute", "execute"
                  if the result is not empty then
                     put format("error setting permissions for folder \"%s\" (%s)", thePathSegment, line 1 of the result) into theError 
                  end if
               end if
            end if
         end if
         
         if theError is empty then
            _fileCreateAllFoldersInPath pPath, thePathSegment, pPerms
            put the result into theError
         end if
      end if
   end if
   
   return theError
end _fileCreateAllFoldersInPath


private command _fileSetPermissions pFile, pOwner, pGroup, pAll
   /* Include
   _escapeForShell
   _executableBitFromType
   */
    local theError,theResult
    
    put _escapeForShell(pFile) into pFile
    
    switch the platform
        case "Win32"
            /*
            Displays or changes file attributes.
            ATTRIB [+R | -R] [+A | -A] [+S | -S] [+H | -H] [[drive:][path]filename]  [/S] [/D]
             
            + Sets an attribute.
            - Clears an attribute.
            R Read-only file attribute.
            A Archive file attribute.
            S system file attribute.
            H Hidden file attribute.
            /S Processes files in all directories in the specified path.
            /D Processes folders as well
            */
             
            switch pOwner
                case "read"
                    put "+r" into pOwner
                    break
                case "write"
                    put "-r" into pOwner
                    break
            end switch
            put shell (format ("attrib %s %s", pOwner, pFile) ) into theResult
            break
            
        case "MacOS"
            put _executableBitFromType(pOwner) into pOwner
            put _executableBitFromType(pGroup) into pGroup
            put _executableBitFromType(pAll) into pAll             
            put shell(format("chmod %u%u%u %s ", pOwner, pGroup, pAll, pFile)) into theResult
            break
    end SWITCH
    
    if the result is not empty then
        put line 1 of theResult into theError
    end if
    
    return theError
end _fileSetPermissions


private function _executableBitFromType pType
    switch pType
        case "execute"
            put 7 into pType
            break
        case "write"
            put 6 into pType
            break
        case "read"
            put 5 into pType
            break
        default
            put 0 into pType
    end switch
    return pType
end _executableBitFromType


private function _escapeForShell pStr
    local theChar,theSpecialChars
    
    if the platform is "win32" then
        replace "/" with "\" in pStr
        put quote & pStr & quote into pStr
    else
        put "\" & space & quote & "'`<>!;()[]?#$^&*=|" into theSpecialChars
        repeat for each char theChar in theSpecialChars
            replace theChar with ("\" & theChar) in pStr
        end REPEAT
    end if
    
    return pStr
end _escapeForShell


## Used for removing multiple slashes from folder paths
private command _stripDoubleSlash @pVariable
    local theCharNo,thePrefix
    
    ## Don't wipe out UNC prefixes
    if char 1 to 2 of pVariable is "//" then
        put "//" into thePrefix
        delete char 1 to 2 of pVariable
    end if
    
    repeat forever
        put offset("//", pVariable) into theCharNo
        if theCharNo > 0 then
            replace "//" with slash in pVariable
        else
            exit repeat
        end if
    end repeat
    
    if thePrefix is not empty then
        put thePrefix before pVariable
    end if
    
    return empty
end _stripDoubleSlash


function fileIsFolder pPath
         /* fileIsFolder File
   Syntax:
   fileIsFolder (pPath)
   Examples:
   fileIsFolder (pPath)
   Description:
   Tests to see if a path is a file or a folder
   
   Return true if pPath is a folder
   
   Source:
   Trevor Devore, https://gist.github.com/trevordevore/5246242  Revision 1
fileIsFolder */

   put the defaultFolder into theFolder
   set the defaultfolder to pPath
   put the result is empty into isAFolder
   set the defaultFolder to theFolder
   return isAFolder
end fileIsFolder


private function _fileExtractDirectory pFilePath
    set the itemDelimiter to slash
    return item 1 to -2 of pFilePath
end _fileExtractDirectory

function filesInFolder pFolder, pFullPath, pIncludeHidden
   /* filesInFolder File
   Syntax:
   filesInFolder (pFolder, [pFullPath], [pIncludeHidden])
   Examples:
    filesInFolder (pFolder, true, true)
    Description:
    Returns a list of files
    .    if pFullPath = true, then a full paths are returned
    .    if pIncludeHidden = true, the hidden files are returned
    
   Source:
   Trevor Devore, https://gist.github.com/trevordevore/5246242  Revision 1
   filesInFolder */
   /* Include
   fileIsFolder
   */
   local theDefault,theFile,theFiles,theFullFiles
   
   if not fileIsFolder(pFolder) then return empty
   if last char of pFolder is not slash then put slash after pFolder
   
   put the defaultFolder into theDefault
   set the defaultFolder to pFolder
   put the files into theFiles
   set the defaultFolder to theDefault
   if pIncludeHidden is not true then
      filter theFiles without ".*"
   else
      filter theFiles without "..*"
   end if
   
   if pFullPath then
      repeat for each line theFile in theFiles
         put pFolder & theFile & cr after theFullFiles
      end REPEAT
      delete last char of theFullFiles
      return theFullFiles
   else
      return theFiles
   end if
end filesInFolder


function foldersInFolder pFolder, pFullPath, pIncludeHidden
   /* foldersInFolder File
   Syntax:
   foldersInFolder (pFolder, [pFullPath], [pIncludeHidden])
   Examples:
   foldersInFolder (pFolder, true, true)
   Description:
   Returns a list of folders
   .    if pFullPath = true, then a full paths are returned
   .    if pIncludeHidden = true, the hidden folders are returned
   
   Source:
   Trevor Devore, https://gist.github.com/trevordevore/5246242  Revision 1
   foldersInFolder */
   /* Include
   fileIsFolder
   */
   local theDefault,theFolders,theFullFolders,theFolder
   
   if not fileIsFolder(pFolder) then return empty
   if last char of pFolder is not slash then put slash after pFolder
   
   put the defaultFolder into theDefault
   set the defaultFolder to pFolder
   put the folders into theFolders
   set the defaultFolder to theDefault
   
   if pIncludeHidden is not true then
      filter theFolders without ".*"
   else
      filter theFolders without "..*"
   end if
   
   if pFullPath then
      repeat for each line theFolder in theFolders
         put pFolder & theFolder &cr after theFullFolders
      end REPEAT
      delete last char of theFullFolders
      return theFullFolders
   else
      return theFolders
   end if
end foldersInFolder

function StacksInMemory
   /* StacksInMemory Misc
   Syntax:
   StacksInMemory()
   Examples:
     StacksInMemory()
     Description:
     Returns a list of the stacks currently in memory
   Source:
   StacksInMemory */

   local theStack,theStacksInMemory,theSubstack 
   
   repeat for each line theStack in the mainstacks 
      put theStack & cr after theStacksInMemory 
      
      repeat for each line theSubstack in the substacks of stack theStack 
         put theSubstack & cr after theStacksInMemory 
      end repeat 
   end repeat 
   delete the last char of theStacksInMemory 
   return theStacksinMemory 
end StacksInMemory

on InstallPasswordFont obj
   /* InstallPasswordFont fields
   Syntax:
   InstallPasswordFont   [long id of fld] # Command #
   Examples:
   InstallPasswordFont long id of fld "foo"
   Description:
   Loads the font "Password Entry".  This is a font that can be assigned
   to a Password field.  This font draws all characters as bullets. This 
   allows access the text property of the field in order to get 
   the actual password but the user only sees bullets.
   
   if you pass in the long Id of your password field the textfont will
   be set to the fontname:  "PasswordEntry"
   
   set the textfont of fld "your_field" to "PasswordEntry"
   Source:
   Michael Doub
   InstallPasswordFont */
   /* Include
   */
   put specialfolderpath("temporary")  into theFontFile
   put "/PasswordEntry.ttf" after theFontFile
   put the custompropertyset of me into oldcps
   set the custompropertyset of me to "Library"
   put the PasswordTextFont of me into url ("binfile:" & theFontFile) 
   set the custompropertyset of me to oldcps
   
   revFontLoad theFontFile
   put the result into theError
   if theError is not empty then
      answer "Error loading password font:" && theError & "."
   else
      if obj is not empty then set the textfont of obj to "PasswordEntry"
   end if
   
   delete file theFontFile
end InstallPasswordFont

-- begin Pi_to_Gert_Variables
local _pi_thePort, _pi_readrate, _pi_callbackname, _pi_owner, _pi_okToRead
-- end Pi_to_Gert_Variables

on Pi_to_Gert_Open pPortName, pReadrate, pBaud, pParity, pDatabits, pStopbits
   /* Pi_to_Gert_Open RaspberryPi
   Syntax:
   Pi_to_Gert_Open pPortName, [pReadrate], [pBaud], [pParity], [pDatabits], [pStopbits]    # Command #
   Examples:
   Pi_to_Gert_Open
   Description:
   Set the serial port configuration paramenters and opens the serial port to the GertDuino.
   
   Defaults:
   .    pPortName: "/dev/ttyAMA0"
   .    readrate: 10
   .    pBaud: 9600
   .    pParity: N
   .    pDatabits: 8
   .    pStopbits: 1
   
   Source:
   Michael Doub
   Pi_to_Gert_Open */
   /* Include
   Pi_to_Gert_Variables
   */
   
   if pPortName is empty then
      put "/dev/ttyAMA0" into _pi_theport
   else
      put pPortName into _pi_thePort
   end if
   if pReadrate is empty then put 10 into _pi_readrate
   if pBaud is empty then put 9600 into pBaud
   if pParity is empty then put "N" into pParity
   if pDatabits is empty then put 8 into pDatabits
   if pStopbits is empty then put 1 into pStopbits
   Put "BAUD=" & pBaud &&\
   "PARITY="& pParity &&\
   "DATA=" & pDatabits &&\
   "STOP=" & pDatabits into serial
   if the platform = "Linux" then
      set the serialControlString to serial
      open file _pi_thePort for binary update
   end if
end Pi_to_Gert_Open

on Pi_to_Gert_Start_Reading  pCallbackname, pObj
   /* Pi_to_Gert_Start_Reading  RaspberryPi
   Syntax:
   Pi_to_Gert_Start_Reading  pCallbackname, pObj    # Command #
   Examples:
   Pi_to_Gert_Start_Reading  "WeGotData", me  
   Description:
   This routine starts the reading process between the Gertduino and
   the raspBerryPi.  Since you must read the serial port until empty, this 
   means that you must constantly have a read active on the port.    
      
      When data  is actually recieved it is passed 
      to pCallbackname of pObj thru the message path with a single parameter 
      of the data base64encoded.
      
      Source:
      Michael Doub
      Pi_to_Gert_Start_Reading */
      /* Include
      Pi_to_Gert_Variables
      readPort_Gert
      */
      put true into _pi_okToRead
      put pCallbackname into _pi_callbackname
      put pObj into _pi_owner
      readPort_Gert
end Pi_to_Gert_Start_Reading

on Pi_to_Gert_Stop_Reading
   /* Pi_to_Gert_Stop_Reading  RaspberryPi
   Syntax:
   Pi_to_Gert_Stop_Readingj    # Command #
   Examples:
   Pi_to_Gert_Stop_Reading
   Description:
   This routine stops the continious read process that is expecting data
   from the Gertdino serial port.
   Source:
   Michael Doub
   Pi_to_Gert_Stop_Reading */
   /* Include
   Pi_to_Gert_Variables
   */
   put false into _pi_okToRead
end Pi_to_Gert_Stop_Reading

on Pi_to_Gert_Close
   /* Pi_to_Gert_Close  RaspberryPi
   Syntax:
   Pi_to_Gert_Close     # Command #
   Examples:
   Pi_to_Gert_Close
   Description:
   This reoutine actually closes the serial port to the GertDuino.
   Source:
   Michael Doub
   Pi_to_Gert_Close */
   /* Include
   Pi_to_Gert_Variables
   */
   put false into _pi_okToRead
   wait for _pi_readrate with messages
   close file _pi_thePort 
end Pi_to_Gert_Close

on readPort_Gert
   if not _pi_okToRead then exit readPort_Gert
   if the platform = "Linux" then
      read from file _pi_thePort until empty
   else
      if random(1000) <= 2 then put the long time into it
   end if
   if it is not empty then
      put base64encode(it) into tBuf   -- in case we want to pass binar someday
      put trunc(_pi_readrate * 1.5) into tim
      send _pi_callbackname && tBuf to _pi_owner in tim millisec
   end if
   send "readPort_Gert" to me in _pi_readrate millisec   -- post another read
end readPort_Gert

on Pi_to_Gert_Write theData pDecode
   /* Pi_to_Gert_Write  RaspberryPi
   Syntax:
   Pi_to_Gert_Write theData, [pDecode]    # Command #
   Examples:
   Pi_to_Gert_Write thedata
   Pi_to_Gert_Write thedata, true
   Description:
   Writes theData to the Gertduino serial port.   If pDecode is true then the data
   will be base64decoded
   Source:
   Michael Doub
   Pi_to_Gert_Write */
   /* Include
   Pi_to_Gert_Variables
   */
   if pDecode then
      write base64decode(theData) to file  _pi_thePort
   else
      write theData to file _pi_thePort
   end if
end Pi_to_Gert_Write

on CenterTextVertically myFld
   /* CenterTextVertically fields
   Syntax:
   CenterTextVertically fieldID   # Command #
   Examples:
    CenterTextVertically long id of fld "foo"
    Description:
    Centers the text of a field to the visual vertical center of the field.
    Source:
    Geoff Canyon, gcanyon@gmail.com
CenterTextVertically */

   put the effective textHeight of myFld into tTextHeight
   put item 2 of the loc of myFld into tfieldY
   put the formattedRect of line 1 to - 1 of myFld into tFormatRect
   put item 4 of tFormatRect - item 2 of tFormatRect into tFormatHeight
   put tFormatHeight div 2 into tFormatHalfHeight
   put item 2 of tFormatRect into tCurrFormatTop
   put tfieldY - tCurrFormatTop into tCenterField_To_TopTextDiff
   set the topMargin of myFld to the topMargin of myFld + tCenterField_To_TopTextDiff - tFormatHalfHeight
end CenterTextVertically


on initializeCprops propList,tObjRef,tDelimSecondary,tDelimPrimary,
   /* initializeCprops Properties
   Syntax:
   initializeCprops propList, tObjRef, tDelimSecondary, tDelimPrimary   # Command #
   Examples:
   put "tGender^M,tTown^Cambridge,nextAppt^1 month" into propList
   initializeCprops propList,the long id of this card,comma,"^"
   Description:
   Initialize a list of custom properties in one swoop
 
   .   proplist is a delimited list of <cPropName><tDelimSecondary><value>
   .   tObjRef is the fully qualified object containing the properties
   .   tDelimPrimary is the delimited between each propery/value pair.  The
   .          default on empty is comma.
   .   tDelimSecondary is the delimiter between the property name and the 
   .          value.  The default on empty is space.
   Source:
   from an example by Geoff Canyon, adapted by Peter M. Brigham and Mike Doub
   initializeCprops */
   if tDelimPrimary = empty then put comma into tDelimPrimary
   if tDelimSecondary = empty then put space into tDelimSecondary
   split propList using tDelimPrimary and tDelimSecondary
   repeat for each key K in propList
      set the K of tObjRef to propList[K]
   end repeat
end initializeCprops


function IPCalc theIPAddress, theSubnetMask
   /* IPCalc Internet
   Syntax:
   IPCalc theIPAddress, [theSubnetMask]
   Examples:
   IPCalc ("192.168.12.0/23")
   IPCalc ("192.168.12.0","255,255,254,0")
   Description:
   Derive Internet values from either CIDR notation in the IPAddress
   or a standard IP and subnet mask
      
   Input: 
         .    theIPAddress -  the IP address in CIDR notation (xxx.xxx.xxx.xxx/n)
   .                             http://doc.m0n0.ch/quickstartpc/intro-CIDR.html
          or
         .    theIPAddress - a standard IP address and    (xxx.xxx.xxx.xxx)
        .     theSubNetMask - a standard subNetMask    (xxx.xxx.xxx.xxx)
   
   Returns an array of the following values:
         .   bcastaddr
         .   cidraddr
         .   cidrdepth
         .   firstaddr
         .   ipaddress
         .   lastaddr
         .   subnetaddr
         .   subnetmask
         .   usablecount
   
   Returns a string beginning with ERROR: if the parameters are out of range
   Check that the returned value is an array to see if there was an error
      
   Source:
          Bob Sneidar,  slylabs13@icloud.com
   IPCalc */
   /* Include
   charx
   */
      
   set the itemdelimiter to "."
      
   
   -- check parameters
   -- the IP address must be 4 octets of numbers
   if the number of items of theIPAddress <>4 \
         or the last char of theIPAddress is "." \
         or ".." is in theIPAddress then
      return "ERROR: The IP Address must be in the form:" & cr & \
            "'nnn.nnn.nnn.nnn' or 'nnn.nnn.nnn.nnn/nn'. (ipaddress = '" & theIPAddress & "')"
   end if 
      
   
      -- initial setup
      set the numberFormat to "00000000"
      
   
      -- detemine format
      if theIPAddress contains "/" then
            put offset("/", theIPAddress) into theCIDRDelim
            put char theCIDRDelim +1 to -1 of theIPAddress into theCIDRDepth
            
      
            -- CIDR depth must be a number
            if theCIDRDepth is not a number then
                  return "ERROR: The CIDR Depth must be a number between 1 and 30. " & \
                              "(CIDRDepth = " & theCIDRDepth & ")"
            end if
            
      
            put charx("1", theCIDRDepth) & charx("0", 32-theCIDRDepth) into theBinSubnetMask
            put baseconvert(char 1 to 8 of theBinSubnetMask, 2, 10) into item 1 of theSubnetMask
            put baseconvert(char 9 to 16 of theBinSubnetMask, 2, 10) into item 2 of theSubnetMask
            put baseconvert(char 17 to 24 of theBinSubnetMask, 2, 10) into item 3 of theSubnetMask
            put baseconvert(char 25 to 32 of theBinSubnetMask, 2, 10) into item 4 of theSubnetMask
            put char 1 to theCIDRDelim -1 of theIPAddress into theIPAddress
      else
            -- subnet mask octets must be 4 numbers between 0 and 255
            -- and all octets after the first octet less than 255 must be 0
            
      if the number of items of theSubnetMask <>4 \
            or the last char of theSubnetMask is "." \
            or ".." is in theSubnetMask then
         return "ERROR: The Subnet Mask must be in the form:" & cr & \
               "'nnn.nnn.nnn.nnn' (subnetmask = '" & theSubnetMask & "')"
      end if
                       
      put false into mustBeZero
      repeat for each item theOctet in theSubnetMask
                  
         if theOctet <0 or theOctet >255 then
            return "Each octet in the subnet mask must be a number between 0 and 255. " & \
                  "(subnetmask = " & theSubnetMask & ")"
         end  if   
         
         if mustBeZero and theOctet >0 then
            return "ERROR: All octets after an octet less than 255 must be 0. " & \
                  "(subnetmask = " & theSubnetMask & ")"
         end if
                  
         if theOctet <255 then
            put true into mustBeZero
         end if
      end repeat
            
      
            -- convert the subnet mask to binary
            put 0 into whichOctet
            repeat for each item theOctet in theSubnetMask
                  add 1 to whichOctet
                  
                  -- subnet mask must contain only 4 octets
                  if whichOctet >4 then
                        return "ERROR: The Subnet Mask must contain 4 numbers between 0 and 255 " & \
                                    "separated by periods. (subnetmask = " & theSubnetMask & ")"
                  end if
         
                  put value(baseConvert(theOctet, 10, 2)) after theBinSubnetMask
            end repeat
            put offset("0", theBinSubnetMask) -1 into theCIDRDepth
      end if
      
   -- CIDR depth must be between 0 and 32
   if theCIDRDepth <0 or theCIDRDepth >32 then
      return "ERROR: The CIDR Depth must be between 0 and 32. " & \
            "(CIDRDepth = '" & theCIDRDepth & "')"
   end if
      
   
      -- All octets of the IP address must be between 0 and 255
      repeat for each item theOctet in theIPAddress
            if theOctet <0 or theOctet >255 then
                  return "ERROR: Each IP Address octet must be a number between 0 and 255. " & \
                              "(ipaddress = " & theIPAddress & ")"
            end if
      end repeat
      
   
      -- convert the ip address to binary
      put 0 into whichOctet
      repeat for each item theOctet in theIPAddress
            add 1 to whichOctet
            put baseConvert(theOctet, 10, 2) into theBinValue
            add 0 to theBinValue
            put theBinValue after theBinIPAddress
      end repeat
      
   
      -- calculate the binary subnet address
      put char 1 to theCIDRDepth of theBinIPAddress into theBinNetworkAddr
      put char theCIDRDepth +1 to -1 of theBinIPAddress into theBinNodeAddr
      put theBinNodeAddr into theBinSubnetNodeAddr
      set the numberFormat to "0"
      replace "1" with "0" in theBinSubnetNodeAddr
      put theBinNetworkAddr & theBinSubnetNodeAddr into theBinSubnetAddr
      
   
      -- convert the binary subnet address to decimal
      put baseconvert(char 1 to 8 of theBinSubnetAddr, 2, 10)  into item 1 of theSubnetAddr
      put baseconvert(char 9 to 16 of theBinSubnetAddr, 2, 10)  into item 2 of theSubnetAddr
      put baseconvert(char 17 to 24 of theBinSubnetAddr, 2, 10)  into item 3 of theSubnetAddr
      put baseconvert(char 25 to 32 of theBinSubnetAddr, 2, 10)  into item 4 of theSubnetAddr
      
   
      -- calculate the first usable IP address
      put theSubnetAddr into theFirstAddr
      add 1 to item 4 of theFirstAddr
      
   
      -- calculate the binary broadcast address
      put theBinNodeAddr into theBinBcastNodeAddr
      replace "0" with "1" in theBinBcastNodeAddr
      put theBinNetworkAddr & theBinBcastNodeAddr into theBinBcastAddr
      
   
      -- convert the binary broadcast address to decimal
      put baseconvert(char 1 to 8 of theBinBcastAddr, 2, 10) into item 1 of theBcastAddr
      put baseconvert(char 9 to 16 of theBinBcastAddr, 2, 10) into item 2 of theBcastAddr
      put baseconvert(char 17 to 24 of theBinBcastAddr, 2, 10) into item 3 of theBcastAddr
      put baseconvert(char 25 to 32 of theBinBcastAddr, 2, 10) into item 4 of theBcastAddr
   
      -- calculate the last usable IP address
      put theBcastAddr into theLastAddr
      subtract 1 from item 4 of theLastAddr
      
      -- calculate the number of usable addresses
      -- put item 4 of theLastAddr - item 4 of theFirstAddr +1 into theAddrCount
      put baseconvert(theBinBcastNodeAddr, 2, 10) -1 into theAddrCount
   
      -- calculate the CIDR notation
      put theIPAddress & "/" & theCIDRDepth into theCIDRAddr
   
      -- create array
      put theIPAddress into ipdata ["ipaddress"]
      put theSubnetMask into ipdata ["subnetmask"]
      put theSubnetAddr into ipdata ["subnetaddr"]
      put theFirstAddr into ipdata ["firstaddr"]
      put theBcastAddr into ipdata["bcastaddr"]
      put theLastAddr into ipdata ["lastaddr"]
      put theCIDRDepth into ipdata ["cidrdepth"]
      put theAddrCount into ipdata ["usablecount"]
      put theCIDRAddr into ipdata ["cidraddr"]
      return ipdata
end IPCalc

Private function charx theChar, theCount
   repeat for theCount
      put theChar after theValue
   end repeat
   return theValue
end charx


function getThumbs pfilepath 
   /* getThumbs Image
   Syntax:
   getThumbs (pfilepath )
   Examples:
   put  getThumbs (pfilepath ) into imageArray
   if imageArray is not an array then 
   .  answer "No thumbnails"
   else
   .  create image
   .  set the text of it to imageArray[1]
   end if
   
   Description:
   This function returns an array of thumbnail images that were contained within a 
   jpeg file.   This function only loads a portion of the image into memory to extract
   the thumbnails from the metadata.   It does not load the entire image.
   
   Input:
   .    pfilepath is a fully qualified path to the jpeg image containing the thumbnails
   
   Returns:
   .    empty if there were no thumbnails found or
   .    an array of the actual image data extracted from the jpeg image file indexed by
   .    sequential integers starting at 1
   
   Multiple thumbnails may be found so the number of keys of the imageArray tells 
   you the number of thumnails found
   
   Source:
   Michael Doub, derived from a posting by Alejandro Tejada 
   getThumbs */
   
   open file pfilepath for binary read
   read from file pfilepath for 100000 -- first 100k of jpeg binary data
   put it into temp1
   close file pfilepath
   
   put numtochar(255) & numtochar(216) into tStart
   -- in Hexadecimal: FFD8 = SOI(Start of jpeg image)
   put numtochar(255) & numtochar(217) into tEnd
   -- in Hexadecimal: FFD9 = EOI(End of jpeg image)
   set the casesensitive to true
   
   delete char 1 to 2 of temp1
   -- delete JPEG SOI (Start of jpeg image)
   if char -2 to -1 of temp1 = tEnd then delete char -2 to -1 of temp1
   -- delete JPEG EOI(End of jpeg image)
   
   put empty into rDataArray
   put 1 into counter
   
   repeat until offset(tEnd,temp1) = 0
      put offset(tStart,temp1) into tThumbstart
      put offset(tEnd,temp1) into tThumbEnd
      put char tThumbstart to (tThumbEnd + 1) of temp1 into tJPGThumb
      delete char 1 to (tThumbEnd + 1) of temp1
      if tJPGThumb is not empty then
         put tJPGThumb into rDataArray[counter]
         add 1 to counter
      end if
   end repeat
   
   return rDataArray
end getThumbs

function Zap tIn
   /* Zap Text
   Syntax:
   Zap (inputString)
   Examples:
   put Zap(inText) into outText
   Description:
   Returns only POSIX printable characters, space, tab and return
   Source:
   Thierry Douez - http://sunny-tdz.com
   Zap */
   return replacetext(tIn,"[^[:print:]\n\t]", empty)  
   -- "[:print:] matches visable characters and space  [POSIX]
   -- "[ -~]" matches space thru "~"
end Zap

function GetRegexMatches ptext,pregex
   /* GetRegexMatches Text Items
   Syntax:
   GetRegexMatches (test, regex_pattern)
   Examples:
   GetRegexMatches (test, regex_pattern)
   Description:
   Finds all the matches of pregex in ptext and returns a list of the
   start,end char positions
   Source:
   Peter Haworth <pete@lcsql.com>
   GetRegexMatches */
   
   
   local tOffset,tStart,tEnd,tList,tLength
   
   --Make sure the whole regex string is a capture group
   if not (pregex begins with "(" and pregex ends with ")") then
      put "("before pregex
      put ")" after pregex
   end if
   
   --Make sure the regex is valid
   try
      get matchChunk(ptext,pregex,tStart,tEnd)
   catch e
      answer "Invalid regex expression:"
      return empty
   end try
   
   put 1 into tOffset
   put the length of ptext into tLength
   repeat
      if matchChunk(char tOffset to tLength of ptext,pregex,tStart,tEnd) then
         put tStart+tOffset-1, tEnd+tOffset-1 & return after tList
         add tEnd  to tOffset
      else
         exit repeat
      end if
   end repeat
   
   return tList
end GetRegexMatches


function deleteExtraTokens inputVar, tokenVar 
   /* deleteExtraTokens Text
   Syntax:
   deleteExtraTokens (inputVar, tokenVar)
   Examples:
   put deleteExtraTokens ("hello    world", space) ==> "hello world"
   Description:
   This fuction witll remove sequences of the specified token that are greater than one.
   If no token is presented, then space is used as the default
   Source:
   David L. Jones, (djones@rsmas.miami.edu)
   deleteExtraTokens */
   if tokenVar is empty then put space into tokenVar
   put offset(tokenVar & tokenVar , inputVar) into offsetVar -- initialize varaible
   if offsetVar <> 0 then
      repeat until offsetVar = 0
         replace tokenVar & tokenVar with tokenVar in inputVar
         put offset(tokenVar & tokenVar, inputVar) into offsetVar
      end repeat
   end if
   return inputVar
end deleteExtraTokens

function combinatorial n 
   /* combinatorial Math
   Syntax:
   combinatorial (n)
   Examples:
   put combinatorial (5)
   Description:
   Returns all possible subsets of a set, where n = #  of objects in the set
   Each line will contain a unique comma seperate list of set members
   Source:
   David L. Jones, (djones@rsmas.miami.edu)
   combinatorial */
   put the cursor into tCursor
   put 1 into tCursorCtr
   if n >= 15 then -- make sure you know what you're in for!
      answer n && "objects will result in" && (2^15 -1) && "subsets" with "Continue" or "Cancel"
      if it is "Cancel" then exit to top
   end if
   put 1 into subsetsVar -- initialize variable
   repeat until x = n -- this repeats (2^n - 2) times, which is one less than the numer of possible subsets
      Add 1 to tCursorCtr
      if tCursorCtr > 5000 then
         set the cursor to busy
         put 0 into tCursorCtr
      end if
      put the last line in subsetsVar into x -- each subset is used as input to compute the next subset
      put the number of items in x into noItems
      if item noItems of x = n then
         add 1 to item (noItems -1) of x -- increment 2nd to last item if last item = n
         delete the last item of x -- get rid of last item if it = n
         put return & x after subsetsVar -- add another subset to list of subsets
      else
         put ((item noItems of x) + 1) into item (noItems + 1) of x -- increment last item
         put return & x after subsetsVar -- add another subset to list of subsets
      end if
   end repeat
   set the cursor to tCursor
   return subsetsVar -- return the list of all possible subsets
end combinatorial

function nComb n, r  
   /* nComb Math
   Syntax:
   nComb(n,r)
   Examples:
   nComb(n,r)
   Description:
   Returns the # of combinations of n objects taken r at a time
   Source:
   David L. Jones, (djones@rsmas.miami.edu)
   nComb */
   /* Include
   factorial
   */
   if (r > 0) And (r <= n) then
      if r = n then
         return 1
      else
         return factorial(n)/(factorial(r) * factorial(n - r))
      end if
   else
      Answer "nComb error:" && r && "is not between 0 and" && n
      exit to top
   end if
end nComb

function factorial x 
   /* factorial Math
   Syntax:
   factorial (x)
   Examples:
   factorial (5)
   Description:
   Returns x!
   Source:
   David L. Jones, (djones@rsmas.miami.edu)
   factorial */
   
   if x <= 1
   then return 1
   else return x * factorial(x-1)
end factorial

function latLongDist t1, n1, t2, n2 , mk
   /* latLongDist Geo
   Syntax:
   latLongDist (t1, n1, t2, n2 , ["mi")
   Examples:
   latLongDist (38.898556, -77.037852, 38.897147, -77.043934)
   Description:
   Finds distances  between two points based on Latitude and Longitude
   using the haversine" formula
   
   if mk is empty or "mi" then miles will be returned else km is returned
   Source:
   Michael Doub's port of http://andrew.hedges.name/experiments/haversine/ javascript
   latLongDist */
   put 3961 into Rm -- mean radius of the earth (miles) at 39 degrees from the equator
   put 6373 into Rk  -- mean radius of the earth (km) at 39 degrees from the equator
   put t1 * pi/180 into lat1  -- convert degrees to radians
   put n1 * pi/180 into lon1
   put t2 * pi/180 into lat2
   put n2 * pi/180 into lon2
   put lat2 - lat1 into dlat
   put lon2 - lon1 into dlon
   put (sin(dlat/2))^2 + cos(lat1) * cos(lat2) * (sin(dlon/2))^2 into aa
   put 2 * atan2( sqrt(aa), sqrt(1-aa) ) into cc
   put cc * Rm into Dm
   put cc * Rk into Dk
   if mk is empty or lower(mk) = "mi" then
      return round (Dm,3)
   else
      return round(Dk,3)
   end if
end latLongDist

function latLongDist2 lat1, lon1, lat2, lon2, radius
   /* latLongDist2 Geo
   Syntax:
   latLongDist2 (t1, n1, t2, n2,[radius_of_earth])
   Examples:
   latLongDist2 (38.898556, -77.037852, 38.897147, -77.043934)
   latLongDist2 (38.898556, -77.037852, 38.897147, -77.043934, 6371000)
   Description:
   Finds distances  between two points based on Latitude and Longitude
   using Spherical Law of Cosines
   
   Optional radius parameter is the radius of the earth in meters.  (Allows caller to
   compensate if the default average radius of 6371000 meters is not appropriate)
   
   returned is distance_in_meters
   
   Source:
   Michael Doub  http://www.movable-type.co.uk/scripts/latlong.html
   latLongDist2 */
   
   if radius is empty then put 6371000 into radius
   return ACOS( SIN(lat1 * PI / 180) * SIN(lat2*PI / 180) + COS(lat1*PI / 180) * COS(lat2*PI / 180) * COS(lon2*PI/180-lon1*PI/180) ) * radius
end latLongDist2



function dd2dms dd, latlong , pDelim
   /* dd2dms Geo
   Syntax:
   dd2dms (dd, ["lat"] , [pDelim])
   Examples:
   put dd2dms (38.898556, "Lat") into tLat
   put dd2dms (-77.037852, "Long") into tLong
   Description:
   Converts a digital longitude or Latitude into degrees, minutes, seconds, direction format.
   
   pDelim allows you to select the delimiter, but space is the default.  The latlong
   parameter can be "lat" to indicate dd is a latitude.  latlong defaults to longitude
   Source:
   Michael Doub
   dd2dms */
   if pDelim is empty then put space into pDelim
   if Lower(latlong) = "lat" then
      if dd < 0 then
         put "S" into dir
      else
         put "N" into dir
      end if
   else
      if dd < 0 then
         put "W" into dir
      else
         put "E" into dir
      end if
   end if
   put abs(dd) into dd
   put offset (".", dd) into x
   put char 1 to x -1 of dd into deg
   delete char 1 to x -1 of dd
   multiply dd by 60
   put offset ( ".", dd) into x
   put char 1 to x -1 of dd into minu
   delete char 1 to x -1 of dd
   put round (dd * 60) into seco
   add 1000 to deg
   add 1000 to minu
   add 1000 to seco
   return char -3 to -1 of deg & pDelim & \
         char -2 to -1 of  minu & pdelim & \
         char -2 to -1 of seco & pdelim & dir
end dd2dms	
        	
function dms2dd dms pDelim
   /* dms2dd Geo
   Syntax:
   dms2dd (dms [pDelim])
   Examples:
    dms2dd ("38.53.55.N", ".")
   dms2dd ("77 2 16 W")
   Description:
   Converts a degrees, minutes, seconds, direction longitude or latitude to digital format
   
   pdelim is the delimiter between items. It defaults to space if omitted.
   Source:
   Michael Doub
dms2dd */
   if pDelim is empty then put space into pDelim
   set itemdel to pDelim
   if the number of items in dms <> 4  then return empty
      put lower(item 4 of dms) into dir
      switch dir
         case "s"
         case "w"
            put -1 into item 4 of dms
            break
         case "n"
         case "e"
            put 1 into item 4 of dms
            break
         default
            return empty
      end switch
   return  (item 1 of dms + item 2 of dms/60 + item 3 of dms/3600) * item 4 of dms 
end dms2dd	

function factorialFloor x,f
   /* factorialFloor Math
   Syntax:
   factorialFloor (x,f)
Examples:
Description:
Source:
Geoff Canyon <gcanyon@gmail.com>
factorialFloor */
   if x <= f then return 1
   return x * factorialFloor(x-1,f)
end factorialFloor

function nCombFloor n, r
   /* nCombFloor Math
   Syntax:
   nCombFloor (n, r)
   Examples:
Description:
Source:
Geoff Canyon <gcanyon@gmail.com>
nCombFloor */
/* Include
factorialFloor
*/
   if (r > 0) or (r <= n) then \
         return factorialFloor(n,max(r,n-r))/factorial(min(r,n-r))
   Answer "nComb error:" && r && "is not between 0 and" && n
   exit to top
end nCombFloor

function factorialFloor x,f
   /* factorialFloor Math
   Syntax:
   factorialFloor (x,f)
Examples:
Description:
Just takes an ordinary factorial and only calculates it down to just before the floor. 
6! = 6*5*4*3*2*1 = 720 where factorialFloor(6,3) = 6*5*4 = 120
Source:
Geoff Canyon <gcanyon@gmail.com>
factorialFloor */
   if x <= f then return 1
   return x * factorialFloor(x-1,f)
end factorialFloor

function nCombFloor n, r
   /* nCombFloor Math
   Syntax:
   nCombFloor (n, r)
Examples:
Description:
Returns the # of combinations of n objects taken r at a time but uses factorialFloor to save 
a step and reduce the calculation of the largest value. 
nCr = n! / (r! * (n-r)!)

The largest calculation there will be n!. So if that exceeds LC's math capabilities (about 16 digits) 
your answer will be wrong.  But note that you can change that into:
nCr = (n! / r!) / (n-r)!  or  nCr = (n! /  (n-r)!) / r!

In either case, the numerator ends up being factorialFloor. For example, if you want 8C3 that 
equals  8! / (3! * (8-3)!) = 8! / (3! * 5!)

Taking the larger of the two elements in the denominator, that's the same as
(8! / 5!) / 3!

(8! / 5!) = (8*7*6*5*4*3*2*1) / (5*4*3*2*1) 

canceling out that's
8*7*6, which is factorialFloor(8,5)

then you just have to get  factorialFloor(8,5) / 3!

The nice bit is two-fold: first, there's less actual math involved, so it's faster; second, 
the big number in the numerator is diminished as much as it can be before dividing 
by the denominator. That makes calculating something like 80C5 possible.

Source:
Geoff Canyon <gcanyon@gmail.com>
nCombFloor */
/* Include
factorialFloor
*/
   if (r > 0) or (r <= n) then \
         return factorialFloor(n,max(r,n-r))/factorial(min(r,n-r))
   Answer "nComb error:" && r && "is not between 0 and" && n
   exit to top
end nCombFloor

function nCombFactors n, r
   /* nCombFactors Math
   Syntax:
   nCombFactors (n, r)
Examples:
Description:
Returns the # of combinations of n objects taken r at a time but it takes it a step further. 
You know that every number in the divisor can divide evenly into the numerator (there are
no fractional ways to choose things). So if you break everything down to its prime 
factorization, you can cancel out *everything* in the denominator before doing any 
multiplication. so starting with 8C3 again:

nCombFactors turns 8C3 into (8! / 5!) / 3!

then it turns (8! / 5!) into 8 * 7 * 6, and factors those, getting 2,2,2,2,3,7
then it does the same for 3!, getting 2,3
Then it cancels out by removing the 2,3 from the first list, getting 2,2,2,7
and then finally it multiplies those together, getting 56. The advantage here is that 
multiplication only happens at the very end, and never grows larger than the final answer. 
That means that any combinatorial problem that has an answer within LC's numeric range 
can be solved. 60C30 will break either of the other two: it will break the original nComb 
because LC can't handle 60! (it has about 80 digits, far beyond LC). And it will 
break nCombFloor because it still has to calculate 
factorialFloor(60,30) = 60 * 59 * 58 ... 32 * 31, which has about 50 digits. But 
nCombFactors can handle it because each of the calculations just involves lists of numbers. 

For example put factorialFactors(60,30) =
2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,5,5,
5,5,5,5,5,5,7,7,7,7,7,11,11,11,13,13,17,17,19,19,23,29,31,37,41,43,47,53,59

Only the final calculation has to be multiplied out:
2*2*2*2*7*11*17*19*31*37*41*43*47*53*59 = 118264581564861424 which is (barely) 
within LC's limits.
Source:
Geoff Canyon <gcanyon@gmail.com>
nCombFactors */
/* Include
removeItems
factorialFactors
primeFactors
*/
  
   if (r <= 0) or (r > n) then
      Answer "nComb error:" && r && "is not between 0 and" && n
      exit to top
   end if
   put factorialFactors(n,max(r,n-r)+1) into tNum
   put factorialFactors(min(r,n-r)) into tDen
   put removeItems(tNum,tDen) into c
   replace comma with "*" in c
   if c is empty then return 1 else return value(c)
end nCombFactors

private function removeItems N,D
   repeat until D is empty
      if item 1 of D > item 1 of N then
         put item 1 of N & comma after R
         delete item 1 of N
      else
         delete item 1 of N
         delete item 1 of D
      end if
   end repeat
   if N is empty then return char 1 to -2 of R else return R & N
end removeItems

private function factorialFactors x,f
   if f is empty then put 2 into f
   repeat with i = f to x
      put primeFactors(i),"" after R
   end repeat
   sort items of R numeric
   return char 2 to -1 of R
end factorialFactors

private function primeFactors x
   repeat with i = 2 to x div 2
      repeat until x mod i <> 0
         put i,"" after R
         put x div i into x
         if x = 1 then return char 1 to -2 of R
      end repeat
   end repeat
   return x
end primeFactors
         	
function subtractLists listA, listB, tDelim
   /* subtractLists Text Items
   Syntax:
   subtractLists (listA, listB, [tDelim])
   Examples:
   subtractLists (listA, listB)
   subtractLists (listA, listB, "/")
   Description:
   Returns a list of all items in listA that are not in listB
   both lists should be delimited with the same delimiter
   .   if tDelim = empty then looks first for the presence of cr in the lists,
   .   if found, defaults to cr as the delimiter
   .   if no cr found, looks for the presence of comma in the lists,
   .   if found, defaults to comma as the delimiter
   .   if neither found, returns empty (user should have specified another delim)
   
   outputs a list with the same delimiter used in the input lists
   Source:
   subtractLists */
   
   
   if listA = empty then return empty
   if listB = empty then return listA
   if tDelim = empty then
      if listA & listB contains cr then
         put cr into tDelim
      else if listA & listB contains comma then
         put comma into tDelim
      else
         return empty
         -- user should have specified another delimiter
      end if
   end if
   set the itemdel to tDelim
   repeat for each item tItem in listA
      if tItem is not among the items of listB then put tItem & tDelim after outList
   end repeat
   return item 1 to -1 of outList
end subtractLists

function mergeLists listA, listB, tDelim
   /* mergeLists Text Items
   Syntax:
   mergeLists (listA, listB, [tDelim])
   Examples:
   mergeLists (listA, listB)
   mergeLists (listA, listB, "/")
   Description:
   Merge two lists without duplicates or empty items
   both lists should be delimited with the same delimiter
   .   if tDelim = empty then looks first for the presence of cr in the lists,
   .   if found, defaults to cr as the delimiter
   .   if no cr found, looks for the presence of comma in the lists,
   .   if found, defaults to comma as the delimiter
   .   if neither found, returns empty (user should have specified another delim)
   
   outputs a list with the same delimiter used in the input lists
   does not sort the result
   Source:
   mergeLists */
   /* Include
   getDelimiters
   NoDuplicates
   */
   
   
   if listA = empty then return listB
   if listB = empty then return listA
   if tDelim = empty then
      if listA & listB contains cr then
         put cr into tDelim
      else if listA & listB contains comma then
         put comma into tDelim
      else
         return empty
      end if
   end if
   NoDuplicates listA,tDelim
   NoDuplicates listB,tDelim
   put getDelimiters(listA & listB) into tempDelim
   split listA with tDelim and tDelim
   split listB with tDelim and tDelim
   union listA with listB
   combine listA with tDelim and tempDelim
   replace tempDelim with empty in listA
   return listA
end mergeLists

function intersectLists listA, listB, tDelim
   /* intersectLists Text Items
   Syntax:
   intersectLists (listA, listB, [tDelim])
   Examples:
   intersectLists (listA, listB)
    intersectLists (listA, listB, "/")
   Description:
   returns the intersection of two lists, ie., a list of items/lines common to both
   .   if tDelim = empty then looks first for the presence of cr in the lists,
   .   if found, defaults to cr as the delimiter
   .   if no cr found, looks for the presence of comma in the lists,
   .   if found, defaults to comma as the delimiter
   .   if neither found, returns empty (user should have specified another delim)
   
   order of items may be changed, result may require sorting
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   intersectLists */
   /* Include
   getDelimiters
   NoDuplicates
   */
   
   
   if listA = empty or listB = empty then return empty
   if tDelim = empty then
      if listA & listB contains cr then
         put cr into tDelim
      else if listA & listB contains comma then
         put comma into tDelim
      else
         return empty
      end if
   end if
   NoDuplicates listA,tDelim
   NoDuplicates listB,tDelim
   put getDelimiters(listA & listB) into tempDelim
   split listA with tDelim and tDelim
   split listB with tDelim and tDelim
   intersect listA with listB
   combine listA with tDelim and tempDelim
   replace tempDelim with empty in listA
   return listA
end intersectLists

function qInString str,altChar
   /* qInString Text
   Syntax:
   qInString (str,[altChar])
   Examples:
   qInString("fld ^text^ of card ^apple^ of stack ^fruits^")
   -->  fld "text" of card "apple" of stack "fruits"
   Description:
   use for creating strings that contain quotes
   The default is to use "^" as quote placeholder, can be overridden
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   qInString */
   
   if altChar = empty then put "^" into altChar
   replace altChar with quote in str
   return str
end qInString

function importFile getWhat,isBinFile, return_flag
   /* importFile File
   Syntax:
   importFile (getWhat,[isBinFile],[return_flag])
   Examples:
   put importFile() into tData
   put importFile("Pick a text file:") into tData
   put importFile("/valid/path/to/file.txt") into tTextData
   put importFile("/valid/path/to/file.png") into tImageData
   put importFile("ftp://www.whatever/photos/angelfish.jpg") into tImageData
   put importFile("http://www.google.com/") into tHTMLdata
   put importFile("Pick an MP3 file:",true) into tMP3data
   Description:
   if getWhat contains "://" then treats it as a webloc, otherwise,
   on MacOS if first char of getWhat = "/" then treats it as a valid filepath,
   .     otherwise will prompt an answer file dialog,
   .     using the contents of getWhat as the prompt
   on Win32 if  char  2 to 3 of getWhat = ":/" then treats it as a valid filepath,
   .     otherwise will prompt an answer file dialog,
   .     using the contents of getWhat as the prompt
   if getWhat = empty, will use a generic prompt
   if isBinFile = empty, it will be automatically set to true for
   .   common binary file suffixes (see script), importing a disk file as binary,
   .   otherwise it will be set to false, importing the file as a text file,
   .   translating end of line characters appropriately for the platform
   .   or user can specify isBinFile manually
   
   if return_flag is not empty then control will return to the caller with empty 
   otherwise return to top is called when the user cancels the file dialog
   
   if an error occurs, the function will return "Error in importFile(): ..."
   
   Source:
   Peter M. Brigham, modified by Mike Doub, pmbrig@gmail.com 
   importFile */
   /* Include
   */
   
   switch
      case getWhat contains "://"
      case getWhat begins with "/"
         put getWhat into tLoc
         break
      default
         -- ask user for file location
         if getWhat = empty then put "Choose a file to import:" into getWhat
         if char -1 of getWhat <> ":" then put ":" after getWhat 
         answer file getWhat
         if the result = "cancel" or it = empty then 
            if return_flag <> empty then
               return empty
            else
               exit to top
            end if
         end if
         put it into tLoc
         break
   end switch
   switch
      case tLoc contains "://"
         load url tLoc
         wait 100 millisecs with messages
         break
      case isBinFile <> empty
         -- accept as specified
         break
      case tLoc ends with ".jpg"
      case tLoc ends with ".jpeg"
      case tLoc ends with ".png"
      case tLoc ends with ".gif"
      case tLoc ends with ".mp3"
      case tLoc ends with ".mp4"
      case tLoc ends with ".m4a"
      case tLoc ends with ".aiff"
      case tLoc ends with ".mpg"
      case tLoc ends with ".mpeg"
      case tLoc ends with ".wav"
      case tLoc ends with ".bin"
         put true into isBinFile
         break
         -- for others, specify isBinFile = true
         -- or add to the list, if you often use another file type
      default
         put false into isBinFile
   end switch
   put the platform into jump
   switch jump
      case "Win32"
         if char 2 to 3 of tLoc = ":/" then
            if isBinFile then
               put "binfile:" before tLoc
            else
               put "file:" before tLoc
            end if
         end if
         break
      case "MacOS"
         if tLoc begins with "/" then
            if isBinFile then 
               put "binfile:" before tLoc
            else
               put "file:" before tLoc
            end if
         end if
         break
   end switch
   
   put URL tLoc into tData
   put the result into tError
   if tError <> empty then return "Error in importFile():" && tError
   return tData
end importFile

on exportFile tData, saveToWhere, isBinFile
   /* exportFile File
   Syntax:
   exportFile tData, [saveToWhere], [isBinFile]      # Command #
   Examples:
   exportFile tData, "/valid/path/to/file.txt"
   exportFile tImageData, tPath, true
   exportFile tImageData, "Name your image file:", true
   .      ensures binary export even if user fails to name file with ".png", etc.
   exportFile tData
   Description:
   if first char of saveToWhere = "/" then treats saveToWhere as a valid filepath
   .   otherwise treats saveToWhere as a prompt for an ask file dialog
   if saveToWhere is empty then default ask file prompt will be "Name your file:"
   if isBinFile = empty, it will be automatically set to true for
   .   common binary file suffixes (see script), exporting a disk file as binary,
   .   otherwise it will be set to false, exporting the file as a text file,
   .   translating end of line characters appropriately for the platform
   .   or user can specify isBinFile manually
   createPath is used to verify that all of the folders in the path actually exist, if
   not present, they are created.
   
   the result will contain the filepath  unless there is an error, then returns the error 
   in the result
   
   Suggestion:   test if char 1 of the result <> "/" then process error
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com, createPath added by Michael Doub
   exportFile */
   /* Include
   createPath
   */
   
   if char 1 of saveToWhere <> "/" then
      if saveToWhere = empty then
         put "Name your file:" into tPrompt
      else
         if char -1 of saveToWhere <> ":" then put ":" after saveToWhere
         put saveToWhere into tPrompt
      end if
      ask file tPrompt
      if it = empty then exit exportFile
      put it into saveToWhere
   end if
   switch
      case isBinFile <> empty
         break
      case saveToWhere ends with ".jpg"
      case saveToWhere ends with ".jpeg"
      case saveToWhere ends with ".png"
      case saveToWhere ends with ".gif"
      case saveToWhere ends with ".mp3"
      case saveToWhere ends with ".mp4"
      case saveToWhere ends with ".m4a"
      case saveToWhere ends with ".aiff"
      case saveToWhere ends with ".mpg"
      case saveToWhere ends with ".mpeg"
      case saveToWhere ends with ".wav"
      case saveToWhere ends with ".bin"
      case saveToWhere ends with ".pdf"
         put true into isBinFile
         break
         -- for others, specify isBinFile = true
         -- or add to the list, if you often use another file type
      default
         put false into isBinFile
   end switch
   createPath saveToWhere
   if isBinFile then put "binfile:" before saveToWhere
   else put "file:" before saveToWhere
   put tData into URL saveToWhere
   if the result <> empty then return "Error in exportFile:" && the result
   return saveToWhere -- in case it needs to be stored by your script
end exportFile


function exactTime
   /* exactTime Date
   Syntax:
   exactTime
   Examples:
   exactTime()
   Description:
   Returns YYYY-MM-DD HH:MM:SS.######
   ie, down to microseconds
   times in this format can be arranged chronologically
   with an ordinary sort command
   
   based on verboseTime() by Mark Talluto, Use-LC list
   Source:
   revised by Peter M. Brigham, pmbrig@gmail.com
   exactTime */
   /* Include
   */
   
   put the long seconds into s
   put char 1 to offset(".",s)-1 of s into dd
   convert dd to internet english date
   put word 5 of dd into tTime
   set the numberformat to "#.000000"
   add 0 to s
   put char -7 to -1 of s after tTime
   convert dd to dateitems
   put item 1 of dd into tYear
   put item 2 of dd into tMo
   set the numberformat to "00"
   add 0 to tMo
   put item 3 of dd into tDay
   add 0 to tDay
   return tYear & "-" & tMo & "-" & tDay && tTime
end exactTime

function getZip pStreet, pCity, pState
   /* getZip Geo
   Syntax:
   getZip (pStreet, pCity, pState)
   Examples:
   getZip (pStreet, pCity, pState)
   Description:
   Returns the zipcode give an address
   
   -- Adapted from Scott Rossi, LC-use list
   -- internet connection required, uses Google Maps API
   -- quite fast!
   Source:
   Peter M. Brigham, pmbrig@gmail.com
   getZip */
   /* Include
   getNestedItems
   _googleAPIstring
   */
   
   put "http://maps.googleapis.com/maps/api/geocode/json?address=<a>&sensor=false" \
         into tURL
   put _googleAPIstring(pStreet) & comma into theStreet
   put _googleAPIstring(pCity) & comma into theCity
   put _googleAPIstring(pState) into theState
   -- GET GEO DATA
   replace "<a>" with (theStreet & "+" & theCity & "+" & theState) in tURL
   put url tURL into theGeoData
   if theGeoData = empty then
      return "getZip() error: could not connect to Google."
   end if
   if "ZERO_RESULTS" is in theGeoData then return "Error: no geocode data found."
   if "formatted_address" is not in theGeoData then
      return "getZip() error: no zip code data found."
   end if
   -- theGeoData should now contain a line like:
   --    "formatted_address" : "1 State Street, Boston, MA 02109, USA"
   -- need word -1 of comma-del item 3 of everything after "formatted_address"
   put getNestedItems(theGeoData,2,"formatted_address",3,comma,-1,space) \
         into theZip
   if theZip is not a number then
      return "getZip() error: no zip code data found."
   end if
   return theZip
end getZip

function getCounty pStreet, pCity, pState
   /* getCounty Geo
   Syntax:
   getCounty (pStreet, pCity, pState)
   Examples:
    getCounty (pStreet, pCity, pState)
Description:
Returns the County given an address

   -- Adapted from Scott Rossi's getZip() function, LC-use list
   -- internet connection required, uses Google Maps API
   -- quite fast!
   
Source:
Peter M. Brigham, pmbrig@gmail.com
getCounty */
/* Include
getNestedItems
_googleAPIstring
*/
  
   
   put "http://maps.googleapis.com/maps/api/geocode/json?address=<a>&sensor=false" \
         into tURL   
   put _googleAPIstring(pStreet) & comma into theStreet
   put _googleAPIstring(pCity) & comma into theCity
   put _googleAPIstring(pState) into theState
   -- GET GEO DATA
   replace "<a>" with (theStreet & "+" & theCity & "+" & theState) in tURL
   put url tURL into theGeoData
   if theGeoData = empty then
      return "getCounty() error: could not connect to Google."
   end if
   if "ZERO_RESULTS" is in theGeoData then return "Error: no geocode data found."
   -- RETRIEVE COUNTY
   if "administrative_area_level_2" is not in theGeoData then
      return "getCounty() error: no county information available."
   end if
   put getNestedItems(theGeoData,1,"administrative_area_level_2",-3,cr,4,quote) \
         into tCounty
   return tCounty
end getCounty

private function _googleAPIstring pString
   -- utility function for getZip() and getCounty()
   replace "." with empty in pString
   replace "," with empty in pString
   if char -1 of pString is space then delete char -1 of pString
   replace space with "+" in pString
   return pString
end _googleAPIstring

function howmany tStr,tContainer,caseSens
   /* howmany Text
   Syntax:
   howmany (tStr,tContainer,[caseSens])
   Examples:
   howmany("00","000000") -->3
   Description:
   Returns how many times tStr occurs in tContainer where overlapping matches 
   are NOT counted.
   
   caseSens = true|false|empty
   
   Source:
   Peter M. Brigham, pmbrig@gmail.com 
   howmany */
   /* Include
   */
   
   if caseSens = empty then put false into caseSens
   set the casesensitive to caseSens
   if tStr is not in tContainer then return 0
   put len(tContainer) into origLength
   replace tStr with empty in tContainer
   return (origLength - len(tContainer))/len(tStr)
end howmany

function formatDate theDate, theFormat
   /* formatDate Date
   Syntax:
   formatDate (theDate, theFormat)
   Examples:
   formatDate (theDate, "sql date")
   formatDate (theDate, "short date")
   formatDate (theDate, "abbreviated date")
   formatDate (theDate, "internet date")
   formatDate (theDate, "long date")
   formatDate (theDate, "julian date")
   
   Description:
   Accepts any valid date for the first parameter. If not a valid date, it simply returns
   what was passed. Second parameter can be any of the following:
   sql date: date in the yyyy-mm-dd format
   short date, abbreviated date, internet date, long date: LC versions of the same
   julian date: Julian number based on (I believe) Jacques formula)
   Source:
   bobsneidar@iotecdigital.com
   formatDate */
   
   
   put the itemdelimiter into theOldDelim
   set the itemdelimiter to "-"
   
   if the length of item 1 of theDate = 4 and \
         the number of items of theDate = 3 and \
         item 1 of theDate is a number and \
         item 2 of theDate is a number and \
         item 3 of theDate is a number then
      put item 2 of theDate & "/" & \
            item 3 of theDate & "/" & \
            item 1 of theDate into theDate
   end if
   
   convert theDate to dateitems
   set the itemdelimiter to theOldDelim
   
   switch theFormat
      case "sql date"
         put item 1 of theDate & "-" & \
               format("%02d",item 2 of theDate) & "-" & \
               format("%02d",item 3 of theDate) into theDate
         break
      case "short date"
         convert theDate from dateitems to short date
         break
      case "abbreviated date"
         convert theDate from dateitems to abbreviated date
         break
      case "internet date"
         convert theDate from dateitems to internet date
         break
      case "long date"
         convert theDate from dateitems to long date
         break
      case "julian date"
         put the date into theDate
         convert theDate to dateItems
         if  ((item 2 of theDate = 1) or (item 2 of theDate = 2)) then
            put 1 into theDay
         else
            put 0 into theDay
         end if
         put item 1 of theDate + 4800 - theDay into theYear
         put item 2 of theDate + (12 * theDay) - 3 into theMonth
         put item 3 of theDate + \
               ((153 * theMonth + 2) div 5) + \
               (365 * theYear) + \
               (theYear div 4) - \
               (theYear div 100) + \
               (theYear div 400) - \
               32045 into theDate
         break
   end switch
   
   return theDate 
end formatDate

function InvertList p, delim
   /* InvertList Lines
   Syntax:
   InvertList(aList,[linedelim])
   Examples:
   InvertList(tlist) 
   put "1,2,6,5" into tlist
   InvertList(tlist, comma) --> "5,6,2.1"
   Description:
   This function inverts the lines of an unsorted List.  I normally think of a line
   being terminated with a CR, but you can change the line deliminator so other
   lists can be inverted.
   Source:
   Michael Doub adapted from Alex Tweedly's work on qrevers
   InvertList */
   put linedel into temp
   if delim is empty then put cr into delim
   set the linedel to delim
   put p into t 
   put the number of chars in t into tlen 
    repeat for each line l in p 
         put the number of chars in l into tl 
         put l & delim into char (tLen-tl) to tLen of t 
         subtract (tl+1) from tLen 
    end repeat 
   set the linedel to temp
   if char -1 of p <> char -1 of t then delete char -1 of t
   return t 
end InvertList

function keepColumns pData,pColsToKeep,pDelim
   /* keepColumns Table
   Syntax:
   keepColumns (<data>,<cols>[,<delim>])
   Examples:
   put keepColumns (data_string,"2,4") into data_string2
   put keepColumns (data_string,"2,3","/") into data_string2
   Description:
   Keeps specified columns of a table and delete the non-specified.    This routine
   will also allow you to change the order of the columns that are not deleted.
   
   .     data: Specifies the data to parse.
   .     cols: A comma separated list of columns or column ranges to be kept,
   .         for example "2,5,7"
   .         or a column range: "3-5"
   .         or a combination "2,4-5,7,9-11,"
   .     delim: Optional column separator for example "," or "|"
   .         if unspecified, defaults to tab.
   
   Source:
   Adapted by Michael Doub, based on a handler by Hugh Senior and Peter M. Brigham
   keepColumns */
   /* Include
   getItem
   */
   
   if pColsToKeep = empty then return pData
   replace space with empty in pColsToKeep
   repeat for each item pCol in pColsToKeep
      if "-" is in pCol then 
         put getItem(pCol,1,"-") into firstColNbr
         put getItem(pCol,2,"-") into lastColNbr
         repeat with i = firstColNbr to lastColNbr
            put i & comma after pColsToKeepExpanded
         end repeat
      else
         put pCol & comma after pColsToKeepExpanded
      end if
   end repeat
   put char 1 to -2 of pColsToKeepExpanded into pColsToKeep
   if pDelim = empty then put tab into pDelim
   set the columnDelimiter to pDelim
   split pData by column
   put item 2 of extents(pData) into tMax
   
   repeat for each item n in pColsToKeep
      if n >= 1 and n <= tMax then
         add 1 to x
         put pData[n] into rData[x]
      end if
   end repeat
   combine rData by column
   return rData
end keepColumns

function getAvailableHandlers pObjRef
   /* getAvailableHandlers System
   Syntax:
   getAvailableHandlers (pObjRef)
   Examples:
   put getAvailableHandlers (pObjRef) into foo
   Description:
   Returns a comma seperated list of all of the handlers and function in the specifed object.
   
   .    item 1 = [ M | PM | F | PF ] or  
   .                   [ handler | private handler | function | private function ]
   .    item 2 = handler or function name
   .    item 3 = linenumber of handler definition of item 2 within the script
   .                   of the referenced object
   .    item 4 = linenumber of the end statment of item 2 within the script of 
   .                   the referenced object
   Source:
   undocumented handler found by Richard Gaskin
   getAvailableHandlers */
   put revAvailableHandlers(pObjRef) into temp
   delete word 5 to -1 of line 1 of temp
   replace space with comma in temp
   return temp
end getAvailableHandlers

function getHandlerFromScript pObjRef, pHandlerName, pType
   /* getHandlerFromScript System
   Syntax:
   getHandlerFromScript (pObjRef, pHandlerName, [pType])
   Examples:
   put   getHandlerFromScript (pObjRef, "getHandlerFromScript") into foo
   put   getHandlerFromScript (pObjRef, "getHandlerFromScript","function") into foo
   Description:
   Returns the specified handler from the script of pObjRef
   
   .   pHandlerName should be the bare name of the handler
   .   if you have duplicate handler names, eg, a function and a command with
   .      the same name, or getprop and setprop handlers with the same name,
   .      then both/all will be returned, unless you specify the optional pType as
   .     "function" or "command" or "getprop" or "setprop"
   .   if not found, returns "no such handler:" && pType && pHandlerName
   
   Source:
   Peter M. Brigham
   getHandlerFromScript */
   /* Include
   caseSwitch
   */
   put the script of pObjRef into tScript
   put the revAvailableHandlers of pObjRef into hList
   delete word 5 to -1 of line 1 of hList
   filter hList with "* " & pHandlerName & " *"
   put caseSwitch(pType,"function=F","command=M","getprop=G","setprop=S","*=*") \
         into tType
   if tType <> empty then
      filter hList with "*" & tType & " *"
   end if
   if hList = empty then
      put "no such handler:" && pType && pHandlerName into tError
      replace "  " with space in tError
      return tError
   end if
   repeat for each line h in hList
      put line (word 3 of h) to (word 4 of h) of tScript & cr & cr after outScript
   end repeat
   delete char -2 to -1 of outScript
   return outScript
end getHandlerFromScript

function caseSwitch
   /* caseSwitch Misc
   Syntax:
   caseSwitch (var_to_Match,<matchValue>=<returnValue>,[<matchValue>=<returnValue>]...
   Examples:
   put caseSwitch(len(tZip),"5=zip","10=zip+4","*=not a zip code")  into zipCodeType
   Description:
   Does a quick inline switch/case but supports a default for a non-match.  
   .    Also see Switch
   
   param 1 is checkValue
   params 2+ are in the form matchValue(s)>=<returnValue
   .    separate multiple matcheValues with commas
   .    and enclose each matchValue=returnValue pair in quotes
   if checkValue matches one or more items in matchValue(s),
   .    returns returnValue
   
   Note that checkValue should NOT be enclosed in quotes'
   
   Use a matchValue of "*" to specify a default value,
   .    to be returned if no matches found in the list
   .    if the default is "*=*" then no match returns the original <checkValue>
   .    if no match and no default value specified, then returns empty
   
   Source:
   Peter M. Brigham   from Ken Ray, use-LC list, originally named stsSwitch()
   caseSwitch */
    put param(1) into tCheckValue
   set the itemDel to "="
   put "" into tDefault
   repeat with x = 2 to the paramCount
      put param(x) into tCheck
      put item 1 of tCheck into tMatch
      put item 2 of tCheck into tRetVal
      replace "," with "=" in tMatch
      if tCheckValue = empty and tMatch = empty then return tRetVal
      if tCheckValue is among the items of tMatch then return tRetVal
      if tMatch = "*" then
         if tRetVal = "*" then
            put tCheckValue into tDefault
         else
            put tRetVal into tDefault
         end if
      end if
   end repeat
   return tDefault
end caseSwitch

function displayBinary pIn, wrapLen
   /* displayBinary Debugging
   Syntax:
   displayBinary (pIn,[wrapLen])
   Examples:
   displayBinary (pIn)
   displayBinary (pIn, 6)
   Description:
   Converts the data in pIn into a readable binary representation:
   
   01101111	01110101	01101110	01110100
   
   Each byte is seperated with a tab.  WrapLen is the number of bytes
   to display before substituting return for the tab.
   
   Source:
   Michael Doub
displayBinary */

   if wraplen is empty then put 8 into wrapLen
   set the numberformat to 00000000
   put 1 into rctr
   repeat for each char n in pIn
      put baseconvert(chartonum(n),10,2) + 0 & tab after rOut
      add 1 to rctr
      if rctr > wrapLen then 
         put cr into char -1 of rout
         put 1 into rctr
      end if
   end repeat
   if the last char of rOut <> cr then put cr after rOut
   return rOut
end displayBinary

function displayHex pIn, wrapLen
   /* displayHex Debugging
   Syntax:
   displayHex (pIn, [wrapLen])
   Examples:
   displayHex (pIn)
   displayHex (pIn, 12)
   Description:
   Converts the data in pIn into a readable hex representation representation with each
   byte seperated by a tab:
   
   6E 22 2C 22 41 6D 6F 75 6E 74 22 2C
   
   WrapLen is the number of bytes
   to display before substituting return for the tab.
   
   Source:
   Michael Doub
   displayHex */
  
   put 1 into rctr
   if wraplen is empty then put 8 into wrapLen
   repeat for each char n in pIn
      put baseconvert(chartonum(n),10,16) into kjh
      if the number of chars of kjh < 2 then put "0" before kjh
      put kjh & tab after rout
      add 1 to rctr
      if rctr > wrapLen then 
         put cr into char -1 of rout
         put 1 into rctr
      end if
   end repeat
   if the last char of rOut <> cr then put cr after rout
   return rout
end displayHex

function displayDump pIn
   /* displayDump Debugging
   Syntax:
   displayDump (pIn)
   Examples:
    displayDump (pIn)
    Description:
    Produces a traditional dump format
    
    0   22 41 63 63   6F 75 6E 74   22 2C 22 50   6F 73 74 65  " A c c o u n t " , " P o s t e
    
    Item 1 is the line offset from the start of the data
    Item 2 to 4  are hex data, or 4 sets of hex numbers seperated by a space
    Item 5 is a text string of printable characters where non printable are represented by 
    .    a period
    
    Source:
    Michael Doub
displayDump */

   put 0 into linenum
   put 1 into x
   put 1 into y
   put empty into part1
   put empty into part2
   repeat for each char n in pIn
      put baseconvert(chartonum(n),10,16) into hex
      if the number of chars of hex < 2 then put "0" before hex
      put hex after part1
      put chartonum(n) into tChar
      if tChar > 32 then put numtochar(tChar) into tChar else put "." into tChar
      put tChar after part2
      add 1 to x
      add 1 to y
      
      if x <= 4 then 
         put " " after  part1
      else
         put tab after part1
         put 1 into x
      end if
      if y <= 16 then 
         put " " after part2
      else
         put cr after part2
         put baseconvert(linenum,10,16) into hex
         add 16 to linenum
         put hex & tab & part1 & tab & part2 after rout
         put empty into part1
         put empty into part2
         put 1 into y
      end if
   end repeat
     if the last char of rOut <> cr then put cr after rOut
   return rout
end displayDump

function PowerSource
   /* PowerSource System
   Syntax:
   PowerSource()
   Examples:
   PowerSource()
   Description:
   -- returns the current power source for a laptop
   --    "AC" or "Battery"
   Source:
   Peter M. Brigham with help from Martin Koob, Bob Sneidar, Richard Gaskin
   PowerSource */
   /* Include
   caseSwitch
   */
   
   switch the platform
      case "MacOS"
         -- thanks to Martin Koob, use-LC list
         put shell ("pmset -g batt") into tStatus
         -- returns something like:
         --    Currently drawing from 'AC Power'
         --     -InternalBattery-0	99%; finishing charge; 0:00 remaining
         return char 2 to -1 of word -2 of line 1 of tStatus
         break
      case "Win32"
         -- thanks to Bob Sneidar, use-LC list
         put shell("WMIC Path Win32_Battery GetAvailability") into tStatus
         -- Line 3 will contain 2 if the battery is charging, 3 if running on battery
         put line 3 of tStatus into tStatus
         return caseSwitch(tStatus,"3=Battery","*=AC")
         break
      default
         -- Unix, thanks to Mark Wieder
         constant kBatteryStatus0 = "/sys/class/power_supply/BAT0/status"
         constant kBatteryStatus1 = "/sys/class/power_supply/BAT1/status"
         if there is a file (kBatteryStatus0) then
            open file (kBatteryStatus0) for read
            read from file (kBatteryStatus0) until eof
            put it into tStatus
            close file  (kBatteryStatus0)
         else if there is a file (kBatteryStatus1) then
            open file (kBatteryStatus1) for read
            read from file (kBatteryStatus1) until eof
            put it into tStatus
            close file  (kBatteryStatus1)
         else
            return "AC"
            -- no battery, must be running off external power
         end if
         put word 1 of tStatus into tStatus
         --if tStatus = empty then return empty
         return caseSwitch(tStatus,"discharging=Battery","charging,unknown,full=AC","*=*")
         -- if tStatus is not in "discharging,charging,unknown,full" then
         --    just returns whatever "/sys/class/power_supply/BATx" reports
   end switch
end PowerSource

function formatNumber pNum, pPrefix, pSeparator, pPostfix, pDecOut, pDecIn
   /* formatNumber Text
   Syntax:
   formatNumber (pNum, [pPrefix], [pSeparator], [pPostfix], [pDecOut], [pDecIn])
   Examples:
   formatNumber (1000.00) --> $1000.00
   formatNumber (1000,,comma) --> 1,000
   formatNumber (1000.00,,comma) --> 1,000.00
   formatNumber (1000.00,"$",comma) --> $1,000.00
   formatNumber (1000.00,"£") --> £1000.00
   formatNumber (1000.00,"£",".",,comma) --> £1.000,00
   formatNumber (1000,00,"£",".",,comma,comma) --> £1.000,00
   formatNumber (1000.00,,,"$") -- 1000.00$
   Description:
   Formats a number string based upon the parameters supplied.
   
   pNum is a positive of negitive number
   pPrefix and pPostfix are added to the front and back of the returned string
   pSeperator is the character to be used to seperate each multiple of a thousand
   pDecIn is the character seperating the whole and fraction part of the number
   .   defaults to "."
   pDecOut is the character to be returned as the character seperating the whole and 
   .   fraction part of the number.  defaults to the value of pDecIn.   There are no
   .   seperators insected in the fractional part of a number.
   Source:
   adapted by Michael Doub from Håkan,  Hakan@Exformedia.se
   formatNumber */
   local tIsNegative, tRest, pDecimalPos 
   if  paramcount() = 1 then 
      put "$" into pPrefix
      put "," into pSeparator
   end if
   if pDecIn is empty then put "." into pDecIn
   if pDecOut is empty then put pDecIn into pDecOut
   if pNum < 0 then 
      put abs(pNum) into pNum 
      put true into tIsNegative 
   end if 
   put offset(pDecIn, pNum) into pDecimalPos 
   if pDecimalPos <> 0 then 
      put char pDecimalPos + 1 to -1 of pNum into tRest 
   else
      put empty into pDecOut
   end if 
   put char 1 to pDecimalPos -1 of pNum into pNum 
   repeat with i = length(pNum)-3 to 3 step -3 
      put pSeparator before char i+1 of pNum 
   end repeat 
   
   if tIsNegative then 
      return pPrefix & "-" &  pNum & pDecOut & tRest & pPostfix 
   else 
      return pPrefix & pNum & pDecOut & tRest & pPostfix 
   end if 
end formatNumber 

on xyAD x,y,dist,ang,@x1,@y1, pRaw
   /* xyAD Geometry
   Syntax:
   xyAD x,y,dist,ang,x1,y1,[pRaw]  # Command #
   Examples:
   put 0 into x1
   put 0 into y1
   xyAD x,y,dist,ang,x1,y1
   xyAD x,y,dist,and,x1,y1, true
   Description:
   Calculate point x1,y1 that is distance dis and angle ang from point x,y
   .    x1 and y1 are put into param 5,and 6.  Note that this are passed by reference 
   .            so make sure they exist in the caller.
   .    ang is in degrees, positive is east of north
   .    if pRaw is true, then the x1, y1 will NOT be rounded.
   Source:
   adapted from David Epstein's function by Michael Doub
   xyAD */
   if ang > 360 then put ang mod 360 into ang
   if ang <= 0 then put 360 + ang into ang
   put  ((270 + ang) * 2 * pi / 360) into ang
   put  x + dist * cos(ang) into x1
   put  y + dist * sin(ang) into y1
   if pRaw = true then exit xyAD
   put  round(x1) into x1
   put  round(y1) into y1
end xyAD
 
---- Below is commented out as we already have printArray  this just outputs
---- a slightly different format

--function displayArray @pArray, pFullData, _pDimension
--   /* displayArray Debugging
--   Syntax:
--   displayArray (pArray, [pFullData])
--   Examples:
--   put displayArray(tArray) into fld "peruse"
--   put displayArray(tArray,true) into fld "peruse"
--   Description:
--   Displays an array as an outline-style list.  Most useful for multidimensional arrays, 
--   to see the structure

--   .   if an element of the array contains more than one line,
--   .      the first line only will be displayed (less confusing to look at).  If you want to see 
--   .      the full data then pass pFullData = true

--   _pDimension is an internally used parameter for recursion

--   pArray is referenced to avoid duplicating large arrays in memory,
--   .       but the array is not altered by this function

--   Source:
--   by Peter M. Brigham, pmbrig@gmail.com, adapted from a handler by Trevor DeVore
--   displayArray */
--   /* Include
--   makeString
--   */

--   if _pDimension is empty then put 0 into _pDimension
--   if pFullData = empty then put false into pFullData
--   put ": " into divString
--   put the keys of pArray into theKeys
--   if line 1 of theKeys is a number then
--      sort theKeys numeric
--   else
--      sort theKeys
--   end if
--   repeat for each line theKey in theKeys
--      if pArray[theKey] is an array then
--         put makeString(space,_pDimension*3) & theKey & cr after theText
--         put pArray[theKey] into theTempArray
--         put displayArray(theTempArray, pFullData, _pDimension + 1) after theText
--      else
--         if pFullData then
--            put makeString(space,_pDimension*3) & theKey & ":" \
      --                  && pArray[theKey] & cr after theText
--         else
--            put pArray[theKey] into tElement
--            put empty into tTrailer
--            if the number of lines of tElement > 1 then
--               put " ..." into tTrailer
--            end if
--            put makeString(space,_pDimension*3) & theKey & divString \
      --                  & (line 1 of tElement) & tTrailer & cr after theText
--         end if
--      end if
--   end repeat
--   return theText
--end displayArray

function makeString pChar, n
   /* makeString Text
   Syntax:
   makeString (pChar, n)
   Examples:
   put makeString(space,5) into foo
Description:
Returns a string of n characters (pChar) without using a repeat loop!
  
Source:
Peter M. Brigham, pmbrig@gmail.com -- improved by Richard Gaskin
makeString */
  
   set the linedel to pChar
   put pChar into line n of temp
   return temp
end makeString

function ReorderColumns pData,pColumnOrder,pDelim
   /* ReorderColumns Table
   Syntax:
   ReorderColumns (<data>,<cols>[,<delim>])
   Examples:
   put "1,2,3,4,5,6,7,8,9" into data_string
   put ReorderColumns (data_string,"2-4, 7,6",comma) -->  "2,3,4,7,6,1,5,8,9"
   Description:
   Reorders the columns of a table to the order specified.    If a column is
   not listed, it will be placed after the last specified column in assending
   column number order.  
   
   .     data: Specifies the data to parse.
   .     cols: A comma separated list of columns or column ranges to be kept,
   .         for example "2,5,7"
   .         or a column range: "3-5"
   .         or a combination "2,4-5,7,9-11,"
   .     delim: Optional column separator for example "," or "|"
   .         if unspecified, defaults to tab.
   
   Source:
   Adapted by Michael Doub, based on a handler by Hugh Senior and Peter M. Brigham
   ReorderColumns */
   /* Include
   getItem
   */
   
   if pColumnOrder = empty then return pData
   replace space with empty in pColumnOrder
   repeat for each item pCol in pColumnOrder
      if "-" is in pCol then 
         put getItem(pCol,1,"-") into firstColNbr
         put getItem(pCol,2,"-") into lastColNbr
         repeat with i = firstColNbr to lastColNbr
            put i & comma after pColumnOrderExpanded
         end repeat
      else
         put pCol & comma after pColumnOrderExpanded
      end if
   end repeat
   put char 1 to -2 of pColumnOrderExpanded into pColumnOrder
   
   if pDelim = empty then put tab into pDelim
   set the columnDelimiter to pDelim
   set itemdel to pDelim
   put the number of items in line 1 of pData into maxColumns
   set itemdel to comma
   repeat with i = 1 to maxColumns
      if i is not among the items of pColumnOrder then put comma & i after pColumnOrder
   end repeat
   
   
   split pData by column
   put item 2 of extents(pData) into tMax
   
   repeat for each item n in pColumnOrder
      if n >= 1 and n <= tMax then
         add 1 to x
         put pData[n] into rData[x]
      end if
   end repeat
   combine rData by column
   return rData
end ReorderColumns

function geoDistanceTo t1, n1, t2, n2, R
   /* geoDistanceTo Geo
   Syntax:
   geoDistanceTo (t1, n1, t2, n2, [R])
   Examples:
   geoDistanceTo (38 898556, -77.037852, 38.897147, -77.043934)
   geoDistanceTo (38 898556, -77.037852, 38.897147, -77.043934, 6372000)
   Description:
   Returns the distance between two points (using haversine formula).
   
   Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   t2 point 2 latutude in degrees
   .   n2 point 2 longitude in degrees
   .   R is the radius of the earth in meters. This defaults to 6371000 meters
   
   Returns the distance in meters
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   Source:
   ported by Michael Doub
   geoDistanceTo */
   /* Include
   deg2rad
   */
   if R is empty then put 6371000 into R
   put deg2rad(t1) into Lat1; put deg2rad(n1)  into Lon1
   put deg2rad(t2) into Lat2; put deg2rad(n2)  into Lon2
   put  Lat2 - Lat1 into Delta_Lat
   put  Lon2 - Lon1 into  Delta_Lon
   put sin(Delta_Lat/2) * sin(Delta_Lat/2) + cos(Lat1) * cos(Lat2) * sin(Delta_Lon/2) * sin(Delta_Lon/2) into AA
   put 2 * atan2(sqrt(AA), sqrt(1-AA)) into c
   put  R * c into d
   return d;
end geoDistanceTo
   
   
function geoBearingTo t1,n1,t2,n2
   /* geoBearingTo Geo
   Syntax:
   geoBearingTo (t1,n1,t2,n2)
   Examples:
   geoBearingTo (38 898556, -77.037852, 38.897147, -77.043934)
   Description:
   Returns the (initial) bearing from point1 to destination point2.
   
   Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   t2 point 2 latutude in degrees
   .   n2 point 2 longitude in degrees
   
     Returns degrees from North
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   see http://mathforum.org/library/drmath/view/55417.html
   Source:
   ported by Michael Doub
   geoBearingTo */
   /* Include
   deg2rad
   rad2deg
   */
   put deg2rad(t1) into Lat1; put deg2rad(n1)  into Lon1
   put deg2rad(t2) into Lat2; put deg2rad(n2)  into Lon2
   put Lon2 - Lon1 into Delta_Lon
   put sin(Delta_Lon) * cos(Lat2) into y
   put cos(Lat1)*sin(Lat2) - sin(Lat1)*cos(Lat2)*cos(Delta_Lon) into x
   put atan2(y, x) into Ang
   return (rad2deg(Ang)+360) MOD 360
end geoBearingTo
   
   
 
function geofinalBearingTo  t1,n1,t2,n2
   /* geofinalBearingTo Geo
   Syntax:
   geofinalBearingTo  (t1,n1,t2,n2)
   Examples:
   geofinalBearingTo  (38 898556, -77.037852, 38.897147, -77.043934)
   Description:
   Returns final bearing arriving at destination  points from point 1; the final bearing
   will differ from the initial bearing by varying degrees according to distance and latitude.
   
   Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   t2 point 2 latutude in degrees
   .   n2 point 2 longitude in degrees
   
    Returns degrees from North
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   Source:
   ported by Michael Doub
   geofinalBearingTo */
   /* Include
   geoBearingTo
   */
   // get initial bearing from destination point to this point & reverse it by adding 180°
   return ( geoBearingTo (t1,n1,t2,n2) +180 ) MOD 360
end geofinalBearingTo
   
   
function geoMidpointTo t1,n1,t2,n2
   /* geoMidpointTo Geo
   Syntax:
   geoMidpointTo (t1,n1,t2,n2)
   Examples:
   geoMidpointTo (38 898556, -77.037852, 38.897147, -77.043934)
   Description:
   Returns the midpoint between point1 and  point2.
   
    Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   t2 point 2 latutude in degrees
   .   n2 point 2 longitude in degrees
   
   Returns latutude,longitude each in degrees
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   see http://mathforum.org/library/drmath/view/51822.html for derivation
   Source:
   ported by Michael Doub
   geoMidpointTo */
   /* Include
   deg2rad
   rad2deg
   */
   
   put deg2rad(t1) into Lat1; put deg2rad(n1)  into Lon1
   put deg2rad(t2) into Lat2; put deg2rad(n2)  into Lon2
   put Lon2 - Lon1 into Delta_Lon 
   
   put  cos(Lat2) * cos(Delta_Lon) into Bx
   put  cos(Lat2) * sin(Delta_Lon) into _By
   
   put atan2(sin(Lat1)+sin(Lat2) , sqrt( (cos(Lat1)+Bx)*(cos(Lat1)+Bx) + _By*_By) )  into Lat3
   put Lon1 + atan2(_By, cos(Lat1) + Bx) into Lon3
   put (Lon3+3*PI) mod (2*PI) - PI into Lon3  // normalise to -180..+180°
   
   return rad2deg(Lat3),rad2deg (Lon3)
end geoMidpointTo
   
   
function geoDestinationPoint t1,n1,distance, bearing, radius
   /* geoDestinationPoint Geo
   Syntax:
   geoDestinationPoint (t1,n1,distance, bearing, [radius])
   Examples:
   geoDestinationPoint (51.4778, -0.0015, 100000, 45)
   Description:
   Returns the destination point from point1 having travelled the given distance on the
   given initial bearing (bearing normally varies around path followed).   
   
   Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   distance in meters
   .   bearing in degrees
   .   radius of the earth is optional, defaults to 6371000
   
   Returns latutude,longitude each in degrees
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   see http://williams.best.vwh.net/avform.htm#LL
   Source:
   ported by Michael Doub
   geoDestinationPoint */
   /* Include
   deg2rad
   rad2deg
   */
   
   if radius is empty then put 6371000 into radius 
   put distance / radius into AngDist    // angular distance in radians
   put  deg2rad(bearing) into Ang
   put deg2rad(t1) into Lat1; put deg2rad(n1)  into Lon1
   put  asin( sin(Lat1)*cos(AngDist) + cos(Lat1)*sin(AngDist)*cos(Ang) ) into Lat2
   put Lon1 + atan2(sin(Ang)*sin(AngDist)*cos(Lat1), cos(AngDist)-sin(Lat1)*sin(Lat2)) into Lon2
   put (Lon2+3*PI) MOD (2*PI) - PI into Lon2  // normalise to -180..+180°
   return rad2deg(Lat2),rad2deg (Lon2)
end geoDestinationPoint
   

function geoIntersection t1,n1, brng1, t2,n2, brng2
   /* geoIntersection Geo
   Syntax:
   geoIntersection (t1,n1, brng1, t2,n2, brng2)
   Examples:
   geoIntersection (t1,n1, brng1, t2,n2, brng2)
   Description:
   Returns the point of intersection of two paths defined by point and bearing.
   
   Parameters:
   .   t1 point 1 latutude in degrees
   .   n1 point 1 longitude in degrees
   .   brng1 bearing is degrees 
   .   t2 point 2 latutude in degrees
   .   n2 point 2 longitude in degrees
   .   brng2 bearing is degrees 
   
   Returns latutude,longitude each in degrees
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   Source:
   ported by Michael Doub
   geoIntersection */
   /* Include
   deg2rad
   rad2deg
   */
   // see http://williams.best.vwh.net/avform.htm#Intersection
   
   put deg2rad(t1) into Lat1; put deg2rad(n1)  into Lon1
   put deg2rad(t2) into Lat2; put deg2rad(n2)  into Lon2
   put deg2Rad(brng1) into Ang13;  put deg2Rad(brng2) into Ang23
   put  Lat2-Lat1 into Delta_Lat; put  Lon2-Lon1 into Delta_Lon
   
   put  2*asin( sqrt( sin(Delta_Lat/2)*sin(Delta_Lat/2) + cos(Lat1)*cos(Lat2)*sin(Delta_Lon/2)*sin(Delta_Lon/2) ) ) into AngDist12
   if AngDist12 = 0 then return empty
   
   // initial/final bearings between points
   put acos( ( sin(Lat2) - sin(Lat1)*cos(AngDist12) ) / ( sin(AngDist12)*cos(Lat1) ) ) into Ang1
   --TODO if (isNaN(Ang1)) Ang1 = 0; // protect against rounding
   put acos( ( sin(Lat1) - sin(Lat2)*cos(AngDist12) ) / ( sin(AngDist12)*cos(Lat2) ) ) into Ang2
   
   if (sin(Lon2-Lon1) > 0) then
      put  Ang1 into Ang12
      put 2*PI - Ang2 into Ang21
   else
      put  2*PI - Ang1 into Ang12
      put  Ang2 into Ang21
   end if
   
   put (Ang13 - Ang12 + PI) MOD (2*PI) - PI into tAng1    // angle 2-1-3
   put (Ang21 - Ang23 + PI) MOD (2*PI) - PI into tAng2   // angle 1-2-3
   
   if (sin(tAng1) = 0 and  sin(tAng2) =0) then  return empty; // infinite intersections
   if (sin(tAng1)*sin(tAng2) < 0) then return empty;      // ambiguous intersection
   
   //tAng1 = abs(tAng1);
   //tAng2 = abs(tAng2);
   // ... Ed Williams takes abs of tAng1/tAng2, but seems to break calculation?
   
   put  acos( -cos(tAng1)*cos(tAng2) + sin(tAng1)*sin(tAng2)*cos(AngDist12) ) into tAng3
   put  atan2( sin(AngDist12)*sin(tAng1)*sin(tAng2), cos(tAng2)+cos(tAng1)*cos(tAng3) ) into AngDist13
   put  asin( sin(Lat1)*cos(AngDist13) + cos(Lat1)*sin(AngDist13)*cos(Ang13) ) into Lat3
   put  atan2( sin(Ang13)*sin(AngDist13)*cos(Lat1), cos(AngDist13)-sin(Lat1)*sin(Lat3) ) into Delta_Lon13
   put  Lon1 + Delta_Lon13 into Lon3
   put  (Lon3+3*PI) MOD (2*PI) - PI into Lon3    // normalise to -180..+180°
   return rad2deg(Lat3),rad2deg (Lon3)
end geoIntersection
   
   
function compassPoint bearing, precision
   /* compassPoint Geo
   Syntax:
   compassPoint (bearing, [precision])
   Examples:
   compassPoint (45)
   compassPoint (45, 2)
   Description:
   Returns compass point (to given precision) for supplied bearing.
   
   Parameters
   .   bearing in degrees
   .   precision  = 1, N S E W
   .                       2, N NW E SE S SW W NW
   .                       3, N NNE NE ENE E SES SE SSE S SSW SW WSW W WNW NW NNW
   
   Latitude/longitude spherical geodesy formulae & scripts           (c) Chris Veness 2002-2015  
   www.movable-type.co.uk/scripts/latlong.html                                   MIT Licence
   Source:
   ported by Michael Doub
   compassPoint */
   
   if precision is empty then put 3 into precision
   
   // note precision = max length of compass point; it could be extended to 4 for quarter-winds
   // (eg NEbN), but I think they are little used
   
   put ((bearing MOD 360)+360) MOD 360 into bearing     // normalise to 0..360
   
   
   switch precision
      case 1   // 4 compass points
         switch round(bearing*4/360) mod 4
            case 0; put "N" into rVal; break;
            case 1; put "E" into rVal; break;
            case 2;  put "S" into rVal; break;
            case 3; put "W" into rVal; break;
         end switch
         break
      case 2 // 8 compass points
         switch (round(bearing*8/360) mod 8) 
            case 0; put "N" into rVal;  break;
            case 1; put "NE" into rVal; break;
            case 2; put "E" into rVal;  break;
            case 3; put "SE" into rVal; break;
            case 4; put "S" into rVal;  break;
            case 5; put "SW" into rVal; break;
            case 6; put "W" into rVal;  break;
            case 7; put "NW" into rVal; break;
         end switch
         break
      case 3   // 16 compass points
         switch (round(bearing*16/360) mod 16) 
            case  0; put "N" into rVal;   break;
            case  1; put "NNE" into rVal; break;
            case  2; put "NE" into rVal;  break;
            case  3; put "ENE" into rVal; break;
            case  4; put "E" into rVal;   break;
            case  5; put "ESE" into rVal; break;
            case  6; put "SE" into rVal;  break;
            case  7; put "SSE" into rVal; break;
            case  8; put "S" into rVal;   break;
            case  9; put "SSW" into rVal; break;
            case 10; put "SW" into rVal;  break;
            case 11; put "WSW" into rVal; break;
            case 12; put "W" into rVal;   break;
            case 13; put "WNW" into rVal; break;
            case 14; put "NW" into rVal;  break;
            case 15; put "NNW" into rVal; break;
         end switch
         break
      default
         throw "Precision must be between 1 and 3"
   end switch
   return rVal;
end compassPoint                                             

function levDist pString1 pString2
   /* levDist Misc
   Syntax:
   levDist (pString1, pString2)
   Examples:
   levDist ("Mike", "Mikey")
   Description:
   "In information theory and computer science, the Levenshtein distance is 
   a string metric for measuring the difference between two sequences. Informally,
   the Levenshtein distance between two words is the minimum number of 
   single-character edits (i.e. insertions, deletions or substitutions) required to 
   change one word into the other." 
   
   extracted from http://en.wikipedia.org/wiki/Levenshtein_distance
   
   Source:
   RISHI GHOSH,  http://www.rghosh.com/code/levenshtein-distance-livecod/
   levDist */
   repeat with x = 1 to the number of chars in pString1
      put x into tDist[x][0]
      repeat with y = 1 to the number of chars in pString2
         put y into tDist[0][y]
         put 1 into tSubstitutionCost
         if char x of pString1 is char y of pString2 then 
            put 0 into tCost
         else 
            put tSubstitutionCost into tCost
         end if
         put min((tDist[x-1][y] + 1),(tDist[x][y-1] + 1),(tDist[x-1][y-1] + tCost)) into tDist[x][y]
      end repeat 
   end repeat
   return tDist[x][y]
end levDist

function ScriptOnly pStackName
   /* ScriptOnly Properties
   Syntax:
   ScriptOnly(stackName)
   Examples:
   if ScriptOnly("StackFoo")
   Description:
   This function checks the disc image of stack pStackName to see if
   this is a Script Only Stack.   It returns true if the first line of the stack
   script on disc is "script".
   Source:
   Michael Doub
   ScriptOnly */
   put the effective filename of stack pStackName into thePath
   open file thePath
   read from file thePath for 20
   if word 1 of it contains "script" then
      put true into rData
   else
      put false into rData
   end if
   close file thePath
   return rData
end ScriptOnly

function wordBounds input, word_index, line_index,@start_char, @end_char
   /* WordBounds Text
   Syntax:
   WordBounds (input, word_index, line_index,@start_char, @end_char)
   Examples:
   put empty into start_char
   put empty into end_char
   if WordBounds (input, word_index, line_index,@start_char, @end_char)
   Description:
   Returns true when the referenced word is found.   if true then the starting and 
   ending character of a word in a container given the line_index and word index 
   to the target word.   
   
   The line index is really the number of lines to skip, starting to look for the word.   
   The word can actually be on the following line if the index is larger than the 
   number of words in the line referenced
   
   Make sure that start_char and end_char are existing variables.  They will not be created.
   Source:
   Thierry Douez:    th.douez@sunny-tdz.com
   WordBounds */
   get format( "(?mx)(?: .*? \\n){%d}   (?: (\\w+) [\\W]*){%d}", line_index -1, word_index)
   return matchChunk( input,  it, start_char, end_char)
end WordBounds

function getColumns pData, pColNbrs, pDelim
   /* getColumns Table
   Syntax:
   getColumns (pData, pColNbrs, pDelim)
   Examples:
   getColumns (pData, "3-5", "|")
   getColumns (pData, "7,4-5,2,11-9")
   Description:
   Extract specified columns from a table in order
   .    pData: a tab-delimited table (delim may be overridden with pDelim)
   .    pColNbrs: A comma separated list of columns or column ranges
   .       to be returned in the order indicated, for example "2,7,5"
   .       or an ascending column range: "3-5"
   .       or a descending column range: "5-3"
   .       or a combination "7,4-5,2,11-9"
   Source:
   Peter M. Brigham
   getColumns */
   
   if pColNbrs = empty then return pData
   if pDelim = empty then put tab into pDelim
   -- first expand column ranges
   repeat for each item pCol in pColNbrs
      put offset("-",pCol) into dashPos
      if dashPos = 0 then
         put pCol & comma after tColsToReturn
      else if dashPos = 1 then
         -- for column numbers like -1, -2, etc.
         put howMany(pDelim,line 1 of pData) + 1 into nbrItems
         put pCol + 1 + nbrItems & comma after tColsToReturn
      else
         -- a column range
         put char 1 to dashPos-1 of pCol into firstColNbr
         put char dashPos+1 to -1 of pCol into lastColNbr
         if firstColNbr < lastColNbr then
            repeat with i = firstColNbr to lastColNbr
               put i & comma after tColsToReturn
            end repeat
         else
            repeat with i = firstColNbr down to lastColNbr
               put i & comma after tColsToReturn
            end repeat
         end if  
      end if       
   end repeat
   delete char -1 of tColsToReturn
   -- then extract columns in order
   set the columnDelimiter to pDelim
   split pData by column
   repeat for each item n in tColsToReturn
      add 1 to x
      put pData[n] into rData[x]
   end repeat
   combine rData by column
   return rData
end getColumns
 
function numToAccounting pNum, pDecimalSeparator, pThousandSeparator 
   /* numToAccounting Text
   Syntax:
   numToAccounting (pNum, [pDecimalSeparator], [pThousandSeparator])
   Examples:
   Put numToAccounting (pNum)
   Put numToAccounting (pNum,".")
   Put numToAccounting (pNum,".",",")
   Description:
   Purpose:    Converts a number to accounting format - 
   thousands separators with negative numbers in brackets
   (or parentheses depending from where one hails). 
   
   Inputs:
   .             pNum                	The number to be converted
   .             pDecimalSeparator   	The character to be used, default "."
   .             pThousandSeparator  	The character to be used, default ","
   Returns:                        	
   .            The number in accounting format rounded toplevel decimal places
   Source:
   Peter W A Wood
   numToAccounting */
   
   
   local tCount
   local tDecimalSeparator
   local tNum
   local tStart
   local tThousandSeparator
   
   # set the separators
   if pThousandSeparator is empty then
      put "," into tThousandSeparator
   else
      put pThousandSeparator into tThousandSeparator
   end if
   if pDecimalSeparator is empty then
      put "." into tDecimalSeparator
   else
      put pDecimalSeparator into tDecimalSeparator
   end if
   
   #format the numbers
   put format("%.2f", pNum) into tNum
   put tDecimalSeparator into char -3 of tNum
   put 0 into tCount
   put the length of tNum - 3 into tStart
   repeat with i = tStart down to 1
      add 1 to tCount
      if tCount = 4 then 
         if char i of tNum  = "-" then exit repeat
         put tThousandSeparator after char i of tNum
         put 1 into tCount
      end if
   end repeat
   if pNum < 0 then
      put "(" into character 1 of tNum
      put ")" after tNum
   end if
   return tNum 
end numToAccounting
 
function accountingToNum pNum
   /* accountingToNum Text
   Syntax:
   accountingToNum (pNum)
   Examples:
   put accountingToNum (pNum)
   Description:
   Converts a number in accounting format to an simple number
   Inputs:
   .    pNum      The number in accounting format to be converted
   Returns:           
   .                    The simple number
   Source:
   Peter W A Wood
   accountingToNum */
   
   local tNum
   
   if first character of pNum = "(" then put "-" into tNum
   repeat for each character digit in pNum
      if digit is a number then put digit after tNum
   end repeat
   put "." after character -3 of tNum
   
   return tNum 
   
end accountingToNum

function PointWithinGrc grcNbr, xyPoint
   /* PointWithinGrc Graphics
   Syntax:
   PointWithinGrc (jgraphic_id,xyPoint)
   Examples:
   if PointWithinGrc(grcNbr, the mouseLoc) 
   Description:
   Return true if the xyPoint is within the graphic grcNbr
   
   Source:
   from  stack #47 ("pointInShape") in forums.livecode.com/viewtopic.php?f=76&t=19248
   PointWithinGrc */
   if xyPoint is not within the rect of grc grcNbr then return false
   switch the style of grc grcNbr
      case "rectangle"
         return true -- (xyPoint is within the rect of grc grcNbr)
      case "regular" -- compute the points and use the polygon check below
         put the polysides of grc grcNbr into n0
         put (90+the angle of grc grcNbr) mod 360 into a0
         put 2*pi/n0 into c0; put empty into pnts
         put (the width of grc grcNbr) div 2 into r2; put (the height of grc grcNbr) div 2 into r1
         -- n0 vertices --> n0+1 points for a 'closed' polygon (first point=last point)
         put item 1 of the loc of grc grcNbr into lx; put item 2 of the loc of grc grcNbr into ly
         put empty into pnts
         if a0=0 then
            repeat with k=0 to n0
               put CR & (round(r2*sin(k*c0)+lx),round(-r1*cos(k*c0)+ly)) after pnts
            end repeat
            delete char 1 of pnts -- is CR
         else
            put sin(pi*a0/180) into s; put cos(pi*a0/180) into c 
            repeat with k=0 to n0
               put round( r1*sin(k*c0)) into sx; put round(-r2*cos(k*c0)) into sy
               put CR & ( (round(lx+c*sx-s*sy),round(ly+c*sy+s*sx)) ) after pnts
            end repeat
            delete char 1 of pnts -- is CR
         end if
         if conversioncheck then -- for testing only
            if there is a grc "temp" then delete grc "temp"
            if there is no grc "temp" then
               create grc "temp"
               set style of grc "temp" to "polygon"
            end if
            set points of grc "temp" to pnts
         end if
      case "curve" -- is too a polygon (diff to polygon is for manual drawing only)
      case "polygon"
         if pnts is empty then put the points of grc grcNbr into pnts
         put the number of lines of pnts into N
         put item 1 of xyPoint into x0; put item 2 of xyPoint into y0
         put false into chck; put N into j0
         ## ACKNOWLEDGEMENT:
         ## This is essentially the subdivison algorithm by MShimrat (Aug 1962).
         repeat with i=1 to N
            put item 1 of line i of pnts into x1; put item 2 of line i of pnts into y1
            put item 1 of line j0 of pnts into x2; put item 2 of line j0 of pnts into y2
            if ( ((y1 > y0) is not (y2 > y0)) and ( x0 < x1 + (x2-x1)*(y0-y1)/(y2-y1) ) )
            then put not chck into chck
            put i into j0
         end repeat
         return chck
      case "roundrect"
         put the rect of grc grcNbr into r
         put item 1 of xyPoint into x; put item 2 of xyPoint into y
         put item 1 of r into x1; put item 2 of r into y1
         put item 3 of r into x2; put item 4 of r into y2
         put the roundradius of grc grcNbr into d -- note: the "radius" is a diameter (!)
         -- roundrect "switches" to oval if roundradius is smaller than height and/or width
         put min(d,x2-x1) div 2 into w; put min(d,y2-y1) div 2 into h
         -- if we are in rect of the grc but not in its rounded corners:
         if (x1+w <= x and x <= x2-w) or (y1+h <= y and y <= y2-h) then return true
         -- now check all 4 rounded corners: topLeft,topRight,botRight,botLeft
         put (h*abs(x1 + w - x))^2 into dx1; put (h*abs(x2 - w - x))^2 into dx2
         put (w*abs(y1 + h - y))^2 into dy1; put (w*abs(y2 - h - y))^2 into dy2
         put (w*h)^2 into d0
         return (dx1+dy1 <= d0) or (dx2+dy1 <= d0) or (dx2+dy2 <= d0) or (dx1+dy2 <= d0)
      case "oval"
         put the loc of grc grcNbr into lc
         put the width of grc grcNbr into w; put the height of grc grcNbr into h
         put h*(item 1 of xyPoint - item 1 of lc) into d1
         put w*(item 2 of xyPoint - item 2 of lc) into d2
         put the arcangle of grc grcNbr into c2
         if c2 < 360 then
            put the startangle of grc grcNbr into c1; put (c1 + c2) into c2
            if d2 < 0 then put -atan2(d2,d1)*180/pi into c
            else put 360-atan2(d2,d1)*180/pi into c
            if c2 <= 360 then put ( c1 <= c ) and ( c <= c2 ) into cc
            else put ( c1 <= c ) or ( c <= c2-360) into cc
            return  (4*d1^2 + 4*d2^2 <= w^2*h^2) and cc
         else
            return  (4*d1^2 + 4*d2^2 <= w^2*h^2)
         end if
      case "line"
         put the points of grc grcNbr into pp
         put item 1 of line 1 of pp into x1; put item 2 of line 1 of pp into y1
         put item 1 of line 2 of pp into x2; put item 2 of line 2 of pp into y2
         put item 1 of xyPoint into x; put item 2 of xyPoint into y
         -- is (x,y) on the line, defined by (y-y1)*(x2-x1) = (x-x1)*(y2-y1)?
         -- admit deviations of click by 1 point:
         return abs( (y-y1)*(x2-x1) - (x-x1)*(y2-y1) ) < abs(x2-x1)+abs(y2-y1)
      default; return false
   end switch
end PointWithinGrc

function ArrayEncodeVersion pEncodedString 
   /* ArrayEncodeVersion Misc
   Syntax: 
   ArrayEncodeVersion(pEncodedString)
   Examples:
   put ArrayEncodeVersion(pEncodedString) into tVersion
   Description:
   This function will return the livecode version that created the array encoded string.
   The encoding format changed when UNICODE support was intruduced.  
   Input:  the encoded string
   Output: the version of the encoded string.  The know values are suitable for
   .            use in the encode function.   "6.7" and "7.0".
   .            "Unknown" is returned as the error case.
   Source:
   Michael Doub
   ArrayEncodeVersion */
   switch byteToNum(byte 1 of pEncodedString) 
      case 5 
         return "6.7" 
         break 
      case 6 
         return "7.0" 
         break 
      default 
         return "Unknown" 
   end switch 
end ArrayEncodeVersion 

function text_is_Caps pText
   /* text_is_Caps Misc
   Syntax:
   text_is_Caps (pText) 
   Examples:
   if text_is_Caps (pText) then beep
   Description:
   Returns true if pText is all CAPS
   Source:
   Malte Brill, revolution@derbrill.de
   text_is_Caps */
   set the caseSensitive to true
   return pText = toUpper(pText)
end text_is_Caps

function CSVtoArray2 pData
   /* CSVtoArray2 Table
   Syntax:
   CSVtoArray2 (pData)
   Examples:
   put CSVtoArray2 (csvtext) into pArray
   Description:
   converts csv text into an array
   
   it returns an array with two dimentions  [lineCounter][itemCounter]
   
   Source:
   by Peter M. Brigham, pmbrig@gmail.com
   CSVtoArray2 */
   /* Include
   howmany
   getDelimiters
   offsets
   */
   
   put getDelimiters(pData,5) into tDelims
   put line 1 of tDelims into crChar
   put line 2 of tDelims into tabChar
   put line 3 of tDelims into commaChar
   put line 4 of tDelims into openQuoteChar
   put line 5 of tDelims into closeQuoteChar
   
   replace crlf with cr in pData -- Win to UNIX
   replace numtochar(13) with cr in pData -- Mac to UNIX
   
   if howmany(quote,pData) mod 2 = 1 then
      return "This CSV data is not parsable (unclosed quotes in data)."
   end if
   
   put offsets(quote,pData) into qOffsets
   if qOffsets > 0 then
      put 1 into counter
      repeat for each item q in qOffsets
         if counter mod 2 = 1 then put openQuoteChar into char q of pData
         else put closeQuoteChar into char q of pData
         add 1 to counter
      end repeat
   end if
   
   put offsets(cr,pData) into crOffsets
   repeat for each item r in crOffsets
      put char 1 to r of pData into upToHere
      if howmany(openQuoteChar,upToHere) <> howmany(closeQuoteChar,upToHere) then
         -- the cr is within a quoted string
         put crChar into char r of pData
      end if
   end repeat
   put offsets(tab,pData) into tabOffsets
   repeat for each item t in tabOffsets
      put char 1 to t of pData into upToHere
      if howmany(openQuoteChar,upToHere) <> howmany(closeQuoteChar,upToHere) then
         -- the tab is within a quoted string
         put tabChar into char t of pData
      end if
   end repeat
   put offsets(comma,pData) into commaOffsets
   repeat for each item c in commaOffsets
      put char 1 to c of pData into upToHere
      if howmany(openQuoteChar,upToHere) <> howmany(closeQuoteChar,upToHere) then
         -- the comma is within a quoted string
         put commaChar into char c of pData
      end if
   end repeat
   put 0 into lineCounter
   repeat for each line L in pData
      add 1 to lineCounter
      put 0 into itemCounter
      repeat for each item i in L
         add 1 to itemCounter
         put i into thisItem
         if howmany(openQuoteChar,thisItem) <> howmany(closeQuoteChar,thisItem) then
            return "This CSV data is not parsable (unclosed quotes in item)."
         end if
         replace crChar with cr in thisItem
         replace tabChar with tab in thisItem
         replace commaChar with comma in thisItem
         replace openQuoteChar with quote in thisItem
         replace closeQuoteChar with quote in thisItem
         put thisItem into A[lineCounter][itemCounter]
      end repeat
   end repeat
   return A
end CSVtoArray2

function directoryListing whatFolder,c
   /* directoryListing File
   Syntax:
   directoryListing (whatFolder,c)
   Examples:
   put directoryListing(whatFolder)
   put directoryListing(whatForder,5)
   Description:
   Returns a listing of directories and files in the specified folder to a 
   specified depth sub directories.  if c is positive, then c is the depth 
   of sub directories to traverse.  If c is empty or <= 0 then all levels of
   sub directories are traversed.
   
   if c=1, then only the directory whatFolder is returned
   if c=2, then the directory whatFolder and any files or directorys within
   whatFolder are returned.
   
   Source:
   Geoff Canyon  gcanyon@gmail.com   Adapted by Michael Doub
   directoryListing */
   if char -1 of whatFolder <> "/" then put "/" after whatFolder
   put whatFolder & cr into R
   set the directory to whatFolder
   if c = 1 or the result is not empty then return R
   put the files into tFileList
   sort tFileList
   replace cr with cr & whatFolder in tFileList
   put whatFolder & tFileList & cr after R
   put line 2 to -1 of the folders into tDirList
   sort tDirList
   repeat for each line L in tDirList
      put directoryListing((whatFolder & L),(c-1)) after R
   end repeat
   return R
end directoryListing


function CSVToTab pData, pOldLineDelim, pOldItemDelim, pNewCR, pNewTAB
   /* CSVToTab Table
   Syntax:
   CSVToTab (pData,pcoldelim)
   Examples:
   put CSVToTab (pData) into table
   put CSVToTab (pData,",") into table
   put CSVToTab (pData,"|") into table
   Description:
   Converts CSV into tab delimited.  Where pcoldelim is the column delimiter.
   pcoldelim defaults to comma
   Source:
   Mike Kerner , MikeKerner@roadrunner.com 
   CSVToTab */
   
   
   -- v 3 -> 4   put back in replace TAB with pNewTAB in 'passedquote'
   -- v 4 -> 5   put in the two replace statements in the trailing empty case
      -- fill in defaults
      if pOldLineDelim is empty then put CR into pOldLineDelim
      if pOldItemDelim is empty then put COMMA into pOldItemDelim
      if pNewCR is empty then put numtochar(11) into pNewCR   -- Use <VT> for quoted CRs
      if pNewTAB is empty then put numtochar(29) into pNewTAB      -- Use <GS> (group separator) for quoted TABs

      local tNuData                         -- contains tabbed copy of data

      local tStatus, theInsideStringSoFar

      -- Normalize line endings: REMOVED
      -- Will normaly be correct already, only binfile: or similar chould make this necessary
      -- and that exceptional case should be the caller's responsibility

      put "outside" into tStatus
      set the itemdel to quote
      repeat for each item k in pData
            -- put tStatus && k & CR after msg
            switch tStatus

                  case "inside"
                        put k after theInsideStringSoFar
                        put "passedquote" into tStatus
                        next repeat

                  case "passedquote"
                        -- decide if it was a duplicated escapedQuote or a closing quote
                        if k is empty then   -- it's a duplicated quote
                              put quote after theInsideStringSoFar
                              put "inside" into tStatus
                              next repeat
                        end if
                        -- not empty - so we remain inside the cell, though we have left the quoted section
                        -- NB this allows for quoted sub-strings within the cell content !!
                        replace pOldLineDelim with pNewCR in theInsideStringSoFar
                        replace TAB with pNewTAB in theInsideStringSoFar
                        put theInsideStringSoFar after tNuData

                  case "outside"
                        replace pOldItemDelim with TAB in k
                        -- and deal with the "empty trailing item" issue in Livecode
                        replace (pNewTAB & pOldLineDelim) with pNewTAB & pNewTAB & CR in k
                        put k after tNuData
                        put "inside" into tStatus
                        put empty into theInsideStringSoFar
                        next repeat
                  default
                        put "defaulted"
                        break
            end switch
      end repeat

      -- and finally deal with the trailing item isse in input data
      -- i.e. the very last char is a quote, so there is no trigger to flush the
      --      last item
      if the last char of pData = quote then
                  replace pOldLineDelim with pNewCR in theInsideStringSoFar
                  replace TAB with pNewTAB in theInsideStringSoFar
            put theInsideStringSoFar after tNuData
      end if

      return tNuData
end CSVToTab

function bAdd x,y
   /* bAdd Math
   Syntax:
   bAdd (x,y)
   Examples:
   put bAdd (x,y) into thesum
   Description:
   Large Integer Add function - returns the sum of x and y
   Source:
   Geoff Canyon <gcanyon@gmail.com>
   bAdd */
   if char 1 of x is "-" then
      delete char 1 of x
      if char 1 of y is "-" then
         delete char 1 of y
         put "-" into theSign
      else
         return bSubtract(y,x)
      end if
   else
      if char 1 of y is "-" then
         delete char 1 of y
         return bSubtract(x,y)
      else
         put empty into theSign
      end if
   end if
   put length(x) into lenX
   put length(y) into lenY
   if lenX > lenY then
      put x into r
      put lenX into lenR
   else
      put y into r
      put lenY into lenR
      put x into y
      put lenX into lenY
   end if
   put 0 into c
   repeat with i = 14 to lenR step 14
      add char -i to 13 - i of r + char -i to 13 - i of y to c
      put char -14 to -1 of ("00000000000000" & c) into char -i to 13 - i of r
      delete char -14 to -1 of c
      if i > lenY and c is empty then exit repeat
   end repeat
   put c before r
   put 0 + char 1 to 14 of r into char 1 to 14 of r
   return theSign & r
end bAdd

function bSubtract x,y
   /* bSubtract Math
   Syntax:
   bSubtract (x,y)
   Examples:
   put  bSubtract (x,y) into thedifference
   Description:
   Large Integer Subtraction function - returns the difference of x from y
Source:
Geoff Canyon <gcanyon@gmail.com>
bSubtract */
   if char 1 of x is "-" then
      if char 1 of y is "-" then
         delete char 1 of x
         delete char 1 of y
         put "-" into theSign
      else
         return bAdd(x,"-" & y)
      end if
   else
      if char 1 of y is "-" then
         return bAdd(x,char 2 to -1 of y)
      else
         put empty into theSign
      end if
   end if
   put length(x) into lenX
   put length(y) into lenY
   if lenX > lenY then
      put x into r
      put lenX into lenR
   else if lenX < lenY then
      if theSign is "-" then put empty into theSign else put "-" into theSign
      put y into r
      put lenY into lenR
      put x into y
      put lenX into lenY
   else
      get bCompare(x,y)
      if it is "greater" then
         put x into r
         put lenX into lenR
      else if it is "less" then
         if theSign is "-" then put empty into theSign else put "-" into theSign
         put y into r
         put lenY into lenR
         put x into y
         put lenX into lenY
      else
         return 0
      end if
   end if
   put 0 into c
   repeat with i = 14 to lenR step 14
      put char -i to 13 - i of r into s
      add char -i to 13 - i of y to c
      if s >= c then
         put s - c into s
         put 0 into c
      else
         put ("1" & s) - c into s
         put 1 into c
      end if
      put char -14 to -1 of ("00000000000000" & s) into char -i to 13 - i of r
      if i > lenY and c = 0 then exit repeat
   end repeat
   put 0 + char 1 to 15 of r into char 1 to 15 of r
   return theSign & r
end bSubtract

function bTimes X,Y
   /* bTimes Math
   Syntax:
   bTimes (X,Y)
   Examples:
   put  bTimes (X,Y) into theproduct
   Description:
   Large Integer Multiplication function - returns the product of x and y
   Source:
   Geoff Canyon <gcanyon@gmail.com>
   bTimes */
   if X = 0 or Y = 0 then return 0
   if char 1 of X is "-" then
      put "-" into leadChar
      delete char 1 of X
   end if
   if char 1 of Y is "-"  then
      if leadChar is "-" then put empty into leadChar else put "-" into leadChar
      delete char 1 of Y
   end if
   put X & Y into R
   put "0000000000000000" into char 1 to 10 of R
   put (6 + length(X)) div 7 * 7 into XL
   put char 1 to XL - length(X) of "000000" before X
   put (6 + length(Y)) div 7 * 7 into YL
   put char 1 to YL - length(Y) of "000000" before Y
   put length(R) - 6 into rStart
   repeat with N = XL + YL down to 15 step -7
      put min(XL,N - 7) into finalM
      put 0 into C
      repeat with startM = max(7,N - YL) to finalM - 7 step 630
         repeat with M = startM to min(startM + 623,finalM) step 7
            add (char M - 6 to M of X) * (char N - M - 6 to N - M of Y) to S
         end repeat
         add char 1 to -8 of S to C
         delete char 1 to -8 of S
      end repeat
      put char -7 to -1 of ("000000" & S) into char rStart to rStart + 6 of R
      subtract 7 from rStart
      put C into S
   end repeat
   if S > 0 then put S into char max(1,rStart) to rStart + 6 of R
   put 0 into zR
   repeat until zR > 0
      put 0 + char 1 to 15 of R into zR
      put zR into char 1 to 15 of R
   end repeat
   return leadChar & R
end bTimes


function bCompare x,y -- only works on unsigned values
   /* bCompare Math
   Syntax:
   bCompare (x,y)
   Examples:
   bCompare x,y
   Description:
   Compares two unsigned values.  x to y
   Returns:
   .       "greater" if x > y
   .       "less" if x < y
   .       "equal" if x = y
   Source:
   Geoff Canyon <gcanyon@gmail.com>
   bCompare */
   put length(x) into lenX
   put length(y) into lenY
   if lenX > lenY then return "greater"
   if lenX < lenY then return "less"
   repeat with i = 1 to lenX step 14
      put char i to i + 13 of x into x1
      put char i to i + 13 of y into y1
      if x1 > y1 then return "greater"
      if x1 < y1 then return "less"
   end repeat
   return "equal"
end bCompare

function resizeImageFile pFile, pOutFile, pMaxWid, pMaxHeight 
/* resizeImageFile Image
Syntax: resizeImageFile (pFile, pOutFile, pMaxWid, pMaxHeight)
Examples:  resizeImageFile (pFile, pOutFile, pMaxWid, pMaxHeight)
Description:
Imports an image pFile, resizes it proportionally using the maxWidth 
and maxHeight parameters, then saves the resized image to pOutFile
Source:
resizeImageFile */
/* Include
setAreaProportional
*/
   local t, tt 

   import paint from file pFile 
   put the name of the last image into t 
   set the name of t to "Im1" 

   clone img "Im1" 
   set the name of it to "Im2" 
   setAreaProportional the long id of img "Im2", pMaxWid, pMaxHeight 
   export img "Im2" to file pOutFile as jpeg 
   put the result into tt 

   delete img "Im2" 
   delete img "Im1" 

   return empty      -- "Done resize" & ":" & tt & ":" && pFile && pOutfile 
end resizeImageFile 


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


---- Put Your Routines below this Point -----
---- If you send your version of the stack me at mike@doub.com
---- I will inlude them in the next update if a duplicate function has not
---- already been included.
