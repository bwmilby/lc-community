Script "stack_libJson_button_id_1007"

/*
# Name: button "json.fromArray" of card id 1002 of stack "libJson"
# ID: button id 1007 of card id 1002 of stack "libJson"
*/


--> all handlers

on mouseUp
   put the monthnames into tMonths
   split tMonths by cr
   put tMonths into tArray["lists"]["months"]
   
   put the weekdaynames into tDays
   split tDays by cr
   put tDays into tArray["lists"]["days"]
   
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
   
   put arrayToJson(tArray)
end mouseUp
