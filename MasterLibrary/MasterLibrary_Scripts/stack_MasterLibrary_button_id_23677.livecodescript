Script "stack_MasterLibrary_button_id_23677"

/*
# Name: button "Test" of card "LibMgr" of stack "MasterLibrary"
# ID: button id 23677 of card id 23690 of stack "MasterLibrary"
*/


local putit = true

on mouseUp
   testMasterLibrary
end mouseUp


on testMasterLibrary
   put buildlist(the short name of this stack) into MasterList
   put empty into msg
   if the optionKey is down then
      put empty into newlist
      repeat for each line test in masterlist
         put "on" && "test_" & test & cr & cr & "end" && "test_" & test & cr & cr & cr after newlist
      end repeat
      set the clipboardData["text"] to newlist
      exit to top
   end if
   repeat for each line test in masterlist
      put cr & "test_" & test into it
      try
         put test & cr after msg
         do it
      catch the_error
         if isnumber(item 1 of the_error) then
            dispatch function "expandError" to btn "Lib" of cd "LibMgr" with the_error
            if it = "handled" then
               put the result into expandedError
            else
               put it & cr & theError into expandedError
            end if
            put  expandedError & cr after msg
         else
            put "ERROR" && the_error & cr after msg
         end if
      end try
   end repeat
end testMasterLibrary


on test x y
   if x =  y then
      if putit then
         put x & cr after msg
      end if
   else
      throw x
   end if
end test

on test_q
   test q("hello"), (quote & "hello" & quote)
end test_q

on test_qq
   test qq("'hello'"), (quote & "hello" & quote)
end test_qq

on test_IfX
-- can't automate testing
end test_IfX

on test_deleteColumns
   put "1A" & tab & "1B" & tab &"1C" & cr & "2A" & tab & "2B" & tab & "2C" & cr  into x
   test deleteColumns(x,"1,3") , ("1B" & cr & "2B" & cr )
   put "1A" & tab & "1B" & tab &"1C" & cr & "2A" & tab & "2B" & tab & "2C" & cr  into x
   test deleteColumns(x,"1-2") , ("1C" & cr & "2C" & cr )
   put "1A" & "^" & "1B" & "^" &"1C" & cr & "2A" & "^" & "2B" & "^" & "2C" & cr  into x
   test deleteColumns(x,"1,3","^") , ("1B" & cr & "2B" & cr )
   put "1A^1B^1C^1D^1E^1F" & cr & "2A^2B^2C^2D^2E^2F" & cr  into x
   if deleteColumns(x,"1,2-3,4,5","^") <> "1F" & cr & "2F" & cr then throw "problem with multicase"
end test_deleteColumns

on test_getItem
   test  getItem("a,b,c,d,e,f",4,",") , "d" 
   test getItem("a//b//c//d//e//f",4,"//") , "d"
end test_getItem

on test_CSVtoArray
   put quote & "1A" & quote & comma &"1B,1C" & cr & \
         quote & "2A" & quote & comma &"2B,2C" & cr into x
   put CSVtoArray(x) into tA
   if tA[1][1] <> "1A" or tA[1][2] <> "1B" or tA[1][3] <> "1C" or \
         tA[2][1] <> "2A" or tA[2][2] <> "2B" or tA[2][3] <> "2C" then \
         throw "problem with CVS no title"
   put "A,B,C" & cr & "1,2,3" into x
   put CSVtoArray(x,true) into tA
   if tA[1]["A"] <> 1 or tA[1]["B"] <> 2 or tA[1]["C"] <> 3 then \ 
          throw "problem with CVS title"
end test_CSVtoArray

on test_init_Pi_gpio
-- can only test on a Pi
end test_init_Pi_gpio

on test_Pi_gpio_output
-- can only test on a Pi
end test_Pi_gpio_output

on test_Pi_gpio_input
-- can only test on a Pi
end test_Pi_gpio_input

on test_StripDupes
   repeat with i = 1 to 4
      put "test" && i & cr after x
      put "test" && i & cr after x
   end repeat
   put StripDupes(x) into y
   if the number of lines in y <> 4 then throw "bad line count"
end test_StripDupes

on test_isEmail
   test isEmail("ken.ray@test.com") , true 
    test isEmail("ken.ray@testcom") , false 
end test_isEmail

on test_getNestedItems
   put "aaa,bbb,ccc#ddd#eee#fff,ggg,hhh" into theData
   test getNestedItems(theData,3,comma,2,"#") , "ddd" 
end test_getNestedItems

on test__switch
   test _Switch("Ken","Ken=male","Richard=male","Carol=female") , "male" 
end test__switch

on test_lastItem
   test lastItem ("this,is,a,test",comma) , "test" 
   test lastItem ("/user/test/file.txt") , "file.txt" 
end test_lastItem

on test_isWinNT
 -- test on platform
end test_isWinNT

on test_isOSX
 -- test on platform
end test_isOSX

on test_getCol
   put "1A" & tab & "1B" & tab &"1C" & cr & "2A" & tab & "2B" & tab & "2C" & cr  into x
   if getCol(x,2) <> "1B" & cr & "2B" & cr then throw "problem with no delim"
   put "1A" & comma & "1B" & comma & "1C" & cr & "2A" & comma & "2B" & comma & "2C" & cr  into x
   if getCol(x,3,,comma) <> "1C" & cr & "2C" & cr then throw "problem with delim"
   put "1A" & tab & "1B" & tab &"1C" & cr & "2A" & tab & "2B" & tab & "2C" & cr  into x
   if getCol(x,1,2) <> "1A" & tab &"1B" & cr & "2A" & tab & "2B" & cr then throw "problem with range"
