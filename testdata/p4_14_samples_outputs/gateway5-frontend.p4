#include <core.p4>
#include <v1model.p4>

header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<2>  x1;
    bit<3>  pad0;
    bit<2>  x2;
    bit<5>  pad1;
    bit<1>  x3;
    bit<3>  pad2;
    bit<32> skip;
    bit<1>  x4;
    bit<1>  x5;
    bit<6>  pad3;
}

struct metadata {
}

struct headers {
    @name("data") 
    data_t data;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract<data_t>(hdr.data);
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("output") action output_0(bit<9> port) {
        standard_metadata.egress_spec = port;
    }
    @name("noop") action noop_0() {
    }
    @name("test1") table test1_0() {
        actions = {
            output_0();
            noop_0();
            @default_only NoAction();
        }
        key = {
            hdr.data.f1: exact @name("hdr.data.f1") ;
        }
        default_action = NoAction();
    }
    @name("test2") table test2_0() {
        actions = {
            output_0();
            noop_0();
            @default_only NoAction();
        }
        key = {
            hdr.data.f2: exact @name("hdr.data.f2") ;
        }
        default_action = NoAction();
    }
    apply {
        if (hdr.data.x2 == 2w1 && hdr.data.x4 == 1w0) 
            test1_0.apply();
        else 
            test2_0.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<data_t>(hdr.data);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
