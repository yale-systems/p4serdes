#!/usr/bin/env python

import sys
import socket
from serdes import *

print "client.py called"


if len(sys.argv) != 2:
    print "Usage: %s HOST KEY" % sys.argv[0]
    sys.exit(1)

    
host = sys.argv[1]
value = 150 

addr = (host, UDP_PORT)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(2)

msg = varIntC.pack(150)
print bytes(msg)
s.sendto(msg, addr)

print "sent msg"