end test_getCol

on test_AppPath
if  putit then put AppPath() & cr after msg
end test_AppPath

on test_append
   put "A" & cr & "B" & cr into x
   append "C",x
   test x, ("A" & cr & B & cr & "C" )
   put "A,B" into x
   append "C", x, "item"
   test x , ("A,B,C") 
end test_append

on test_ccValidate
   ccvalidate "1111,2222,3333,4444",cType,cVal
end test_ccValidate

on test_PausePending
   PausePending
   ResumePending
end test_PausePending

on test_ResumePending
   ResumePending
end test_ResumePending

on test_cancelPending
   CancelPending
end test_cancelPending

on test_Clip
   test Clip(10,101,100) , 100 
    test Clip(10,9,100) , 10 
end test_Clip

on test_isPosInteger
   test isPosInteger(1) , true 
   test isPosInteger(15,10,20) , true 
   test isPosInteger(0,,true) , true 
end test_isPosInteger

on test_jsonFormat
   put the json_unformatted of this card into x
   put the json_formatted of this card into y
   put jsonFormat (x) into z
   if y<>z then throw "Mismatch"
end test_jsonFormat

on test_jsonToarray
   put the json_unformatted of this card into x
   get jsonToArray(x)
   put arrayToJson(it) into y
   if x<>y then throw "Array Issue"
end test_jsonToarray

on test_arrayToJson
   put the json_unformatted of this card into x
   get jsonToArray(x)
   put arrayToJson(it) into y
   if x<>y then throw "Array Issue"
end test_arrayToJson

on test_isConnectedToInternet
   get isConnectedToInternet ()
   if it is not among the items "true,false" then throw "We have a problem"
end test_isConnectedToInternet

on test_setAreaProportional
--visual test
end test_setAreaProportional

on test_setProportional
--visual test
end test_setProportional

on test_isImage
   put the short name of the defaultstack into tStack
   put the effective filename of stack tStack into tPath
   test isImage(tPath) , "false" 
end test_isImage

on test_getPixel
--visual test
end test_getPixel

on test_setHeightProportional
--visual test
end test_setHeightProportional

on test_setImage
--visual test
end test_setImage

on test_setWidthProportional
--visual test
end test_setWidthProportional

on test_AssetType
   put the short name of the defaultstack into tStack
   put the effective filename of stack tStack into tPath
   test AssetType(tPath) , "unknown" 
end test_AssetType

on test_centerOfRect
 test centerofRect ("0,0,100,100") , "50,50" 
end test_centerOfRect

on test_FileInfo
   put the short name of the defaultstack into tStack
   put the effective filename of stack tStack into tPath
   test  fileInfo(tPath,"filename") , "MasterLibrary.livecode" 
end test_FileInfo

on test_walkDir
-- cant test automatically
end test_walkDir

on test_GetExtension
   put the short name of the defaultstack into tStack
   put the effective filename of stack tStack into tPath
   test GetExtension(tPath) , "livecode" 
end test_GetExtension

on test_isMovie
 put the short name of the defaultstack into tStack
   put the effective filename of stack tStack into tPath
   test isMovie(tPath) , "false" 
end test_isMovie

on test_Pack
   put pack("hello world", "doit4fun") into x
   put unpack(x, "doit4fun") into y
   if y <> "hello world" then throw "Wrong Answer with password"
    put pack("hello world") into x
   put unpack(x) into y
   if y <> "hello world" then throw "Wrong Answer"
end test_Pack

on test_Unpack
  put pack("hello world", "doit4fun") into x
   put unpack(x, "doit4fun") into y
   if y <> "hello world" then throw "Wrong Answer with password"
    put pack("hello world") into x
   put unpack(x) into y
   if y <> "hello world" then throw "Wrong Answer"
end test_Unpack

on test_isDate
   test isDate("10/10/2014") , true 
   test isDate("10-10-10") , false 
end test_isDate

on test_dateOfEaster
   test dateOfEaster(2000) , "4/23/2000" 
end test_dateOfEaster

on test_DateOffset
test dateOffset("1/1/2000",7) , "1/8/2000" 
end test_DateOffset

on test_dateTimeToJulian
   test dateTimeToJulian(2004,3,22) , 2453086.5 
end test_dateTimeToJulian

on test_dayInYear
 test dayInYear("12/31/2004") , 366 
end test_dayInYear

on test_dayName
   test dayName("9/30/2020") , "Wednesday" 
end test_dayName

on test_daysBetween
   test daysBetween("1/1/2002", "1/1/2003") , 365 
end test_daysBetween

on test_daysInMonth
   test daysInMonth("Dec") , 31 
end test_daysInMonth

on test_doAge
   test  doAge ("8/20/1952","1/1/2015") , 62  
end test_doAge

on test_englishToSQLdate
test englishToSQLdate("6/3/09") , "2009-06-03"  
end test_englishToSQLdate

on test_englishToSystemDate
test englishToSystemDate("12/31/2003") , "12/31/03"  
end test_englishToSystemDate

on test_FromDayNum
   test FromDayNum("735540") , "1/2/2014"  
end test_FromDayNum

