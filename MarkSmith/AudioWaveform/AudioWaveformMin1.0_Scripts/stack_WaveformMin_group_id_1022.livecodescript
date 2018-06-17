Script "stack_WaveformMin_group_id_1022"

/*
# Name: group "AudioWaveform" of card id 1002 of stack "WaveformMin"
# ID: group id 1022 of card id 1002 of stack "WaveformMin"
*/


-------------------------------------------------------------
-------------------------------------------------------------
------AudioWaveform 0.96-------------------------------------
------© Mark Smith 2006--------------------------------------
------free to use--------------------------------------------
-------------------------------------------------------------
-------------------------------------------------------------
on newGroup
  awInitialize
end newGroup


on awInitialize
  killWaves
  set the uSampleList of me to empty
  set the uFile of me to empty
  hide img "error.png" of me
  set the uErrorString of me to empty
  put empty into fld "wave" of me
  set the CustomProperties["FileInfo"] of me to empty
  repositionEverything
  set the disabled of me to true
end awInitialize

-------------------------------------------------------------
-------------------------------------------------------------

setProp uFile fName
  if fName is empty then
    set the uFile of me to empty
    exit uFile
  end if
  if there is not a file fName then
    cantReadFile "file is missing"
  end if
  set the disabled of me to false
  set the uFile of me to fName
  checkFile
  getSamples
  showWaveform
  setFileInfo
end uFile


on reload
  put the uFile of me into tFile
  set the uFile of me to tFile
end reload

setProp uMilliSecsPerPoint nVal
  if nVal is not a number AND nVal is not "x" then exit uMilliSecsPerPoint
  set the uMilliSecsPerPoint of me to nVal
end uMilliSecsPerPoint

setProp uDefaultNumPoints nVal
  if nVal is not a number then exit uDefaultNumPoints
  set the uDefaultNumPoints of me to nVal
  if the uMilliSecsPerPoint of me is "x" then reload
end uDefaultNumPoints

setProp uStartEndPoints nVal
  set the uStartEndPoints of me to nVal
  set the uNumPoints of me to enNum() - stNum() + 1
  --if exists(grc "w1" of me) then setPlayerSelection
end uStartEndPoints


setProp uDisplayType nVal
  if nVal <> 1 AND nVAL <> 2 then exit uDisplayType
  set the uDisplayType of me to nVal
  showWaveform
end uDisplayType


setProp uBGshade aShade
  set the uBGshade of me to aShade
  set the backgroundColor of fld "wave" of me to aShade
end uBGshade

setProp uWaveShade aShade
  set the uWaveShade of me to aShade
  set the textColor of fld "wave" of me to aShade
  repeat for each line L in the uWaveList of me
    set the penColor of grc L of me to aShade
  end repeat
end uWaveShade

getProp uFileInfo
  return getFileInfo()
end uFileInfo

getProp uFileInfoArray
  put the customProperties["fileInfo"] of me into fileInfo
  return fileInfo
end uFileInfoArray



-------------------------------------------------------------
-------------------------------------------------------------

on cantReadFile errString
  set the uFileError of me to true
  set the uFileErrorString of me to "can't read file: " & errString
  killwaves
  set the CustomProperties["FileInfo"] of me to empty
  set the uFile of me to empty
  set the fileName of player "awPlayer" of me to empty
  show img "error.png" of me
  put the uFileErrorString of me into fld "wave" of me
  set the disabled of me to true
  exit to top
end cantReadFile

-------------------------------------------------------------
-------------------------------------------------------------
-- puts all the info into a custom property set "FileInfo"
on setFileInfo
  put the uFile of me into tFileInfoA["FileName"]
  put the uFileType of me into tFileInfoA["FileType"]
  put the uFileDuration of me into tFileInfoA["FileDuration"]
  put round(the uFileSize of me / 1048576,2) into tFileInfoA["FileSize"]
  put the uNumChannels of me into tFileInfoA["NumChannels"]
  put the uNumSampleFrames of me into tFileInfoA["NumSampleFrames"]
  put the uSampleRate of me into tFileInfoA["SampleRate"]
  put the uSampleSize of me into tFileInfoA["SampleSize"]
  
  set the CustomProperties["FileInfo"] of me to tFileInfoA
end setFileInfo
--1048576

