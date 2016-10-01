var davtron=props.globals.getNode("/instrumentation/clock/m877",1);
var set_hour=davtron.getNode("set-hour",1);
var set_min=davtron.getNode("set-min",1);
var mode=davtron.getNode("mode",1);
var modestring =davtron.getNode("mode-string",1);
var modetext =["GMT","LT","FT","ET"];
var HR=davtron.getNode("indicated-hour",1);
var MN=davtron.getNode("indicated-min",1);
var MODE = 0;

setlistener("/sim/signals/fdm-initialized", func {
    set_hour.setBoolValue(0);
    set_min.setBoolValue(0);
    mode.setIntValue(MODE);
    modestring.setValue(modetext[MODE]);
    HR.setIntValue(0);
    MN.setIntValue(0);
    print("Chronometer ... Check");
    settimer(update_clock,2);
});

setlistener("/instrumentation/clock/m877/mode", func(md) {
    MODE = md.getValue();
    modestring.setValue(modetext[MODE]);
},0,0);

var update_clock = func{
    var FThr =getprop("/instrumentation/clock/flight-meter-hour");
    
    var FM =0;
    if (MODE == 0) {
    setprop("/instrumentation/clock/m877/indicated-hour",getprop("/instrumentation/clock/indicated-hour"));
    setprop("/instrumentation/clock/m877/indicated-min",getprop("/instrumentation/clock/indicated-min"));
    }

    if (MODE == 1) {
    setprop("/instrumentation/clock/m877/indicated-hour",getprop("/instrumentation/clock/local-hour"));
    setprop("/instrumentation/clock/m877/indicated-min",getprop("/instrumentation/clock/indicated-min"));
    }

    if (MODE == 2) {
    setprop("/instrumentation/clock/m877/indicated-hour",FThr);
    FH = getprop("/instrumentation/clock/m877/indicated-hour");
    FM = FThr - FH;
    FM = FM * 60;
    setprop("/instrumentation/clock/m877/indicated-min",FM);
    }

    if (MODE == 3) {
    var ETH = getprop("/instrumentation/clock/ET-hr");
    if(ETH != nil){
        setprop("/instrumentation/clock/m877/indicated-hour",getprop("/instrumentation/clock/ET-hr"));
        setprop("/instrumentation/clock/m877/indicated-min",getprop("/instrumentation/clock/ET-min"));
        }
    }

settimer(update_clock,0);
}