#!/usr/bin/env python

import sys
import socket
from serdes import *


if len(sys.argv) != 3:
    print "Usage: %s HOST KEY" % sys.argv[0]
    sys.exit(1)

host = sys.argv[1]
value = 150 

addr = (host, UDP_PORT)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.settimeout(2)

req = varIntC.pack(key)
s.sendto(req, addr)

res, addr2 = s.recvfrom(1024)

b1, b2, b3 = varIntProto.unpack(res)

print b1
print b2
print b3



# assert key2 == key

# if valid:
#     print value
# else:
#     print "NOTFOUND"