on test_isLeapYear
   test isLeapYear(2000) , true 
   test isLeapYear(2001) , false 
end test_isLeapYear

on test_JulianToDateTime
   test  JulianToDateTime(2453086.5) , "3/22/2004" 
end test_JulianToDateTime

on test_militaryClock
   get militaryClock()
   if it is among the items "AM,PM" then throw it
end test_militaryClock

on test_monthName
   test monthName(7) , "July" 
end test_monthName

on test_monthNum
test monthNum("Dec") , 12 
end test_monthNum

on test_monthNumber
   test monthNumber("12/31/2004") , 24061 
end test_monthNumber

on test_numericDate
   test numericDate("12/31/03") , "20031231"  
end test_numericDate

on test_PadShortDate
   test PadShortDate("1/3/13") , "01/03/13" 
end test_PadShortDate

on test_relativeDate
   test relativeDate(2, "Sunday", 5, "2002") , "5/12/2002" 
end test_relativeDate

on test_SQLToEnglishDate
   test SQLToEnglishDate("2009-08-30") , "8/30/09" 
end test_SQLToEnglishDate

on test_systemToEnglishDate

end test_systemToEnglishDate

on test_timeStamp
   test timeStamp(1249865187) , "20090809204627"  
end test_timeStamp

on test_timeStampToSeconds
   test  timeStampToSeconds(20090810104945) , "1249915785" 
end test_timeStampToSeconds

on test_timeStampToShortDate
   test  timeStampToShortDate(20090810104945) , "8/10/09" 
end test_timeStampToShortDate

on test_timeStampToShortTime
   test timeStampToShortTime(20060630140000) , "2:00 pm" 
end test_timeStampToShortTime

on test_timeZone

end test_timeZone

on test_titleCase
   test  titleCase("wednesday") , "Wednesday" 
end test_titleCase

on test_toDayNum
   test toDayNum("12/31/2004") , 732079  
end test_toDayNum

on test_totalDaysInYear
test totalDaysInYear(2001) , 365 
end test_totalDaysInYear

on test_twelveHourClock

end test_twelveHourClock

on test_weekNum
   test  weekNum("12/31/2002") , 53  
end test_weekNum

on test_weekNumISO
   test weekNumISO("12/31/2000", "Sunday") , 53 
end test_weekNumISO

on test_yearNum
   test yearNum("6/3/03") , 2003  
end test_yearNum

on test_FLCcalendar
   if putit then put FLCcalendar(1,10,2014) & cr after msg
end test_FLCcalendar

on test_FormatMoney
    if FormatMoney(10000000.00) <> "$10,000,000.00" then throw "problem"
end test_FormatMoney
   
on test_createPath
   
end test_createPath

on test_CSVtoTab
   put quote & "1A" & quote & comma &"1B,1C" & cr & \
         quote & "2A" & quote & comma &"2B,2C" & cr into x
   if CSVtoTab(x) <> "1A" & tab & "1B" & tab & "1C" & cr & \
          "2A" & tab & "2B" & tab & "2C" & cr then throw "problem"
end test_CSVtoTab

on test_DeleteCustomPropertyFromSet
   put long name of this stack into theobject
   set the customPropertySet of theobject to "MySet"
   set the pTest of theobject to "hello"
   DeleteCustomPropertyFromSet theobject, "MySet", "pTest"
   get the customkeys of theobject
   if "pTest" is among the lines of it then throw "problem"
   get the customPropertySets of theobject
      set the wholeMatches to true
      delete line lineOffset("MySet",it) of it
      set the customPropertySets of theobject to it
end test_DeleteCustomPropertyFromSet

on test_DeleteCustomPropertySet
    put long name of this stack into theobject
   set the customPropertySet of theobject to "MySet"
   set the pTest of theobject to "hello"
   DeleteCustomPropertySet theobject, "MySet"
   get the customPropertySets of theobject 
   set the wholeMatches to true
   if "MySet" is among the lines of it then throw "problem"
end test_DeleteCustomPropertySet

on test_downloadSaveNGo
   
end test_downloadSaveNGo

on test_offsets
   put "Hello World" & cr & "World of Goo" & cr & "GoodBye Cruel World" & cr into x
  test offsets("World",x) , "7,13,40" 
end test_offsets

on test_lineoffsets
    put "Hello World" & cr & "World of Goo" & cr & "GoodBye Cruel World" & cr into x
   test lineoffsets("World",x) , "1,2,3" 
end test_lineoffsets

on test_wordoffsets
   put "Hello World" & cr & "World of Goo" & cr &"GoodBye Cruel World" & cr into x
   test wordoffsets("World",x) , "2,3,8"
end test_wordoffsets

on test_itemoffsets
   put "Hello World" & comma & "World of Goo" & comma & "GoodBye Cruel World" & cr into x
   test itemoffsets("World",x) , "1,2,3" 
    put "Hello World" & tab & "World of Goo" & tab & "GoodBye Cruel World" & cr into x
   test itemoffsets("World",x,tab) , "1,2,3" 
end test_itemoffsets

on test__Floor
   test _Floor(1.1) , 1 
   test _Floor(1) , 1 
end test__Floor

on test__Ceiling
   test _Ceiling(1.1) , 2 
   test _Ceiling(1) , 1 
end test__Ceiling

on test_Hex
   test Hex(0) , "00" 
   test Hex(255) , "FF" 
end test_Hex

on test_html2text
   
end test_html2text