-- return the file info as a readable block of text
function getFileInfo
  put "File: " & the FileInfo["FileName"] of me & cr into tFileInfo
  put "Type: " & the FileInfo["FileType"] of me & cr after tFileInfo
  put "Duration: " & the FileInfo["FileDuration"] of me && "seconds" & cr after tFileInfo
  put "FileSize: " & the FileInfo["FileSize"] of me && "MB" & cr after tFileInfo
  put "Channels: " & the FileInfo["NumChannels"] of me & cr after tFileInfo
  put "Sample frames: " & the FileInfo["NumSampleFrames"] of me & cr after tFileInfo
  put "Sample rate: " & the FileInfo["SampleRate"] of me & cr after tFileInfo
  put "Sample size: " & the FileInfo["SampleSize"] of me after tFileInfo
  return tFileInfo
end getFileInfo


-------------------------------------------------------------
-------------------------------------------------------------
-- establish what kind of file we're dealing with

on checkFile
  put the uFile of me into fName
  set the uFileError of me to false
  set the uFileErrorString of me to empty
  hide img "error.png" of me
  put empty into fld "wave" of me
  
  
  --check to see if it's an SD2 file
  put getResource(fName,"STR ",1000) into testRes
  if the result is empty then
    put "SDII" into fType
  else
     
     
    -- grab the first 48000 (or until eof) bytes from the file
    -- Loading the whole thing takes too long if the file is big
    
    open file fName for binary read
    read from file fName for 48000
    put it into rawHeader
    close file fName
    
    -- make sure we don't try to binaryDecode more data than we got
    -- ps is the binaryDecode string
    put "a" & length(rawHeader) into ps
     
    put empty into tHeader
    get binaryDecode(ps,rawHeader,tHeader)
    
    put empty into fType
    if "AIFF" is in tHeader then put "AIFF" into fType
    if "AIFC" is in tHeader then put "AIFC" into fType
    if "WAVE" is in tHeader then put "WAVE" into fType
  end if
  
  if fType is empty then cantReadFile "unknown file type"
  set the uFileType of me to fType
  set the uFileSize of me to getFileSize(fName)
  
  switch fType
  case "AIFF"
  case "AIFC"
    getAIFinfo tHeader,rawHeader
    break
  case "WAVE"
    getWAVinfo tHeader,rawHeader
    break
  case "SDII"
    getSD2Info
    break
  end switch
  
end checkFile


---------------------------------------------------------------
---------------------------------------------------------------
-- get info from AIFs

on getAIFinfo tHeader,tData
  
  --create variables for the binaryDecode function
  put empty into dummy
  put empty into numChannels
  put empty into numSampleFrames
  put empty into sampleSize
  put empty into sampleRate
  put empty into sndOffset
  put empty into blockSize
  put empty into numBytes
  put empty into compType
  
  --find the start of the COMM chunk
  get offset("COMM",tHeader)
  if it = 0 then cantReadFile "no aif comm chunk"
  put it into commChnkOff
  
  -- get the number of channels
  put char commChnkOff + 8 to commChnkOff + 9 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(s1,binNum,numChannels)
  
  -- get the number of sampleFrames
  put char commChnkOff + 10 to commChnkOff + 13 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(I1,binNum,numSampleFrames)
  
  -- get the sample size (8,16,24 or 32 bits)
  put char commChnkOff + 14 to commChnkOff + 15 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(s1,binNum,sampleSize)
  
  -- get the sample rate
  put char (commChnkOff + 16) to (commChnkOff + 25) of tData into eBytes
  put ieeeExtendedToDouble(eBytes) into dBytes
  if weAreOnIntel() then put reverseBytes(dBytes) into dBytes
  get binaryDecode("d1",dBytes,sampleRate)
  
  if the uFileType of me is "AIFC" then
    -- get the compression type - "none" or "sowt" seem to indicate no compression
    put "x" & commChnkOff + 25 & "a4" into ps
    get binaryDecode(ps,tData,dummy,compType)
  else
    put "none" into compType
  end if
  
  if compType is not "sowt" AND compType is not "none" then cantReadFile "not uncompressed aif format"
  
  --find the start of the SSND chunk
  get offset("SSND",tHeader)
  if it = 0 then cantReadFile "no aif ssnd chunk"
  put it into ssndChnkOff
  
  -- get the length of the SSND chunk
  put char ssndChnkOff + 4 to ssndChnkOff + 7 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(i1,binNum,numBytes)
  
  -- get the sound offset
  put char ssndChnkOff + 8 to ssndChnkOff + 11 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(i1,binNum,sndOffset)
  
  -- get the blockSize
  put char ssndChnkOff + 12 to ssndChnkOff + 15 of tData into binNum
  if weAreOnIntel() then put reverseBytes(binNum) into binNum
  get binaryDecode(i1,binNum,blockSize)
  
  -- this is a kludge since according to all the specs 
  -- I've seen it should be +15, but that seems to take
  -- us 2 bytes into the sound data which will reverse
  -- L/R in 16 bit stereo files, and mangle any 24 bit ones completely
  -- And further, files created by the mac finder
  -- seem to have their own weirdness
  put getFileType(the uFile of me) into tFileType
  if "hook" is in tFileType then
    put  ssndChnkOff + sndOffset + 13  into soundStart
  else
    put ssndChnkOff + sndOffset + 16 into soundStart
  end if
  
  set the uNumChannels of me to numChannels
  set the uSampleSize of me to sampleSize
  set the uNumSampleFrames of me to numSampleFrames
  set the uSampleRate of me to sampleRate
  set the uFileDuration of me to numSampleFrames / sampleRate
  set the uSoundStart of me to soundStart
  
