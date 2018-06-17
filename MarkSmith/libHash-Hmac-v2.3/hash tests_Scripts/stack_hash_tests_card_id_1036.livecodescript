Script "stack_hash_tests_card_id_1036"

/*
# Name: card "hash-hmac" of stack "hash tests"
# ID: card id 1036 of stack "hash tests"
*/


--> all handlers

on calcHash
   put fld "Input" into tData
   switch the hash of grp "hashchoice"
      case "fnv1-32"
         put fnv132.hex(tData) into fld "result"
         break
      case "fnv1a-32"
         put fnv1a32.hex(tData) into fld "result"
         break
      case "md5"
         put md5.hex(tData) into fld "result"
         break
      case "md5"
         put md5.hex(tData) into fld "result"
         break
      case "sha-1"
         put sha1.hex(tData) into fld "result"
         break
      case "sha-224"
         put sha224.hex(tData) into fld "result"
         break
      case "sha-256"
         put sha256.hex(tData) into fld "result"
         break
   end switch
end calcHash

on calchmac
   put fld "Input" into tData
   put fld "hmackey" into tKey
   
   switch the hash of grp "hashchoice"
      case "md5"
         put hmacMd5.hex(tData, tKey) into fld "result"
      break
      case "sha-1"
         put hmacSha1.hex(tData, tKey) into fld "result"
      break
      case "sha-224"
         put hmacSha224.hex(tData, tKey) into fld "result"
      break
      case "sha-256"
         put hmacSha256.hex(tData, tKey) into fld "result"
      break
   end switch
end calchmac