on test_getTaggedList
   put "<s>1</s><s>2</s><s>3</s>" into x
   put getTaggedList("<s>","</s>",x) into y
   if y[1]<> 1 or y[2]<>2 or y[3] <> 3 then throw error
end test_getTaggedList

on test_getTaggedElement
   put "<s>1</s><s>2</s><s>3</s>" into x
   put getTaggedElement("<s>","</s>",x) into y
   if y <> 1 then throw error
end test_getTaggedElement

on test_PrintKeys
       put 1 into test[1]
      put 2 into test[2]
      put 11 into test[1][1]
      put 22 into test[2][2]
      put 333 into test[3][3][3]
      get PrintKeys(test)
      if putit then put it & cr after msg
end test_PrintKeys

on test_withinTriangle
   test withinTriangle(0,0,0,20,10,10,5,5) , true 
   test withinTriangle(0,0,0,20,10,10,30,30) , false 
end test_withinTriangle

on test_analogous
   get  analogous("127,55,0")
   if putit then put it & cr after msg
end test_analogous

on test_Complement
   get Complement("127,55,0")
   if putit then put it & cr after msg
end test_Complement

on test_DeltaC
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaC(Lab1,Lab2)
   if putit then put it & cr after msg
end test_DeltaC

on test_deltaCMC
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaCMC(Lab1,Lab2)
   if putit then put it & cr after msg
end test_deltaCMC

on test_DeltaE
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaE(Lab1,Lab2)
   if putit then put it & cr after msg
end test_DeltaE

on test_DeltaE1994
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaE1994(Lab1,Lab2)
   if putit then put it & cr after msg
end test_DeltaE1994

on test_DeltaE2000
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaE2000(Lab1,Lab2)
   if putit then put it & cr after msg
end test_DeltaE2000

on test_DeltaH
   put "32.356945,28.536943,43.415358" into Lab1
   put "23.068704,0.001781,-0.003506" into Lab2
   get DeltaH(Lab1,Lab2)
   if putit then put it & cr after msg
end test_DeltaH

on test_Harmony
   get Harmony("127,55,0",90)
   if putit then put it & cr after msg
end test_Harmony

on test_HSLtoRGB
   get HSLtoRGB("0,0,0.215686")
   if putit then put it & cr after msg
end test_HSLtoRGB

on test_LABtoLCH
   put "32.356945,28.536943,43.415358" into Lab1
   get LABtoLCH(Lab1)
   if putit then put it & cr after msg
end test_LABtoLCH

on test_LABtoRGB
   put "32.356945,28.536943,43.415358" into Lab1
   get LABtoRGB(Lab1)
   if putit then put it & cr after msg
end test_LABtoRGB

on test_LabtoXYZ
   put "32.356945,28.536943,43.415358" into Lab1
   get LABtoXYZ(Lab1)
   if putit then put it & cr after msg
end test_LabtoXYZ

on test_LCHtoLAB
   put "32.356945,51.954311,56.683055" into LCH
   get LCHtoLAB(LCH)
   if putit then put it & cr after msg
end test_LCHtoLAB

on test_RGBtoHSL
   get RGBtoHSL("55,55,55")
   if putit then put it & cr after msg
end test_RGBtoHSL

on test_RGBtoHSV
   get RGBToHSV("55,55,55")
   if putit then put it & cr after msg
end test_RGBtoHSV

on test_RGBtoLab
   get RGBToLab("55,55,55")
   if putit then put it & cr after msg
end test_RGBtoLab

on test_RGBtoXYZ
   get RGBToXYZ("55,55,55")
   if putit then put it & cr after msg
end test_RGBtoXYZ

on test_splitcom
   get splitcom("55,55,55")
   if putit then put it & cr after msg
end test_splitcom

on test_triadic
   get triadic("55,55,55")
   if putit then put it & cr after msg
end test_triadic

on test_XYZtoLab
   put "3.631326,3.820437,4.160456" into XYZ
   get XYZtoLab(XYZ)
   if putit then put it & cr after msg
end test_XYZtoLab

on test_XYZtoRGB
   put "3.631326,3.820437,4.160456" into XYZ
   get XYZtoRGB(XYZ)
   if putit then put it & cr after msg
end test_XYZtoRGB

on test_XYZtoYxy
   put "3.631326,3.820437,4.160456" into XYZ
   get XYZtoYxy(XYZ)
   if putit then put it & cr after msg
end test_XYZtoYxy

   on test_YxyToXYZ
      put "3.820437,0.312716,0.329001" into Yxy
      get YxyToXYZ(Yxy)
      if putit then put it & cr after msg
end test_YxyToXYZ

on test_iff
   test iff(1 < 2,"got it","Wrong answer") , "got it" 
end test_iff

on test_CardOf
   get  CardOf(the target)
    if putit then put it & cr after msg
end test_CardOf


on test_currentCardOf
   get currentCardOf (the target)
    if putit then put it & cr after msg
end test_currentCardOf


on test_MainStackOf
   get MainStackOf(the target)
    if putit then put it & cr after msg
end test_MainStackOf


on test_myCard
   get myCard()
    if putit then put it & cr after msg
end test_myCard


on test_myCurrentCard
   get myCurrentCard()
    if putit then put it & cr after msg
end test_myCurrentCard


on test_myMainStack
   get myMainStack()
    if putit then put it & cr after msg
end test_myMainStack


