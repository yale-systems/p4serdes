import struct

UDP_PORT = 1234

varIntC = struct.Struct('!i i') # key
varIntProto = struct.Struct('!i B B B B') # key

