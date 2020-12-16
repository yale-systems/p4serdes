from p4app import P4Mininet
from mininet.topo import SingleSwitchTopo
import sys
import time

topo = SingleSwitchTopo(2)
net = P4Mininet(program='serdes.p4', topo=topo)
net.start()

s1, h1, h2 = net.get('s1'), net.get('h1'), net.get('h2')

# TODO Populate IPv4 forwarding table

# TODO Populate the cache table


# Now, we can test that everything works

# Start the server with some key-values
server = h1.popen('./server.py', stdout=sys.stdout, stderr=sys.stdout)
time.sleep(0.4) # wait for the server to be listenning

out = h2.cmd('./client.py 10.0.0.1') # expect a resp from server

#assert out.strip() == "11"

server.terminate()
