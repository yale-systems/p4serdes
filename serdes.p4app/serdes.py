import struct

UDP_PORT = 1234

varIntC = struct.Struct('!i i') # key
varIntProto = struct.Struct('!B B B') # key