end getAIFinfo

--------------------------------------------------------------------------------------
-- get info from WAVs

on getWavinfo tHeader,tData
   
  put empty into dummy
  put empty into numChannels
  put empty into audioFormat
  put empty into numSampleFrames
  put empty into sampleSize
  put empty into sampleRate
  put empty into c1
  put empty into c2
  put empty into c3
  put empty into c4
   
  get offset("fmt ",tHeader)
  if it = 0 then cantReadFile "no wav fmt chunk"
  put it into fmtChnkOff
  
  get offset("data",tHeader)
  if it = 0 then cantReadFile "no wav data chunk"
  put it into dataChnkOff
  put dataChnkOff +7 into soundStart
  
  put "x" & fmtChnkOff + 6 & "n1" into ps
  get binaryDecode(ps,tData,dummy,audioFormat)
  
  put "x" & fmtChnkOff + 8 & "n1" into ps
  get binaryDecode(ps,tData,dummy,numChannels)
  
  put "x" & fmtChnkOff + 20 & "n1" into ps
  get binaryDecode(ps,tData,dummy,sampleSize)
  put sampleSize / 8 into bytesPerSample
  
  put "x" & fmtChnkOff + 11 & "B8B8B8B8" into ps
  get binaryDecode(ps,tData,dummy,c1,c2,c3,c4)  -- may run into big/little endian problems here
  put baseConvert(c4 & c3 & c2 & c1,2,10) into sampleRate
  
  put "x" & dataChnkOff + 3 & "B8B8B8B8" into ps
  get binaryDecode(ps,tData,dummy,c1,c2,c3,c4)
  put baseConvert(c4 & c3 & c2 & c1,2,10) / bytesPerSample / numChannels into numSampleFrames
  
  if audioFormat <> 1 then
    cantReadFile "not uncompressed wav audio format"
    exit to top
  end if
  
  set the uNumChannels of me to numChannels
  set the uSampleSize of me to sampleSize
  set the uSampleRate of me to sampleRate
  set the uNumSampleFrames of me to numSampleFrames
  set the uFileDuration of me to numSampleFrames / sampleRate
  set the uSoundStart of me to soundStart
  
end getWavinfo

----------------------------------------------------------------------

on getSD2Info
  put the uFile of me into fName
  put char 2 to -1 of getResource(fName,"STR ",1000) * 8 into sampleSize
  put char 2 to -1 of getResource(fName,"STR ",1001) * 1 into sampleRate
  put char 2 to -1 of getResource(fName,"STR ",1002) into numChannels
  
  put URL ("binfile:" & fName) into tData
  put length(tData) / ((sampleSize / 8) * numChannels) into numSampleFrames
  
  set the uNumChannels of me to numChannels
  set the uSampleSize of me to sampleSize
  set the uSampleRate of me to sampleRate
  set the uNumSampleFrames of me to numSampleFrames
  set the uFileDuration of me to numSampleFrames / sampleRate
  set the uSoundStart of me to 1
end getSD2Info

----------------------------------------------------------------------
----------------------------------------------------------------------
-- get the actual sample data out of the file

