####    VHF-22 tranciever   ####
####    Syd Adams    ####

var VHF = props.globals.getNode("/instrumentation/VHF-22",1);
var VH1_STBY = VHF.getNode("standby1",1);
var VH2_STBY = VHF.getNode("standby2",1);
var VH1_COMM = VHF.getNode("comm1",1);
var VH2_COMM = VHF.getNode("comm2",1);

var SB1=props.globals.getNode("/instrumentation/comm/frequencies/standby-mhz");
var SB2=props.globals.getNode("/instrumentation/comm[1]/frequencies/standby-mhz");
var COMM1=props.globals.getNode("/instrumentation/comm/frequencies/selected-mhz");
var COMM2=props.globals.getNode("/instrumentation/comm[1]/frequencies/selected-mhz");


setlistener("/sim/signals/fdm-initialized", func {
    VH1_STBY.setValue(getprop("/instrumentation/comm/frequencies/standby-mhz")*1000);
    VH2_STBY.setValue(getprop("/instrumentation/comm[1]/frequencies/standby-mhz")*1000);
    VH1_COMM.setValue(getprop("/instrumentation/comm/frequencies/selected-mhz")*1000);
    VH2_COMM.setValue(getprop("/instrumentation/comm[1]/frequencies/selected-mhz")*1000);
    print("VHF-22 ... OK");
    });

setlistener("/instrumentation/VHF-22/standby1", func(sb1){
    SB1.setValue(sb1.getValue() * 0.001);
    },0,0);

setlistener("/instrumentation/VHF-22/standby2", func(sb2){
    SB2.setValue(sb2.getValue() * 0.001);
    },0,0);

setlistener("/instrumentation/VHF-22/comm1", func(cm1){
    COMM1.setValue(cm1.getValue() * 0.001);
    },0,0);

setlistener("/instrumentation/VHF-22/comm2", func(cm2){
    COMM2.setValue(cm2.getValue() * 0.001);
    },0,0);