on test_myOwner
   get myOwner()
    if putit then put it & cr after msg
end test_myOwner


on test_myStack
   get myStack()
    if putit then put it & cr after msg
end test_myStack


on test_OwnerOf
   get OwnerOf(the target)
   if putit then put it & cr after msg
end test_OwnerOf


on test_StackOf
   get StackOf(the target)
    if putit then put it & cr after msg
end test_StackOf

on test_fldExtract

end test_fldExtract

on test_fldPopulate

end test_fldPopulate

on test_extractLines
   repeat with i = 1 to 5
      put i & cr after LL
   end repeat
   test extractLines ("2,4",LL) , ("2" & cr & "4" )
end test_extractLines

on test_removeLines
 repeat with i = 1 to 5
      put i & cr after LL
   end repeat
   test removeLines ("2,4,5",LL) , ("1" & cr & "3" )
end test_removeLines

on test_removeLinesInPlace
   repeat with i = 1 to 5
      put i & cr after LL
   end repeat
  removeLinesInPlace "2,4,5",LL
      test LL , ("1" & cr & "3" & cr) 
end test_removeLinesInPlace

on test_saveStackRequest
   
end test_saveStackRequest

on test_PrintArray
   put 1 into test[1]
   put 2 into test[2]
   put 11 into test[1][1]
   put 22 into test[2][2]
   put 333 into test[3][3][3]
   get PrintArray(test)
   if putit then put it & cr after msg
end test_PrintArray

on test_DefineQuickFiles
   DefineQuickFiles "settings", "mySetting.settings"
   DefineQuickFiles "myData", "myData.data", "perm", "Resources/Database"
end test_DefineQuickFiles

on test_LoadQuickFile
    DefineQuickFiles "settings", "mySetting.settings"
    DefineQuickFiles "myData", "myData.data", "perm", "Resources/Database"
    LoadQuickFile "settings", t1
    LoadQuickFile "myData", t2
end test_LoadQuickFile

on test_SaveQuickFile
   DefineQuickFiles "settings", "mySetting.settings"
   DefineQuickFiles "myData", "myData.data", "perm", "Resources/Database"
   put "hello" into t1[1]
   put "goodbye" into t2[2]
   SaveQuickFile "settings", t1
   SaveQuickFile "myData", t2
   put empty into t1
   put empty into t2
   LoadQuickFile "settings", t1
   LoadQuickFile "myData", t2
   if t1[1] <> "hello" or t2[2] <> "goodbye" then throw "problem"
end test_SaveQuickFile

on test_deleteQuickFile
    DefineQuickFiles "settings", "mySetting.settings"
   DefineQuickFiles "myData", "myData.data", "perm", "Resources/Database"
   put "hello" into t1[1]
   put "goodbye" into t2[2]
   deleteQuickFile "settings"
   deleteQuickFile "myData"
end test_deleteQuickFile

on test_ISOdate
   test ISOdate ("02/27/2010") , "2010-02-27" 
   test ISOdate("Nov 3, 2014") , "2014-11-03" 
end test_ISOdate

on test_FindinStyledText
   -- tested manally in the FieldTester stack
end test_FindinStyledText

on test_ISOnow
   get ISOnow()
   if putit then put it & cr after msg
end test_ISOnow

on test_commandkeyDown
   
end test_commandkeyDown

on test_truncate
   test truncate ("this is a test of how to truncate",14) , "this is a test" 
   test  truncate ("this is a test of how to truncate",17, "...")  , "this is a test..." 
   test truncate ("this is a test of how to truncate",15 ,numtochar(201)) ,("this is a test"& numtochar(201) )
end test_truncate

on test_savestackversion
   
end test_savestackversion

on test_regexpLineOffset

end test_regexpLineOffset

on test_sr
  test sr (" this is a test   "), "this is a test"
end test_sr

on test_expandError
   -- used it this script
   fles
end test_expandError

on test_err
 --TODO
end test_err

on test_exportFile
 --TODO
end test_exportFile

on test_noDupes
   test noDupes("a,a,b,b,c,c"), "a,b,c"
end test_noDupes

on test_NoDuplicates
   put "a,a,b,b,c,c" into x
   NoDuplicates x
   test x, "a,b,c"
end test_NoDuplicates

on test_getDelimiters
   get getDelimiters ("123123kjlkj")
   if putit then put chartonum(it) & cr after msg
end test_getDelimiters

on test_arrayFromFile
   put "a" into o["A"]
   put "b" into o["B"]
   put  (specialfolderpath("Temporary") & slash & "test.dat") into fn
   arrayToFile o, fn
   put ArrayFromFile( fn) into i
   delete file fn
   if i <> o then throw "problem"
end test_arrayFromFile

on test_replaceItem
   put "a,b,c" into x
   replaceItem "Z", x, 2, comma
   test x, "a,Z,c"
end test_replaceItem

on test_ArrayToFile
   put "a" into o["A"]
   put "b" into o["B"]
   put  (specialfolderpath("Temporary") & slash & "test.dat") into fn
   arrayToFile o, fn
   put ArrayFromFile( fn) into i
   delete file fn
   if i <> o then throw "problem"
end test_ArrayToFile

on test_nudgeTextSize
 --visual test
end test_nudgeTextSize

on test_setCustomProp
 --TODO
end test_setCustomProp

on test_shakeStack
  --visual test
end test_shakeStack

