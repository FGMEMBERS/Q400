setlistener("/sim/signals/fdm-initialized", func{
    settimer(update_APU, 1);
    print("APU System loaded");
});

setlistener("/controls/APU/start", func{
    if(getprop("controls/APU/master")==1 and getprop("/systems/electrical/volts")>20) {
        interpolate("/engines/APU/rpm", 25, 5);
    }
});

setlistener("/engines/APU/rpm" , func{
    if(getprop("/engines/APU/rpm")==25){
        setprop("/controls/APU/start", 0);
        setprop("/engines/APU/running", 1);
        setprop("/controls/APU/power-btn", 1);
    }else{
        setprop("/engines/APU/running", 0);
        setprop("/controls/APU/power-btn", 0);
    }
});

setlistener("/controls/APU/master", func{
    #Initiate APU selftest
    if(getprop("controls/APU/master")==1){
        interpolate("controls/APU/selftest", 8, 3);
    }
});

var update_APU = func{
    var master=getprop("/controls/APU/master");
    var running=getprop("/engines/APU/running");
    var start=getprop("/controls/APU/start");
    var blair=getprop("/controls/APU/bleedair");
    var generator=getprop("/controls/APU/generator");
    var selftest=getprop("/controls/APU/selftest");
    
    
    #APU selftest
    if(selftest>0.25 and selftest<0.75){
        setprop("/controls/APU/power-btn-tst", 1);
    }else if(selftest>1.25 and selftest<1.75){
        setprop("/controls/APU/power-btn-tst", 2);
    }else{
        setprop("/controls/APU/power-btn-tst", 0);
    }
    
    if(selftest>2.25 and selftest<2.75){
        setprop("/controls/APU/start-btn-tst", 1);
    }else{
        setprop("/controls/APU/start-btn-tst", 0);
    }
    
    if(selftest>3.25 and selftest<3.75){
        setprop("/controls/APU/gen-btn-tst", 1);
    }else if(selftest>4.25 and selftest<4.75){
        setprop("/controls/APU/gen-btn-tst", 2);
    }else{
        setprop("/controls/APU/gen-btn-tst", 0);
    }
    
    if(selftest>5.25 and selftest<5.75){
        setprop("/controls/APU/bleedair-tst", 1);
    }else{
        setprop("/controls/APU/bleedair-tst", 0);
    }
    
    if(selftest>6.25 and selftest<6.75){
        setprop("/controls/APU/gen-oht-tst", 1);
    }else{
        setprop("/controls/APU/gen-oht-tst", 0);
    }
    
    if(selftest==8){
        setprop("/controls/APU/selftest", 0);
    }
    
    
    if(running and !master){
        interpolate("/engines/APU/rpm", 0, 5);
    }
    
    if(running and generator){
        setprop("/engines/APU/plugged", 1);
    }else{
        setprop("/engines/APU/plugged", 0);
    }
    
    if(running and !generator){
        setprop("/controls/APU/gen-btn", 2);
    }else if(running and generator){
        setprop("/controls/APU/gen-btn", 1);
    }else{
        setprop("/controls/APU/gen-btn", 0);
    }
    
        
    
    settimer(update_APU, 0);
}