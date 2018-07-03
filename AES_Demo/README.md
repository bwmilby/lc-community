Notes:
1. To do an immediate test, go to the "Test" screen (click "Go to Test") and run the test. This test accesses my web server with encryption keys unique to this test.
2. Copy the php code from this stack, into a text editor, and upload it to your cgi folder on your server. Add the eKey line (indicated in the php listing) to the  .htaccess file in your cgi folder.
3. Examine the code in the stack script and modify the URL to point to your uploaded cgi.
4. Run the test on your server.
5. When successful, modify the cgi for your purposes. Make sure the indicated LC scripts are in a protected area and you change the 32 char encryption key to a unique string.