--on getSamples
--  --file info
--  
--  put the uNumChannels of me into numChannels
--  put the uNumSampleFrames of me into numSampleFrames
--  put the uSampleSize of me into sampleSize
--  put the uSampleRate of me into sampleRate
--  put the uSoundStart of me into soundStart
--  put the uMillisecsPerPoint of me into msPerPoint
--  
--  --calculated info
--  if msPerPoint = 0 then
--    -- show all samples!!! likley to be unusably slow except on files < 1 second
--    put numSampleFrames into displayPoints
--  else if msPerPoint is "x" then
--    -- in practice will be <= 10000 because the number of frames won't be exact multiple
--    put the uDefaultNumPoints of me into displayPoints
--  else
--    put trunc(the uFileDuration of me * 1000 / msPerPoint) + 100 into displayPoints
--  end if
--  put min(displayPoints,numSampleFrames) into displayPoints
--  
--  --set max and min. Would you want to see fewer than 10 points?
--  if displayPoints < 10 then put 10 into displayPoints
--  if displayPoints > numSampleFrames then put numSampleFrames into displayPoints
--  
--  put sampleSize / 8 into bytesPerSample
--  put bytesPerSample * numChannels into bytesPerFrame
--  put bytesPerFrame * numSampleFrames into endByte
--  put (numSampleFrames / displayPoints) * bytesPerFrame into bytesPerPoint
--  
--  -- load the file
--  put URL ("binFile:" & the uFile of me) into tData
--   
--  --create variables for the binaryDecode function
--  put empty into cSample
--  put empty into skippedBytes
--  
--  
--   
--  --set up for loop
--  
--  put soundStart - 1 into bytesToSkip
--  
--  repeat displayPoints
--    put 0 into channelNum
--     
--    repeat numChannels
--      add 1 to channelNum
--      
--      put bytesToSkip + 1 into stChar
--      put bytesToSkip + bytesPerSample into enChar
--      put char stChar to enChar of tData into tSample
--       
--      switch bytesPerSample
--      case 1
--        --8 bit audio uses unsigned integers, apparently
--        put "x" & bytesToSkip & dataType into bdString
--        get binaryDecode("C1",tSample,cSample)
--        put cSample - 127 into cSample
--        break
--      case 3
--        --24 bits
--        put tfBits(tSample) into cSample
--        break
--      default
--        --16 or 32 bits
--        if weAreOnIntel() then put char 2 of tSample before tSample
--        get binaryDecode("s1",tSample,cSample)
--      end switch
--      
--      put cSample into item channelNum of sampleFrame
--      add bytesPerSample to bytesToSkip
--       
--    end repeat
--     
--    if numChannels = 1 then put trunc(average(sampleFrame)) into sampleFrame
--     
--    put sampleFrame & cr after sampleList
--     
--    add trunc(bytesPerPoint) to bytesToSkip
--    if bytesToSkip >= (soundStart + endByte) then exit repeat
--  end repeat
--  delete char -1 of sampleList
--   
--  repeat with n = 1 to numChannels
--    put 0 into item n of line 1 of sampleList
--  end repeat
--  set the uSampleList of me to sampleList
--  set the uStartEndPoints of me to "1," & availablePoints()
--  set the uVerticalZoom of me to 1
--end getSamples



