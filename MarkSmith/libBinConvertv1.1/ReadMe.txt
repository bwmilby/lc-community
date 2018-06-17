libBinConvert 1.1

libBinConvert is a library that provides a wrapper around the binaryEncode and binaryDecode functions. It aims to provide descriptively named functions that are easier to remember than the cryptic format specifiers required by the binaryEncode/Decode functions.

It covers signed and unsigned integers of any length (only tested so far up to 16 bytes), floats of 4, 8 and 10 (ieeeExtended) bytes, in either network (big-endian/motorola/mac) byte-order or little-endian/intel byte-order.

It also avoids bug 5315, where binaryDecode treats signed integers as unsigned on intel machines (fixed in Rev 2.9).

The functions are:

from binary to revolution numbers:
getIntBE(binaryBytes)
getUintBE(binaryBytes)
getIntLE(binaryBytes)
getUIntLE(binaryBytes)
getFloatBE(binaryBytes)
getFloatLE(binaryBytes)

getIntListBE(binaryBytes, sizeInBytes, optionalDelimiter)
getIntListLE(binaryBytes, sizeInBytes, optionalDelimiter)
getUIntListBE(binaryBytes, sizeInBytes, optionalDelimiter)
getUintListLE(binaryBytes, sizeInBytes, optionalDelimiter)
getFloatListBE(binaryBytes, sizeInBytes, optionalDelimiter)
getFloatListLE(binaryBytes, sizeInBytes, optionalDelimiter)

from revolution numbers to binary:

toInt1(aNumber)
toUint1(aNumber)
toInt2BE(aNumber)
toInt2LE(aNumber)
toUInt2BE(aNumber)
toUInt2LE(aNumber)
toInt3BE(aNumber)
toInt3LE(aNumber)
toUInt3BE(aNumber)
toUInt3LE(aNumber)
toInt4BE(aNumber)
toInt4LE(aNumber)
toUInt4BE(aNumber)
toUInt4LE(aNumber)
toBigIntBE(aNumber, outputSizeInBytes)
toBigIntLE(aNumber, outputSizeInBytes)
toBigUIntBE(aNumber, outputSizeInBytes)
toBigUIntLE(aNumber, outputSizeInBytes)

toFloat4BE(aNumber)
toFloat4LE(aNumber)
toFloat8BE(aNumber)
toFloat8LE(aNumber)
toFloat10BE(aNumber)
toFloat10LE(aNumber)



To convert binary numbers to revolution numbers, use the 'get' functions.

The functions will perform the appropriate conversions for the length of data passed. ie.:
if you pass in 4 binary bytes of data to getIntLE(), the conversion will be from a 4 byte signed integer in little-endian format.
<put getIntLE(some4bytes) into tNumber>
If you pass in 2 binary bytes of data to getUIntBE(), the conversion will be from a 2 byte unsigned integer in big-endian format.
<put getUIntLE(some2bytes) into tNumber>
NB. For 1 byte numbers, you can use either LE or BE.

For floating point numbers, use getFloatBE() and getFloatLE()
Again, the functions will perform the appropriate conversions for the length of data passed. ie.:
If you pass in 8 bytes of binary data to getFloatBE(), the conversion will be from an 8 byte float (double) in big-endian format.
<put getFloatBE(some8bytes) into tNumber>

For the list functions, pass in the data to convert, the size in bytes of the conversion, and optionally a delimiter (defaults to comma). The return value will be a list of numbers.
To convert a block of binary data from 4 byte unsigned integers in little-endian format to a revolution return -delimited list of numbers:
<put getUIntListLE(tBinData, 4, return) into tNumberList>

To convert revolution numbers to binary, use the 'to' functions.

To convert the number -423 to a 2 byte signed integer in little-endian format:
<put toInt2LE(-423) into tBinNum>

To convert numbers to a larger format than 4 bytes, use toBigInt/toBigUint.
To convert the number -1234567891234567 to an 8 byte signed integer in big-endian format:
<put toBigIntBE(-1234567891234567, 8) into tBinNum>
(nb. the 'toBig' handlers default to an 8 byte output, so you don't have to specify it unless you want something other than 8 bytes.


To convert the number 562.87 to an 8 byte float in big-endian format:
<put toFloat8BE(562.87) into tBinNum>

I have not included input validation, so it's up to you to make sure that you're not passing invalid data, ie. toUInt4LE(someNegativeNumber).

libBinConvert is free for any and all uses, at the users risk!


Mark Smith
mark@maseurope.net
Jan 2008

Changes in this version (1.1):

Added the capability of working with arbitrary sizes of signed and unsigned integers.

