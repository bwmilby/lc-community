# AES Encryption Demo

Originally from a stack posted at:
http://earthlearningsolutions.org/google-static-maps-demo/

Principal work by:
* William A. Prothero
* prothero@ucsb.edu
* https://earthlearningsolutions.org

Informed and inspired by:
* Andre Garza
* Brian Milby


Here are the 2 discussion threads on the use list:
- [Individual Messages]( http://lists.runrev.com/pipermail/use-livecode/2018-July/248184.html)
 / [Threaded View]( http://runtime-revolution.278305.n4.nabble.com/Script-Only-Stack-Behaviors-and-Nesting-tp4725764p4725870.html)
- [Individual Messages]( http://lists.runrev.com/pipermail/use-livecode/2018-June/247982.html)
 / [Threaded View]( http://runtime-revolution.278305.n4.nabble.com/Top-Bottom-Left-Right-tp4725667p4725671.html)


Notes:
1. To do an immediate test, go to the "Test" screen (click "Go to Test") and run the test. This test accesses my web server with encryption keys unique to this test.
2. Copy the php code from this stack, into a text editor, and upload it to your cgi folder on your server. Add the eKey line (indicated in the php listing) to the  `.htaccess` file in your cgi folder.
3. Examine the code in the stack script and modify the URL to point to your uploaded cgi.
4. Run the test on your server.
5. When successful, modify the cgi for your purposes. Make sure the indicated LC scripts are in a protected area and you change the 32 char encryption key to a unique string.
