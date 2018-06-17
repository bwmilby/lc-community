Script "stack_hash_tests_button_id_1079"

/*
# Name: button "store htpasswd" of card "htpasswd" of stack "hash tests"
# ID: button id 1079 of card id 1069 of stack "hash tests"
*/


--> all handlers

on mouseUp
   if the pw of grp "pwgrp" is "sha1s" then
      put htpasswd.sha1.salted(fld "pw")  into fld "htpasswd"
   else
        put htpasswd.sha1(fld "pw")  into fld "htpasswd"
       
   end if
end mouseUp
