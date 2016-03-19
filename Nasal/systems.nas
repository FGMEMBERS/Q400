####	DHC8-400 systems	####
aircraft.livery.init("Aircraft/dhc8-400/models/Liveries"); 
#EFIS specific class
# ie: var efis = EFIS.new("instrumentation/EFIS");
var EFIS = {
    new : func(prop1){
        m = { parents : [EFIS]};
        m.mfd_mode_list=["APP","VOR","MAP","PLAN"];
        m.eicas_msg=[];
        m.eicas_msg_red=[];
        m.eicas_msg_green=[];
        m.eicas_msg_blue=[];
        m.eicas_msg_alpha=[];

        m.efis = props.globals.initNode(prop1);
        m.mfd = m.efis.initNode("mfd");
        m.pfd = m.efis.initNode("pfd");
        m.eicas = m.efis.initNode("eicas");
        m.mfd_mode_num = m.mfd.initNode("mode-num",2,"INT");
        m.mfd_display_mode = m.mfd.initNode("display-mode",m.mfd_mode_list[2]);
        m.kpa_mode = m.efis.initNode("inputs/kpa-mode",0,"BOOL");
        m.kpa_output = m.efis.initNode("inhg-kpa",29.92);
        m.temp = m.efis.initNode("fixed-temp",0);
        m.alt_meters = m.efis.initNode("inputs/alt-meters",0,"BOOL");
        m.fpv = m.efis.initNode("inputs/fpv",0,"BOOL");
        m.nd_centered = m.efis.initNode("inputs/nd-centered",0,"BOOL");
        m.mins_mode = m.efis.initNode("inputs/minimums-mode",0,"BOOL");
        m.minimums = m.efis.initNode("minimums",200,"INT");
        m.mk_minimums = props.globals.getNode("instrumentation/mk-viii/inputs/arinc429/decision-height");
        m.wxr = m.efis.initNode("inputs/wxr",0,"BOOL");
        m.range = m.efis.initNode("inputs/range",0);
        m.sta = m.efis.initNode("inputs/sta",0,"BOOL");
        m.wpt = m.efis.initNode("inputs/wpt",0,"BOOL");
        m.arpt = m.efis.initNode("inputs/arpt",0,"BOOL");
        m.data = m.efis.initNode("inputs/data",0,"BOOL");
        m.pos = m.efis.initNode("inputs/pos",0,"BOOL");
        m.terr = m.efis.initNode("inputs/terr",0,"BOOL");
        m.rh_vor_adf = m.efis.initNode("inputs/rh-vor-adf",0,"INT");
        m.lh_vor_adf = m.efis.initNode("inputs/lh-vor-adf",0,"INT");

        m.kpaL = setlistener("instrumentation/altimeter/setting-inhg", func m.calc_kpa());

        for(var i=0; i<11; i+=1) {
        append(m.eicas_msg,m.eicas.initNode("msg["~i~"]/text"," ","STRING"));
        append(m.eicas_msg_red,m.eicas.initNode("msg["~i~"]/red",0.1 *i));
        append(m.eicas_msg_green,m.eicas.initNode("msg["~i~"]/green",0.8));
        append(m.eicas_msg_blue,m.eicas.initNode("msg["~i~"]/blue",0.8));
        append(m.eicas_msg_alpha,m.eicas.initNode("msg["~i~"]/alpha",1.0));
        }

    return m;
    },
#### convert inhg to kpa ####
    calc_kpa : func{
        var kp = getprop("instrumentation/altimeter/setting-inhg");
        kp= kp * 33.8637526;
        me.kpa_output.setValue(kp);
        },
#### update temperature display ####
    update_temp : func{
        var tmp = getprop("/environment/temperature-degc");
        if(tmp < 0.00){
            tmp = -1 * tmp;
        }
        me.temp.setValue(tmp);
    },
######### Controller buttons ##########
    ctl_func : func(md,val){
        if(md=="range")
        {
            var rng =getprop("instrumentation/radar/range");
            if(val ==1){
                rng =rng * 2;
                if(rng > 640) rng = 640;
            }elsif(val =-1){
                rng =rng / 2;
                if(rng < 10) rng = 10;
            }
            setprop("instrumentation/radar/range",rng);
            me.range.setValue(rng);
        }
        elsif(md=="tfc")
        {
            var pos =getprop("instrumentation/radar/switch");
            if(pos == "on"){
                pos = "off";
                
            }else{
                pos="on";
            }
            setprop("instrumentation/radar/switch",pos);
        }
        elsif(md=="dh")
        {
            var num =me.minimums.getValue();
            if(val==0){
                num=200;
            }else{
                num+=val;
                if(num<0)num=0;
                if(num>1000)num=1000;
            }
        me.minimums.setValue(num);
        me.mk_minimums.setValue(num);
        }
        elsif(md=="display")
        {
            var num =me.mfd_mode_num.getValue();
            num+=val;
            if(num<0)num=0;
            if(num>3)num=3;
            me.mfd_mode_num.setValue(num);
            me.mfd_display_mode.setValue(me.mfd_mode_list[num]);
        }
        elsif(md=="terr")
        {
            var num =me.terr.getValue();
            num=1-num;
            me.terr.setValue(num);
        }
        elsif(md=="arpt")
        {
            var num =me.arpt.getValue();
            num=1-num;
            me.arpt.setValue(num);
        }
        elsif(md=="wpt")
        {
            var num =me.wpt.getValue();
            num=1-num;
            me.wpt.setValue(num);
        }
        elsif(md=="sta")
        {
            var num =me.sta.getValue();
            num=1-num;
            me.sta.setValue(num);
        }
        elsif(md=="wxr")
        {
            var num =me.wxr.getValue();
            num=1-num;
            me.wxr.setValue(num);
        }
        elsif(md=="rhvor")
        {
            var num =me.rh_vor_adf.getValue();
            num+=val;
            if(num>1)num=1;
            if(num<-1)num=-1;
            me.rh_vor_adf.setValue(num);
        }
        elsif(md=="lhvor")
        {
            var num =me.lh_vor_adf.getValue();
            num+=val;
            if(num>1)num=1;
            if(num<-1)num=-1;
            me.lh_vor_adf.setValue(num);
        }
        elsif(md=="center")
        {
            var num =me.nd_centered.getValue();
            var fnt=[5,8];
            num = 1 - num;
            me.nd_centered.setValue(num);
            setprop("instrumentation/radar/font/size",fnt[num]);
        }
    },
};

