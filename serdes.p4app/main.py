from p4app import P4Mininet
from mininet.topo import SingleSwitchTopo
import sys
import time

topo = SingleSwitchTopo(2)
net = P4Mininet(program='serdes.p4', topo=topo)
net.start()

s1, h1, h2 = net.get('s1'), net.get('h1'), net.get('h2')

# TODO Populate IPv4 forwarding table

def hostIP(i):
    return "10.0.0.%d" % (i)

# TODO Populate IPv4 forwarding table
s1.insertTableEntry(table_name='MyIngress.ipv4_lpm',
                        match_fields={'hdr.ipv4.dstAddr': [hostIP(2), 32]},
                        action_name='MyIngress.ipv4_forward',
                        action_params={'dstAddr': h2.MAC(),
                                       'port': 2})
s1.insertTableEntry(table_name='MyIngress.ipv4_lpm',
                        match_fields={'hdr.ipv4.dstAddr': [hostIP(1), 32]},
                        action_name='MyIngress.ipv4_forward',
                        action_params={'dstAddr': h1.MAC(),
                                       'port': 1})


# Now, we can test that everything works

# Start the server with some key-values
server = h1.popen('./server.py', stdout=sys.stdout, stderr=sys.stdout)
time.sleep(0.4) # wait for the server to be listenning

print "h2 command"
out = h2.cmd('./client.py 10.0.0.1') # expect a resp from server

print out


print "h2 command returned"

#assert out.strip() == "11"


time.sleep(1.5) 

server.terminate()