on getSamples
  --file info
  
  put the uNumChannels of me into numChannels
  put the uNumSampleFrames of me into numSampleFrames
  put the uSampleSize of me into sampleSize
  put the uSampleRate of me into sampleRate
  put the uSoundStart of me into soundStart
  put the uMillisecsPerPoint of me into msPerPoint
  
  --calculated info
  if msPerPoint = 0 then
    -- show all samples!!! likley to be unusably slow except on files < 1 second
    put numSampleFrames into displayPoints
  else if msPerPoint is "x" then
    -- in practice will be <= 10000 because the number of frames won't be exact multiple
    put the uDefaultNumPoints of me into displayPoints
  else
    put trunc(the uFileDuration of me * 1000 / msPerPoint) + 100 into displayPoints
  end if
  put min(displayPoints,numSampleFrames) into displayPoints
  
  --set max and min. Would you want to see fewer than 10 points?
  if displayPoints < 10 then put 10 into displayPoints
  if displayPoints > numSampleFrames then put numSampleFrames into displayPoints
  
  put sampleSize / 8 into bytesPerSample
  put bytesPerSample * numChannels into bytesPerFrame
  put bytesPerFrame * numSampleFrames into endByte
  put round(numSampleFrames / displayPoints,0) into framesPerPoint
  put framesPerPoint * bytesPerFrame into bytesPerPoint
  
  
   
  --create variables for the binaryDecode function
  put empty into cSample
  put empty into skippedBytes
  
  
   
  --set up for loop
  put the uFile of me into fName
  open file fName for binary read
  seek to soundStart-1 in file fName
  put 0 into bytesRead
  
  
  repeat while bytesRead < endByte
    read from file fName for bytesPerPoint
    add length(it) to bytesRead
    
    put char 1 to bytesPerFrame of it into tFrame
    
    repeat with n = 1 to numChannels
      
      put char (n * bytesPerSample) - (bytesPerSample - 1) to (n * bytesPerSample) of tFrame into tSample
      
      switch bytesPerSample
      case 1
        get binaryDecode("C1",tSample,cSample)
        put cSample - 127 into cSample
        break
      case 2
        if weAreOnIntel() then put reverseBytes(tSample) into tSample
        get binaryDecode("s1",tSample,cSample)
        break
      case 3
        put tfBits(tSample) into cSample
        break
      end switch
      
      put cSample into item n of sampleFrame
    end repeat
    
    put sampleFrame & cr after sampleList
    --if bytesRead > endByte then exit repeat
  end repeat
  --delete char -1 of sampleList
  close file fName
   
  repeat with n = 1 to numChannels
    put 0 into item n of emptyFrame
  end repeat
  put emptyFrame into line 1 of sampleList
  put emptyFrame after sampleList
  
  set the uSampleList of me to sampleList
  set the uStartEndPoints of me to "1," & availablePoints()
  set the uVerticalZoom of me to 1
end getSamples

function tfBits tf -- 3 bytes
    put null after tf -- turn it into 4 bytes
    if weAreOnIntel() then put reverseBytes(tf) into tf
    put empty into tNum
    get binaryDecode("i1",tf,tNum)
    return trunc(tNum / 255) -- turn it back into 3 byte value
end tfBits

function reverseBits cSamp
  put empty into ts
  get binaryDecode("b16",cSamp,ts)
  replace space with empty in ts
  repeat for each char c in ts
    put c before ns
  end repeat
  put binaryEncode("b4",ns) into cs
  get binaryDecode("n1",cs,ts)
  return ts
end reverseBits

function reverseBytes tBytes
  repeat for each char c in tBytes
    put c before nBytes
  end repeat
  return nBytes
end reverseBytes





-------------------------------------------------------------
-------------------------------------------------------------
-- decide how to show the data, and prepare it for the drawing handler

on showWaveform
  if the uSampleList of me is empty then exit showWaveform
  lock screen
  lock messages
  killWaves
  
  if the uDisplayType of me = 1 then
    put makeAverage() into sampleList
    put 1 into numChannels
  else
    put makeMulti() into sampleList
    put the uNumChannels of me into numChannels
  end if
  
  put 0 into channelNum
  repeat for each line sList in sampleList
    add 1 to channelNum
    makeWave sList,channelNum,numChannels
  end repeat
end showWaveform


-------------------------------------------------------------

-- show all channels
function makeMulti
  repeat for each line L in the uSampleList of me
    put 0 into c
    repeat for each item I in L
      add 1 to c
      put I & comma after sLists[c]
    end repeat
  end repeat
  
  repeat with n = 1 to the uNumChannels of me
    delete char -1 of sLists[n]
    put sLists[n] & cr after inSampleList
  end repeat
  delete char -1 of inSampleList
  return inSampleList
end makeMulti


-- average into 1 channel
function makeAverage
  repeat for each line L in the uSampleList of me
    put trunc(average(L)) & comma after avSampleList
  end repeat
  delete char -1 of avSampleList
  return avSampleList
end makeAverage

-------------------------------------------------------------

-- draw the actual waveforms

