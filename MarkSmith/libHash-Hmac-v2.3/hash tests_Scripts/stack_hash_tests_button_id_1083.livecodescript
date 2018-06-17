Script "stack_hash_tests_button_id_1083"

/*
# Name: button "verify>" of card "htpasswd" of stack "hash tests"
# ID: button id 1083 of card id 1069 of stack "hash tests"
*/


--> all handlers

on mouseUp
  put fld "htpasswd" into tStored
  put fld "pw" into tPw
  put verify.htpasswd.sha1(tpw, tStored) into fld "verify"
end mouseUp