on test_shuffleLines
   repeat with x = 1 to 10
      put x&cr after it
   end repeat
   delete char -1 of it
   shuffleLines it
   if putit then put it & cr after msg
end test_shuffleLines

on test__Random
   get _Random(100)
   if putit then put it & cr after msg
end test__Random

on test_anagram
   get anagram("abcd")
   if putit then put it & cr after msg
end test_anagram

on test_arrayToTabTable
   repeat with i = 1 to 3
      repeat with j =1 to 3
         put i&j into tA[i][j]
      end repeat
   end repeat
   get arrayToTabTable (tA) 
    if putit then put it & cr after msg
end test_arrayToTabTable

on test_tabTableToArray
 repeat with i = 1 to 3
      repeat with j =1 to 3
         put i&j into tA[i][j]
      end repeat
   end repeat
   put arrayToTabTable (tA) into foo
   put tabTableToArray(foo) into tB
   if tA<> tB then throw "arrays <>"
end test_tabTableToArray

on test_toTitleCase
   test toTitleCase ("hello") , "Hello"
   test toTitleCase ("this is a test") , "This is a Test"
   test toTitleCase ("this is a test","test") , "This is a test"
   test toTitleCase ("this is a test",",is") , "This is A Test"
end test_toTitleCase

on test_truncateInMiddle
   test truncateInMiddle("abcdefghijklmnopqrstuvwxyz",20), "abcdefghij…rstuvwxyz"
end test_truncateInMiddle

on test_controlAndGroupVisible

end test_controlAndGroupVisible

on test_userCanSeeControl

end test_userCanSeeControl

on test_CSVtoTable
--TODO
end test_CSVtoTable

on test_asciiHashCode
   put asciiHashCode ("This is a test") & cr after msg
   put asciiHashCode ("This is a test", 13) & cr after msg
   put asciiHashCode ("This is a test",, "password") & cr after msg
end test_asciiHashCode

on test_fillimageWithColor
--visual test
end test_fillimageWithColor

on test_sendPostMarkEmail
--tested seperately with private key and postmark account
end test_sendPostMarkEmail

on test_setPostmarkAPIKEY
--tested seperately with private key and postmark account
end test_setPostmarkAPIKEY

on test_UnThousands
test UnThousands ("1'000.123 456") , "1000,123456"
end test_UnThousands

on testSecondsToISO
--TODO
end testSecondsToISO

on test_Thousands
   test Thousands ("1234567.89012345")  , "1'234'567.890 123 45"
   test Thousands ("1234567.89012345", comma, comma)  , "1,234,567.890,123,45"
end test_Thousands

on test_RecurseOverFolders
--TODO
end test_RecurseOverFolders

on test_Overlap
--TODO
end test_Overlap

on test_Padded
 test Padded ("String",10) , "String    "
end test_Padded

on test_ISODateTime
 put ISODateTime()
end test_ISODateTime

on test_Clean
   test Clean ("    Hello   "), "Hello"
end test_Clean

on test_MultiSortFields
--TODO
end test_MultiSortFields

on test_Indent
test Indent (("X" & cr & "Y"), 5), ("     X" & cr & "     Y")
end test_Indent

on test_RelativePath
--TODO
end test_RelativePath

on test_ISOtoSeconds
--TODO
end test_ISOtoSeconds

on test_SecondsToISO
--TODO
end test_SecondsToISO

on test_positionLineinFld
--Manually tested
end test_positionLineinFld

on test_getCustomProp
--TODO
end test_getCustomProp

on test_SoftLineBreaks
--Manually tested
end test_SoftLineBreaks

on test_DummyTextData
--Manually tested
end test_DummyTextData

on test_positionCharinFld
--Manually tested
end test_positionCharinFld

on test_lineRanges
--Manually tested
end test_lineRanges

on test_PageRanges
--Manually tested
end test_PageRanges

on test_ConvertArrayToXML
--Manually tested
end test_ConvertArrayToXML

on test_ConvertXMLToArray
--Manually tested
end test_ConvertXMLToArray

on test_fileIsFolder
   --Manually tested
end test_fileIsFolder

on test_DecompressArchiveToFolder
   --   answer file "get a zip"
   --   put it into pZipArchivePath
   --   revZipOpenArchive pZipArchivePath, "read"
   --   answer folder "put it"
   --   put it into pOutputFolder
   --   DecompressArchiveToFolder pZipArchivePath, pOutputFolder
   --   revZipCloseArchive pZipArchivePath
end test_DecompressArchiveToFolder

on test_foldersInFolder
  --Manually tested
end test_foldersInFolder

on test_filesInFolder
    --Manually tested
end test_filesInFolder

on test_AddFolderToArchive
   --   ask file "make a zip"
   --   put it into pZipArchivePath
   --   revZipOpenArchive pZipArchivePath, "write"
   --   answer folder "get folder"
   --   put it into pRootFolderPath
   --   AddFolderToArchive pZipArchivePath, pRootFolderPath
   --   revZipCloseArchive pZipArchivePath
end test_AddFolderToArchive

on test_StacksInMemory
   --Manually tested
end test_StacksInMemory

on test_InstallPasswordFont
   InstallPasswordFont
end test_InstallPasswordFont

on test_writePort_Gert
--Manually tested
end test_writePort_Gert

on test_Pi_Stop_Reading_Gert
--Manually tested
end test_Pi_Stop_Reading_Gert

