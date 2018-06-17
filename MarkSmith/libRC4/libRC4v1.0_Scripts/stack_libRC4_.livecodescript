Script "stack_libRC4_"

/*
# Name: stack "libRC4"
# ID: stack "libRC4"
*/


--> all handlers

function rc4 pData, pKey
  
  -- initialize
  repeat with i = 0 to 255
    put i into S1[i]
  end repeat
  
  put 0 into i
  repeat with n = 0 to 255
    add 1 to i
    if i > length(pkey) then put 1 into i
    put chartonum(char i of pKey) into S2[n]
  end repeat
  
  put 0 into j
  repeat with i = 0 to 255
    put (j + S1[i] + S2[i]) mod 256 into j
    put S1[i] into temp
    put S1[j] into S1[i]
    put temp into S1[j]
  end repeat
  
  -- encrypt/decrypt
  put 0 into i ; put 0 into j
  repeat for each char c in pData
    put chartonum(c) into tChar
    
    put (i + 1) mod 256 into i
    put (j + S1[i]) mod 256 into j
    put S1[i] into temp
    put S1[j] into S1[i]
    put temp into S1[j]
    put (S1[i] + S1[j]) mod 256 into t
    put S1[t] into K
    
    put numtochar(tChar bitXor K) after tOutput
  end repeat
  
  return tOutput
end rc4

function rc4_EncodeBin pData, pKey
    return rc4(pData, pKey)
end rc4_EncodeBin

function rc4_EncodeB64 pData, pKey
    return base64encode(rc4(pData, pKey))
end rc4_EncodeB64

function rc4_EncodeHex pData, pKey
    return binToHex(rc4(pData, pKey))
end rc4_EncodeHex

function rc4_DecodeBin pData, pKey
    return rc4(pData, pKey)
end rc4_DecodeBin

function rc4_DecodeB64 pData, pKey
    return rc4(base64decode(pData), pKey)
end rc4_DecodeB64

function rc4_DecodeHex pData, pKey
    return rc4(hexToBin(pData), pKey)
end rc4_DecodeHex

function hexToBin pData
    return binaryencode("H*", pData)
end hexToBin

function binToHex pData
    put empty into tBinData
    get binarydecode("H*", pData, tBinData)
    return tBinData
end binToHex
