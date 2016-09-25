#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
}

struct metadata {
}

struct headers {
    @name("ethernet") 
    ethernet_t ethernet;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("parse_ethernet") state parse_ethernet {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition accept;
    }
    @name("start") state start {
        transition parse_ethernet;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction_1") action NoAction() {
    }
    @name("cntDum") counter(32w70000, CounterType.packets) cntDum;
    @name("act") action act_0(bit<8> idx) {
        cntDum.count((bit<32>)idx);
    }
    @name("tab1") table tab1() {
        actions = {
            act_0();
            NoAction();
        }
        key = {
            hdr.ethernet.dstAddr: exact;
        }
        size = 160000;
        default_action = NoAction();
    }
    apply {
        tab1.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;