on makeWave sampleList,channelNum,numChannels
  put the uVerticalZoom of me into vZoom
  
  -- calc the rect of the waveform graphic
  put the height of fld "wave" of me / numChannels into cHeight
  put the rect of fld "wave" of me into cRect
  add (channelNum - 1) * cHeight to item 2 of cRect
  put item 2 of cRect + cHeight into item 4 of cRect
  put item 3 of cRect - item 1 of cRect -5 into cWidth
  
  put item 2 of cRect into wTop
  put item 1 of cRect into wLeft
  
  -- calc the vertical range and zero point
  put 2 ^ the uSampleSize of me into vRange
  put trunc(vRange / 2) into sMax
  put 0 - sMax into sMin
  put cHeight / 2 into baseLine
  put (cHeight - 5) / vRange into vStep
  
  -- calc the horizontal step
  put (cWidth - 10) / the  number of items in sampleList into hStep
  
   
  -- make the pointsList for the graphic
  put wLeft + 5 into c
   
  put the millisecs into tStart
  repeat for each item i in sampleList
    if the optionKey is down then exit to top
    add hStep to c
     
    
    put i * vZoom into tSamp
    if tSamp > sMax then put sMax into tSamp
    if tSamp < sMin then put sMin into tSamp
    put trunc(c) & comma & trunc(baseLine - (tSamp * vStep) + wTop) into tPoint
    put 0 into pArray[tPoint]
  end repeat
  
  put the keys of pArray into pList
  sort lines of pList numeric by item 1 of each
  
  -- create the graphic and set its properties
  put "w" & channelNum into gName
  if not exists(grc gName of me) then create invisible grc gName in me
   
  set the rect of grc gName of me to cRect
  set the style of grc gName of me to "polygon"
  set the points of grc gName of me to pList
  set the antiAliased of grc gName of me to false
  set the penColor of grc gName of me to the uWaveShade of me
  set the backGroundColor of fld "wave" of me to the uBGshade of me
  show grc gName of me
  
  -- add it to the current list
  addWave gName
  
  
  
end makeWave

-------------------------------------------------------------

---keep a list of the current waveforms
on addWave gName
  put the uWaveList of me into wl
  put gName & cr after wl
  set the uWaveList of me to wl
end addWave

---so we can get rid of them easily
on killWaves
  repeat for each line L in the uWaveList of me
    if exists(grc L of me) then delete grc L of me
  end repeat
  set the uWaveList of me to empty
end killWaves

-------------------------------------------------------------
--- these are just to save a bit of typing

function stNum
  return item 1 of the uStartEndPoints of me
end stNum

function enNum
  return item 2 of the uStartEndPoints of me
end enNum


function availablePoints
  return the number of lines in the uSampleList of me
end availablePoints

-------------------------------------------------------------



-------------------------------------------------------------
-------------------------------------------------------------
--- yawn

on resizeControl
  repositionEverything
end resizeControl

on moveControl
  -- neccessary so that zooming and scrolling do the right thing
  --reload
  showWaveForm
end moveControl


on repositionEverything
  lock screen
  lock messages
  
  put 12 into rOff
  
  put the top of me + 6 into tTop
  put the left of me + 6 into tLeft
  put the width of me - rOff into tWidth
  put the height of me - rOff into tHeight
  
  set the width of fld "wave" of me to MAX(tWidth,200)
  set the height of fld "wave" of me to MAX(tHeight,50)
  
  set the top of fld "wave" of me to tTop
  set the left of fld "wave" of me to tLeft
  
  
  set the loc of img "error.png" of me to the loc of fld "wave" of me
  set the loc of img "hourglass.png" of me to the loc of fld "wave" of me
  
  showWaveform
  
end repositionEverything




-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- These came from Mark Waddingham at RunRev, as I'm too thick to have done them myself.

