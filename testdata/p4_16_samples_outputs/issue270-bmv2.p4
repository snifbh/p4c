#include <core.p4>
#include <v1model.p4>

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

struct H {
    ipv4_t inner_ipv4;
    ipv4_t ipv4;
}

struct M {
}

parser P(packet_in b, out H p, inout M meta, inout standard_metadata_t standard_meta) {
    state start {
        transition accept;
    }
}

control Ing(inout H headers, inout M meta, inout standard_metadata_t standard_meta) {
    apply {
    }
}

control Eg(inout H hdrs, inout M meta, inout standard_metadata_t standard_meta) {
    apply {
    }
}

action drop() {
}
control VerifyChecksumI(in H hdr, inout M meta) {
    Checksum16() inner_ipv4_checksum;
    Checksum16() ipv4_checksum;
    apply {
        bit<16> inner_cksum = inner_ipv4_checksum.get({ hdr.inner_ipv4.version, hdr.inner_ipv4.ihl, hdr.inner_ipv4.diffserv, hdr.inner_ipv4.totalLen, hdr.inner_ipv4.identification, hdr.inner_ipv4.flags, hdr.inner_ipv4.fragOffset, hdr.inner_ipv4.ttl, hdr.inner_ipv4.protocol, hdr.inner_ipv4.srcAddr, hdr.inner_ipv4.dstAddr });
        bit<16> cksum = ipv4_checksum.get({ hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr });
        if (hdr.inner_ipv4.ihl == 5 && hdr.inner_ipv4.hdrChecksum != inner_cksum) {
            drop();
        }
        if (hdr.ipv4.ihl == 5 && hdr.ipv4.hdrChecksum != cksum) {
            drop();
        }
    }
}

control ComputeChecksumI(inout H hdr, inout M meta) {
    Checksum16() inner_ipv4_checksum;
    Checksum16() ipv4_checksum;
    apply {
        bit<16> inner_cksum = inner_ipv4_checksum.get({ hdr.inner_ipv4.version, hdr.inner_ipv4.ihl, hdr.inner_ipv4.diffserv, hdr.inner_ipv4.totalLen, hdr.inner_ipv4.identification, hdr.inner_ipv4.flags, hdr.inner_ipv4.fragOffset, hdr.inner_ipv4.ttl, hdr.inner_ipv4.protocol, hdr.inner_ipv4.srcAddr, hdr.inner_ipv4.dstAddr });
        bit<16> cksum = ipv4_checksum.get({ hdr.ipv4.version, hdr.ipv4.ihl, hdr.ipv4.diffserv, hdr.ipv4.totalLen, hdr.ipv4.identification, hdr.ipv4.flags, hdr.ipv4.fragOffset, hdr.ipv4.ttl, hdr.ipv4.protocol, hdr.ipv4.srcAddr, hdr.ipv4.dstAddr });
        if (hdr.inner_ipv4.ihl == 5) {
            hdr.inner_ipv4.hdrChecksum = inner_cksum;
        }
        if (hdr.ipv4.ihl == 5) {
            hdr.ipv4.hdrChecksum = cksum;
        }
    }
}

control DP(packet_out b, in H p) {
    apply {
    }
}

V1Switch(P(), VerifyChecksumI(), Ing(), Eg(), ComputeChecksumI(), DP()) main;