on test_Pi_Close_Gert
--Manually tested
end test_Pi_Close_Gert

on test_Pi_Start_Reading_Gert
--Manually tested
end test_Pi_Start_Reading_Gert

on test_Pi_Open_Serial_To_Gert
--Manually tested
end test_Pi_Open_Serial_To_Gert

on test_Pi_to_Gert_Stop_Reading
--Manually tested
end test_Pi_to_Gert_Stop_Reading

on test_Pi_to_Gert_Start_Reading
--Manually tested
end test_Pi_to_Gert_Start_Reading

on test_Pi_to_Gert_Open_Serial_Port
--Manually tested
end test_Pi_to_Gert_Open_Serial_Port

on test_Pi_to_Gert_Close_Serial_Port
--Manually tested
end test_Pi_to_Gert_Close_Serial_Port

on test_Pi_to_Gert_Write
--Manually tested
end test_Pi_to_Gert_Write

on test_Pi_to_Gert_Open
--Manually tested
end test_Pi_to_Gert_Open

on test_Pi_to_Gert_Close
--Manually tested
end test_Pi_to_Gert_Close

on test_HSVtoRGB
--TODO
end test_HSVtoRGB

on test_Pi_gpio_init
--Manually tested
end test_Pi_gpio_init

on test_CenterTextVertically
--Manually tested
end test_CenterTextVertically

on test_initializeCprops
--TODO
end test_initializeCprops

on test_IPCalc
   put IPCalc ("192.168.12.0/23") into AA
   put IPCalc ("192.168.12.0","255.255.254.0") into BB
   test AA, BB
end test_IPCalc

on test_getThumbs
--Manually tested
end test_getThumbs

on test_Zap
   put "A" & numtochar(1) & "A" into foo
   test Zap(foo), "AA"
end test_Zap

on test_deleteExtraTokens
   test deleteExtraTokens ("hello    world", space) , "hello world"
   test deleteExtraTokens ("hello    world") , "hello world"
end test_deleteExtraTokens

on test_GetRegexMatches
   put "hello" & cr into foo
   put "world" & cr after foo
   put "  hello" after foo
   put GetRegexMatches (foo, "hello") 
end test_GetRegexMatches

on test_combinatorial
--Manually tested
end test_combinatorial

on test_nComb
--Manually tested
end test_nComb

on test_factorial
--Manually tested
end test_factorial

on test_rad2deg
--Manually tested
end test_rad2deg

on test_latLongDist
--Manually tested
end test_latLongDist

on test_deg2rad
--Manually tested
end test_deg2rad

on test_dms2dd
--Manually tested
end test_dms2dd

on test_dd2dms
--Manually tested
end test_dd2dms

on test_trim
   test trim("   This is a test.   ") , "this is a test." 
   test trim("   This is a test.   ","end"), "   this is a test." 
end test_trim

on test_factorialFloor
--Manually tested
end test_factorialFloor

on test_nCombFloor
--Manually tested
end test_nCombFloor

on test_nCombFactors
--Manually tested
end test_nCombFactors

on test_subtractLists
 put "1,2,3,4" into listA
   put "4,6,7,8" into listB
   test subtractLists(listA,listB) , "1,2,3"
end test_subtractLists

on test_mergeLists
   put "1,2,3,4" into listA
   put "5,6,7,8" into listB
   test mergeLists(listA,listB) , "1,2,3,4,5,6,7,8"
end test_mergeLists

on test_intersectLists
   put "1,2,3,4" into listA
   put "4,6,7,8" into listB
   test intersectLists(listA,listB) , "4"
end test_intersectLists

on test_qInString
   test qInString("^Hello^"), quote & "Hello" & quote
end test_qInString

on test_importFile
--Manually tested
end test_importFile

on test_howmany
 test howmany("00","000000"), 3
end test_howmany

on test_exactTime
  put exactTime()
end test_exactTime

on test_getCounty
put getCounty("6704 Pauline Drive", "Chapel Hill", "NC")
end test_getCounty

on test_getZip
put getZip("6704 Pauline Drive", "Chapel Hill", "NC")
end test_getZip

on test_formatDate
--TODO
end test_formatDate

on test_InvertList
--TODO
end test_InvertList

on test_keepColumns
put empty into x
   repeat with i = 1 to 9
      repeat with j = 1 to 9
         put i & j & tab after x
      end repeat
      put return into the char -1 of x
   end repeat
   put x & cr & cr
   put keepColumns(x, "1,3-4,8-10,5") after msg
end test_keepColumns

on test_getAvailableHandlers
   put the long id of btn "lib" of card "LibMgr" into foo
   put getAvailableHandlers(foo)
end test_getAvailableHandlers

on test_caseSwitch
 test caseSwitch("Ken","Ken=male","Richard=male","Carol=female") , "male" 
end test_caseSwitch

on test_getHandlerFromScript
--Manually tested
end test_getHandlerFromScript

on test_displayHex
--Manually tested
end test_displayHex

on test_displayDump
--Manually tested
end test_displayDump

on test_displayBinary
--Manually tested
end test_displayBinary

on test_PowerSource
put PowerSource() & cr after msg
end test_PowerSource