var w_fctr=0;
var pph1 = 0.0;
var pph2 = 0.0;
var fuel_density=0.0;
var ViewNum = 0.0;
var WiperPos = props.globals.getNode("controls/electric/wipers/position-norm");
var WiperSwitch = props.globals.getNode("controls/electric/wipers/switch");
S_volume = "sim/sound/E_volume";
C_volume = "sim/sound/cabin";
var Oiltemp1="engines/engine[0]/oil-temp-c";
var Oiltemp2="engines/engine[1]/oil-temp-c";

var FHmeter = aircraft.timer.new("/instrumentation/clock/flight-meter-sec", 10);

setlistener("/sim/signals/fdm-initialized", func {
    setprop(S_volume,0.3);
    setprop(C_volume,0.3);
    fuel_density=props.globals.getNode("consumables/fuel/tank[0]/density-ppg").getValue();
    setprop("/instrumentation/clock/flight-meter-hour",0);
    setprop("controls/gear/water-rudder-down",0);
    setprop("controls/gear/water-rudder-pos",0);
    setprop(,0);
    print("system  ...Check");
    setprop("controls/engines/engine/condition",0);
    setprop("controls/engines/engine/condition",0);
    setprop("controls/engines/engine[1]/condition",0);
    setprop(Oiltemp1,getprop("environment/temperature-degc"));
    settimer(update_systems, 2);
    });

setlistener("/engines/engine/out-of-fuel", func(nf){
    if(nf.getValue() != 0){
        fueltanks = props.globals.getNode("consumables/fuel").getChildren("tank");
        foreach(f; fueltanks) {
            if(f.getNode("selected", 1).getBoolValue()){
                if(f.getNode("level-lbs").getValue() > 0.01){
                    setprop("/engines/engine/out-of-fuel",0);
                }
            }
        }
    }
},0,0);

setlistener("/sim/current-view/view-number", func(vw){
    ViewNum = vw.getValue();
    if(ViewNum == 0){
        setprop(S_volume,0.3);
        setprop(C_volume,0.3);
        }else{
            setprop(S_volume,0.9);
            setprop(C_volume,0.05);
        }
},0,0);

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

setlistener("/gear/gear[1]/wow", func(gr){
    if(gr.getBoolValue()){
    FHmeter.stop();
    }else{FHmeter.start();}
},0,0);


