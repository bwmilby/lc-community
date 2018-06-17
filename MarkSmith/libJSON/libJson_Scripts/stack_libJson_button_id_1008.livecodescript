Script "stack_libJson_button_id_1008"

/*
# Name: button "json.fromArray formatted" of card id 1002 of stack "libJson"
# ID: button id 1008 of card id 1002 of stack "libJson"
*/


--> all handlers

on mouseUp
   put the monthnames into tMonths
   split tMonths by cr
   put tMonths into tArray["lists"]["months"]
   
   put the weekdaynames into tDays
   split tDays by cr
   put tDays into tArray["lists"]["days"]
   
   put the long date into tArray["now"]["date"]
   put the long time into tArray["now"]["time"]
   
   put "libJson" into tArray["library"]["name"]
   put "revolution" into tArray["library"]["language"]
   put "Mark Smith" into tArray["library"]["author"]
   put json.libVersion() into tArray["library"]["version"]
   
   put "Google" into tArray["webpages"]["1"]["name"]
   put "http://www.google.com" into tArray["webpages"]["1"]["url"]
   put "search engine" into tArray["webpages"]["1"]["type"]
   
   put "Amazon" into tArray["webpages"]["2"]["name"]
   put "http://www.amazon.com" into tArray["webpages"]["2"]["url"]
   put "retailer" into tArray["webpages"]["2"]["type"]
   
   
   put json.format(arrayToJson(tArray),5) into tJson
   set the json of btn "json.toArray" to tJson
   put tJson
end mouseUp
