libRC4 1.0
Mark Smith
January 2008

This library provides a Revolution implementation of the RC4 encryption algorithm.
The RC4 scheme takes the data to be encoded or decoded, and a key (password).

There are six user functions in the library, three to encode, three to decode:

rc4_EncodeBin(data, key)  encodes the data as rc4-encoded binary string.
rc4_EncodeHex(data, key)  encodes the data as rc4-encoded hexadecimal string.
rc4_EncodeB64(data, key)  encodes the data as base64-encoded rc4_encoded string (best for transmission over the internet).


rc4_DecodeBin(data, key)  decodes the binary-encoded data.
rc4_DecodeHex(data, key)  decodes the hexadecimal-encoded data.
rc4_DecodeBin(data, key)  decodes the base64-encoded data.

Both sides (encoding and decoding) must use the same encoding (bin/hex/b64) ie. if you encode with rc4_EncodeB64, then you must decode with rc4_DecodeB64.

So to send rc4-encoded data between two parties, both parties need to know the key (password). Let's say the key = "secret", and party 'a' wants to send the message "attack at dawn" to party 'b'.

Party 'a' does this:

put rc4_EncodeB64("attack at dawn", "secret") into tEncodedMessage

tEncodedMessage looks like this: jEKmfeHP9sdG69+9hIg=
which is then sent to party 'b'

party 'b' does this:

put rc4_DecodeB64(tEncodedMessage, "secret") into tDecodedMessage
tDecodedMessage looks like this: "attack at dawn"