-- Take a sequence of 10-bytes encoding an extended number, and return
-- a sequence of 8-bytes encoding a double number
function ieeeExtendedToDouble pExtended
  local tExtendedSign, tExtendedExponent, tExtendedMantissa, tExtendedBits
  local tDoubleExponent, tDoubleMantissa, tDoubleBits

  if the length of pExtended is not 10 then
    throw "ieeeerr,Extended number must be 10 bytes long"
  end if

  -- Step 1: Split the extended number up
  get binaryDecode("B80", pExtended, tExtendedBits)
  put char 1 of tExtendedBits into tExtendedSign
  put char 2 to 16 of tExtendedBits into tExtendedExponent
  put char 17 to 80 of tExtendedBits into tExtendedMantissa

  -- Step 2: Truncate the fields

  -- The exponent is the trickiest because it is stored as a number relative to
  -- the smallest possible exponent which in the case of an extended number is
  -- -16383.
  -- Therefore, we take the following steps:
  --   . Make sure we have 16-binary digits
  --   . Encode as two binary bytes
  --   . Decode as a 2-byte integer, most-significant byte first (network byte-order)
  --   . Adjust and clamp to the double exponent range
  local tNumericExponent
  get binaryDecode("n", binaryEncode("B16", "0" & tExtendedExponent), tNumericExponent)
  subtract 16383 from tNumericExponent
  put max(min(tNumericExponent, 2046), -2046) into tNumericExponent

  -- IEEE Doubles actually have a normalization requirement for representation.
  -- The Mantissa is taken to be 1.F where F is the binary fraction encoded in the
  -- number. This seems subtlety different from the extended format, which has no
  -- such requirement (it appears). Therefore, we have to find the leading '1' in the
  -- extended mantissa and adjust the exponent accordingly.
  -- Of course, if there is no leading 1, then the number is 0
  local tLeadingOne

  -- Find the leading one, and return zero if there is none
  put offset("1", tExtendedMantissa) into tLeadingOne
  if tLeadingOne is 0 then
    return 0
  end if

  -- Extract 52-bits for the mantissa, and pad with zeros if we don't have enough
  put char tLeadingOne + 1 to tLeadingOne + 1 + 52 of tExtendedMantissa into tDoubleMantissa
  repeat while the length of tDoubleMantissa < 52
    put "0" after tDoubleMantissa
  end repeat

  -- Adjust the exponent
  subtract tLeadingOne - 1 from tDoubleExponent

  -- Finish encoding the exponent
  get binaryDecode("B16", binaryEncode("n", 1023 + tNumericExponent), tDoubleExponent)
  put char 6 to 16 of tDoubleExponent into tDoubleExponent

  -- Now reconstruct the double as bits
  put tExtendedSign & tDoubleExponent & tDoubleMantissa into tDoubleBits

  -- And perform the final encoding
  return binaryEncode("B64", tDoubleBits)
end ieeeExtendedToDouble

-- Take a sequence of 8 bytes encoding a double number, and return a
-- sequence of 10-bytes encoding an extended number
function ieeeDoubleToExtended pDouble
  local tSign, tExtendedExponent, tExtendedMantissa, tExtendedBits
  local tDoubleExponent, tDoubleMantissa, tDoubleBits

  if the length of pDouble is not 8 then
    throw "ieeeerr,Double number must be 8 bytes long"
  end if

  get binaryDecode("B64", pDouble, tDoubleBits)
  put char 1 of tDoubleBits into tSign
  put char 2 to 12 of tDoubleBits into tDoubleExponent
  put char 13 to 64 of tDoubleBits into tDoubleMantissa

  local tNumericExponent
  get binaryDecode("n", binaryEncode("B16", "00000" & tDoubleExponent), tNumericExponent)
  if tNumericExponent is 0 then
    put 0 into tNumericExponent
    put tDoubleMantissa into tExtendedMantissa
  else
    add 16383 - 1023 to tNumericExponent
    put "1" & tDoubleMantissa into tExtendedMantissa
  end if

  repeat while the length of tExtendedMantissa < 64
    put "0" after tExtendedMantissa
  end repeat

  get binaryDecode("B16", binaryEncode("n", tNumericExponent), tExtendedExponent)
  put char 2 to 16 of tExtendedExponent into tExtendedExponent

  put tSign & tExtendedExponent & tExtendedMantissa into tExtendedBits

  return binaryEncode("B80", tExtendedBits)
end ieeeDoubleToExtended

function getFileSize fName
  put the directory into oldFo
  set the itemDelimiter to "/"
  put item 1 to -2 of fName into foName
  put urlEncode(item -1 of fName) into fileName
  set the itemDelimiter to comma
  
  set the directory to foName
  put the detailed files into flist
  get lineOffset(fileName,flist)
  put item 2 of line it of flist into fSize
  set the directory to oldFo
  return fSize
end getFileSize

function getFiletype tPath
  if weAreOnIntel() then return empty
  put the directory into old_dir
  set the itemdel to "/"
  put last item of tPath into the_file
  delete last item of tPath
  set the directory to tPath
  put urlDecode(the long files) into all_files
  get line(lineoffset(the_file, all_files)) of all_files
  set the itemdel to ","
  set the directory to old_dir
  return last item of it
end getFiletype

function weAreOnIntel
  return "Motorola" is not in the processor
end weAreOnIntel
