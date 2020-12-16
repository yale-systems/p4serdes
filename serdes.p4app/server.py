#!/usr/bin/env python

import sys
import socket
from serdes import *

print "server starting"


s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('', UDP_PORT))

while True:
    print "."
    msg, addr = s.recvfrom(1024)
    value = varIntC.unpack(msg)

    print addr, "-> msg(%d),"%value


