Halloween HTA Application
=========================

gif2b64.sh

BASH script to convert GIF images to base64

Usage:

./gif2b64.sh <gif1> [<gif2>] ... [<gif-n>] > file

where gif1,gif2, ... are the names of the GIF images files (you don't need to write the extension .gif)

Example:

./gif2b64.sh mygif0 doll-giffy bear pumpkin > g.txt

This will convert to base64:

mygif0.gif
doll-giffy.gif
bear.gif
pumpkin.gif

And the result will be written to the g.txt file

The format of g.txt file will be:

"code base64 of mygif0.gif",
"code base64 of doll-giffy.gif",
"code base64 of bear.gif",
"code base64 of pumpkin.gif"

=============================

images

Folder with all GIF images 

=============================

launcher 

It's the launcher generatated by the empire stager

=============================

imbase64.txt

It's the code of the im0.gif to im9.gif converted to base64

=============================

halloween.html

It's the web page to test in our browser including the base64 code of all GIF images

=============================

halloween.hta

It's the final HTA application including:

1. The HTA:application HTML tag
2. The payload with the empire launcher
3. The extension HTA


