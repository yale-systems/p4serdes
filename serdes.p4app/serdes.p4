/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<8> TYPE_UDP = 0x11;

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> length_;
    bit<16> checksum;
}

header var_int_c_t {
    bit<32>  number;
}

header var_int_proto_t {
    bit<32> outputSize;
    bit<8>  b1;
    bit<8>  b2;
    bit<8>  b3;
    bit<8>  b4;
}

struct metadata { }


struct headers {
    ethernet_t       ethernet;
    ipv4_t           ipv4;
    udp_t            udp;
    var_int_c_t      msg;
    var_int_proto_t  proto;
}

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start { 	
        transition parse_ethernet; 
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            TYPE_UDP: parse_udp;
            default: accept;
        }
    }

    state parse_udp {
        packet.extract(hdr.udp);
        transition select(hdr.udp.dstPort) {
            1234: parse_msg;
            default: accept;
        }
    }

    state parse_msg {
        packet.extract(hdr.msg);
        transition accept;
    }

}

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply { }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

     action drop() {
        mark_to_drop();
    }
    
     action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
     }

     action encode() {
         hdr.proto.setValid();
         bit<32> size = 0;
         if (hdr.msg.number > 127) {
             hdr.proto.b1 = ((bit<8>)hdr.msg.number & 127) | 128;
             hdr.msg.number = hdr.msg.number >> 7;
             size = size + 1;
         }
         if (hdr.msg.number > 127) {
             hdr.proto.b2 = ((bit<8>)hdr.msg.number & 127) | 128;
             hdr.msg.number = hdr.msg.number >> 7;
             size = size + 1;
         }
         if (hdr.msg.number > 127) {
             hdr.proto.b3 = ((bit<8>)hdr.msg.number & 127) | 128;
             hdr.msg.number = hdr.msg.number >> 7;
             size = size + 1;
         }
         if (hdr.msg.number > 127) {
             hdr.proto.b4 = ((bit<8>)hdr.msg.number & 127) | 128;
             hdr.msg.number = hdr.msg.number >> 7;
             size = size + 1;
         }
         if (size == 0) {
             hdr.proto.b1 = (bit<8>)hdr.msg.number & 127;
         }
         if (size == 1) {
             hdr.proto.b2 = (bit<8>)hdr.msg.number & 127;
         }
         if (size == 2) {
             hdr.proto.b3 = (bit<8>)hdr.msg.number & 127;
         }
         if (size == 3) {
             hdr.proto.b4 = (bit<8>)hdr.msg.number & 127;
         }
         hdr.proto.outputSize = size;
         hdr.msg.setInvalid();

     }
    
     table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

  apply {
      if(hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
            encode();
      } 
  }
}

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
        update_checksum(
            hdr.ipv4.isValid(),
                { hdr.ipv4.version,
                  hdr.ipv4.ihl,
                  hdr.ipv4.diffserv,
                  hdr.ipv4.totalLen,
                  hdr.ipv4.identification,
                  hdr.ipv4.flags,
                  hdr.ipv4.fragOffset,
                  hdr.ipv4.ttl,
                  hdr.ipv4.protocol,
                  hdr.ipv4.srcAddr,
                  hdr.ipv4.dstAddr },
                hdr.ipv4.hdrChecksum,
                HashAlgorithm.csum16);
    }
}

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
    packet.emit(hdr.ethernet);
    packet.emit(hdr.ipv4);
    packet.emit(hdr.udp);
    packet.emit(hdr.msg);
    packet.emit(hdr.proto);
 }
}

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