var Startup = func{
setprop("controls/electric/engine[0]/generator",1);
setprop("controls/electric/engine[1]/generator",1);
setprop("controls/electric/avionics-switch",1);
setprop("controls/electric/battery-switch",1);
setprop("controls/electric/inverter-switch",1);
setprop("controls/lighting/instrument-lights",1);
setprop("controls/lighting/nav-lights",1);
setprop("controls/lighting/beacon",1);
setprop("controls/lighting/strobe",1);
setprop("controls/engines/engine[0]/condition-lever",1);
setprop("controls/engines/engine[1]/condition-lever",1);
setprop("controls/engines/engine[0]/mixture",1);
setprop("controls/engines/engine[1]/mixture",1);
setprop("controls/engines/engine[0]/propeller-pitch",1);
setprop("controls/engines/engine[1]/propeller-pitch",1);
setprop("engines/engine[0]/running",1);
setprop("engines/engine[1]/running",1);
}

var Shutdown = func{
setprop("controls/electric/engine[0]/generator",0);
setprop("controls/electric/engine[1]/generator",0);
setprop("controls/electric/avionics-switch",0);
setprop("controls/electric/battery-switch",0);
setprop("controls/electric/inverter-switch",0);
setprop("controls/lighting/instrument-lights",0);
setprop("controls/lighting/nav-lights",0);
setprop("controls/lighting/beacon",0);
setprop("controls/lighting/strobe",0);
setprop("controls/engines/engine[0]/condition-lever",0);
setprop("controls/engines/engine[1]/condition-lever",0);
setprop("controls/engines/engine[0]/mixture",0);
setprop("controls/engines/engine[1]/mixture",0);
setprop("controls/engines/engine[0]/propeller-pitch",0);
setprop("controls/engines/engine[1]/propeller-pitch",0);
setprop("engines/engine[0]/running",0);
setprop("engines/engine[1]/running",0);
}

var wipers_on = func{
    var wiper_pos=WiperPos.getValue();
    if(wiper_pos >= 1.000) {
    w_fctr =-1;
    }else{
    if(wiper_pos <= 0.000) w_fctr =1;
    }
    
    if(!WiperSwitch.getValue()){
    if(wiper_pos <=0.0)return;
    }
    var wiper_time = getprop("/sim/time/delta-realtime-sec");
    wiper_pos += (wiper_time * w_fctr);
    WiperPos.setValue(wiper_pos);
}

var update_systems = func {
        var power = getprop("/controls/switches/master-panel");
        pph1 = getprop("/engines/engine[0]/fuel-flow-gph");
        pph2 = getprop("/engines/engine[1]/fuel-flow-gph");
        if(pph1 == nil){pph1 = 6.72;}
        if(pph2 == nil){pph2 = 6.72;}
        setprop("engines/engine[0]/fuel-flow-pph",pph1* fuel_density);
        setprop("engines/engine[1]/fuel-flow-pph",pph2* fuel_density);
    flight_meter();
    oil_temp();
    wipers_on();

    if(getprop("controls/engines/engine[0]/cutoff")){
        setprop("controls/engines/engine[0]/condition",0);
        setprop("engines/engine[0]/running",0);
        }else{
            setprop("controls/engines/engine[0]/condition",getprop("controls/engines/engine[0]/condition-lever"));
        }
    if(getprop("controls/engines/engine[1]/cutoff")){
        setprop("controls/engines/engine[1]/condition",0);
        setprop("engines/engine[1]/running",0);
    }else{
        setprop("controls/engines/engine[1]/condition",getprop("controls/engines/engine[1]/condition-lever"));
    }
    if(getprop("controls/gear/water-rudder-down")){
        setprop("controls/gear/water-rudder-pos",getprop("controls/flight/rudder"));
    }else{
        setprop("controls/gear/water-rudder-pos",0);
    }
    settimer(update_systems, 0);
}

var flight_meter = func{
var fmeter = getprop("/instrumentation/clock/flight-meter-sec");
var fminute = fmeter * 0.016666;
var fhour = fminute * 0.016666;
setprop("/instrumentation/clock/flight-meter-hour",fhour);
}


var oil_temp = func{
var Air_temp= getprop("environment/temperature-degc");
var OT1= getprop(Oiltemp1);
if(OT1 == nil)OT1=0;
var OT2= getprop(Oiltemp2);
if(OT2 == nil)OT2=0;

if(getprop("engines/engine[0]/running")){
    if(OT1 < getprop("engines/engine[0]/n2"))setprop(Oiltemp1,OT1+0.01);
    }else{
        if(OT1 > Air_temp)setprop(Oiltemp1,OT1-0.001);
    }

if(getprop("engines/engine[1]/running")){
    if(OT2 < getprop("engines/engine[1]/n2"))setprop(Oiltemp2,OT2+0.01);
    }else{
        if(OT2 > Air_temp)setprop(Oiltemp2,OT2-0.001);
    }
}