on test_formatNumber
   test formatNumber (1000.00) , "$1,000.00"
   test formatNumber (1000,,comma) ,"1,000"
   test formatNumber (1000.00,,comma) ,"1,000.00"
   test formatNumber (1000.00,"$",comma) ,"$1,000.00"
   test formatNumber (1000.00,"£") ,"£1000.00"
   test formatNumber (1000.00,"£",".",,comma) , "£1.000,00"
   test formatNumber ("1000" & comma & "00","£",".",,comma,comma) ,"£1.000,00"
   test formatNumber (1000.00,,,"$") ,"1000.00$"
   test formatNumber (1000.0000000,,comma) ,"1,000.0000000"
end test_formatNumber

on test_RemoveDupLines
repeat with x = 1 to 5
      put x & cr & x & cr & x & cr & x & cr & x & cr & x & cr after foo
      if x = 3 then put 9 & cr & 7 & cr after foo
   end repeat
   test RemoveDupLines(foo), 9 & cr & 7 & cr
end test_RemoveDupLines

on test_StripDupLines
repeat with x = 1 to 5
      put x & cr & x & cr & x & cr & x & cr & x & cr & x & cr after foo
      if x = 3 then put 9 & cr & 7 & cr after foo
   end repeat
   test StripDupLines (foo), 1 & cr & 2  & cr & 3 & cr & 9 & cr & 7 & cr & 4 & cr & 5 & cr
end test_StripDupLines

on test_xyAD
   put 0 into yy
   put 0 into xx
   xyAd  100,100,10,180,xx,yy
   put xx,yy
end test_xyAD

on test_makeString
test makeString("?",3),"???"
end test_makeString

on test_displayArray
   put 1 into test[1]
   put 2 into test[2]
   put 11 into test[1][1]
   put 22 into test[2][2]
   put 333 into test[3][3][3]
   put displayArray(test) & cr after msg
end test_displayArray

on test_ReorderColumns
   put "1,2,3,4,5,6,7,8,9" & cr & "11,22,33,44,55,66,77,88,99" into tData
   put "2,3,4,7,6,1,5,8,9" & cr & "22,33,44,77,66,11,55,88,99" into rData
   test ReorderColumns (tData, "2-4, 7,6",comma) , rData
end test_ReorderColumns

on test_earthKM
   put empty into x
put earthKM (38.898556, -77.037852, 38.897147, -77.043934,x ) && x & cr after msg
end test_earthKM

on test_geoDistanceTo
   put geoDistanceTo (38.898556, -77.037852, 38.897147, -77.043934) & cr after msg
end test_geoDistanceTo

on test_geoDestinationPoint
put  geoDestinationPoint (51.4778, -0.0015, 100000, 45)   & cr after msg
end test_geoDestinationPoint

on test_compassPoint
   test compassPoint (270) , "W"
end test_compassPoint

on test_geoBearingTo
put geoBearingTo (38.898556, -77.037852, 38.897147, -77.043934)   & cr after msg
end test_geoBearingTo

on test_geofinalBearingTo
put geofinalBearingTo (38.898556, -77.037852, 38.897147, -77.043934)   & cr after msg
end test_geofinalBearingTo

on test_geoIntersection
--TODO
end test_geoIntersection

on test_latLongDist2
--TODO
end test_latLongDist2

on test_geoMidpoint
   put geoMidPoint (38.898556, -77.037852, 38.897147, -77.043934)  & cr after msg
end test_geoMidpoint

on test_geoMidpointTo
--TODO
end test_geoMidpointTo

on test_levDist
--TODO
end test_levDist

on test_exportFile2
--TODO
end test_exportFile2

on test_ScriptOnly
--TODO
end test_ScriptOnly

on test_wordBounds
--TODO
end test_wordBounds

on test_getColumns
--TODO
end test_getColumns

on test_numToAccounting
      test "1.23", numToAccounting(1.234)
      test "(1.23)", numToAccounting(-1.234)
      test "1,234.00", numToAccounting(1234)
      test "1,234,567,892.00", numToAccounting(1234567891.996)
      test "1,234,567,891.99", numToAccounting(1234567891.995)
      test "1'234,56", numToAccounting(1234.56, ",", "'")
      test "(1.234,56)", numToAccounting(-1234.56, ",", ".")
      test "(123,45)", numToAccounting(-123.45, ",", ".")
      test "123.00", numToAccounting(123)
end test_numToAccounting

on test_accountingToNum
      test 1.23, accountingToNum("1,23")
      test -1.23, accountingToNum("(1.23)")
      test 1234.0, accountingToNum("1,234.00")
      test 1234567892.0, accountingToNum("1,234,567,892.00")
      test 1234567891.99, accountingToNum("1,234,567,891.99")
      test 1234.56, accountingToNum("1'234,56")
      test -1234.56, accountingToNum("(1.234,56)")
      test -123.45, accountingToNum("(123,45)")
      test 123, accountingToNum("123.00")
end test_accountingToNum

on test_PointWithinGrc
--TODO
end test_PointWithinGrc

on test_ArrayEncodeVersion
--TODO
end test_ArrayEncodeVersion

on test_text_is_Caps
   test true, text_is_Caps("YES")
   test False, text_is_Caps("No")
end test_text_is_Caps

on test_directoryListing
--TODO
end test_directoryListing

on test_bSubtract
--TODO
end test_bSubtract

on test_bCompare
--TODO
end test_bCompare

on test_bAdd
--TODO
end test_bAdd

on test_bTimes
--TODO
end test_bTimes

on test_CSVtoArray2
--TODO
end test_CSVtoArray2

on test_resizeImageFile
--TODO
end test_resizeImageFile
