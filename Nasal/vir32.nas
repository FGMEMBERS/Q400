####    VIR-22 NAV reciever   ####
####    Syd Adams    ####

var VIR = props.globals.getNode("/instrumentation/VIR-32",1);
var VR1_STBY = VIR.getNode("standby1",1);
var VR2_STBY = VIR.getNode("standby2",1);
var VR1_NAV = VIR.getNode("nav1",1);
var VR2_NAV = VIR.getNode("nav2",1);

var STBY1=props.globals.getNode("/instrumentation/nav/frequencies/standby-mhz");
var STBY2=props.globals.getNode("/instrumentation/nav[1]/frequencies/standby-mhz");
var NAV1=props.globals.getNode("/instrumentation/nav/frequencies/selected-mhz");
var NAV2=props.globals.getNode("/instrumentation/nav[1]/frequencies/selected-mhz");


setlistener("/sim/signals/fdm-initialized", func {
    VR1_STBY.setValue(getprop("/instrumentation/nav/frequencies/standby-mhz")*100);
    VR2_STBY.setValue(getprop("/instrumentation/nav[1]/frequencies/standby-mhz")*100);
    VR1_NAV.setValue(getprop("/instrumentation/nav/frequencies/selected-mhz")*100);
    VR2_NAV.setValue(getprop("/instrumentation/nav[1]/frequencies/selected-mhz")*100);
    print("VIR-32 ... OK");
    });

setlistener("/instrumentation/VIR-32/standby1", func(sb1){
    STBY1.setValue(sb1.getValue() * 0.01);
    },0,0);

setlistener("/instrumentation/VIR-32/standby2", func(sb2){
    STBY2.setValue(sb2.getValue() * 0.01);
    },0,0);

setlistener("/instrumentation/VIR-32/nav1", func(nm1){
    NAV1.setValue(nm1.getValue() * 0.01);
    },0,0);

setlistener("/instrumentation/VIR-32/nav2", func(nm2){
    NAV2.setValue(nm2.getValue() * 0.01);
    },0,0);
