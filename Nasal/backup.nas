electrical_bus = func(bv) {
    var bus_volts = bv;
    var load = 0.0;
    var srvc = 0.0;
    var starter_volts = 0.0;
    var starter_volts1 = 0.0;
    var start_n2_0 = 0.0;
    var start_n2_1 = 0.0;

    var internal_starter = getprop("controls/engines/internal-engine-starter");
    var if_engine0_running = getprop("engines/engine[0]/running");
    var if_engine1_running = getprop("engines/engine[1]/running");
    var if_engine0_serviceable = getprop("engines/engine[0]/serviceable");
    var if_engine1_serviceable = getprop("engines/engine[1]/serviceable");
    var if_engine0_cutoff = getprop("controls/engines/engine[0]/cutoff");    
    var if_engine1_cutoff = getprop("controls/engines/engine[1]/cutoff");
    var aft_boost = getprop("controls/electric/aft-boost-pump");
    var fwd_boost = getprop("controls/electric/fwd-boost-pump");
    var aft_boost_pumps_volts = bus_volts * aft_boost;
    var fwd_boost_pumps_volts = bus_volts * fwd_boost;
    
    if (internal_starter == 0) {
        increasing_counter0 = 0.0;
        increasing_counter1 = 0.0;
    }

    if (internal_starter < 0) {
       	internal_starter = -internal_starter;
	starter_volts1 = bus_volts * internal_starter;
    } else if (internal_starter > 0) {
       	starter_volts = bus_volts * internal_starter;
    }
    
    load += internal_starter * 5;
        start_n2_0 += starter_volts * 0.7;
    
    var increasing0 = func {
        if (getprop("engines/engine[0]/n2") < start_n2_0) {
            increasing_counter0 = increasing_counter0 + 0.0005;
       	    setprop("engines/engine[0]/n2", increasing_counter0);
	    settimer(increasing0, 0);
        }
    }

    if (getprop("engines/engine[0]/n2") < start_n2_0) {
        increasing0();
    }
    
    load += internal_starter * 5;
    start_n2_1 += starter_volts1 * 0.7;
    
    var increasing1 = func {
        if (getprop("engines/engine[1]/n2") < start_n2_1) {
            increasing_counter1 = increasing_counter1 + 0.0005;
       	    setprop("engines/engine[1]/n2", increasing_counter1);
	    settimer(increasing1, 0);
        }
    }

    if (getprop("engines/engine[1]/n2") < start_n2_1) {
        increasing1();
    }
    
    var internal_condition0 = getprop("controls/engines/engine[0]/condition");
    var internal_condition1 = getprop("controls/engines/engine[1]/condition");
    var min_n2_0 = getprop("engines/engine[0]/n2");
    var min_n2_1 = getprop("engines/engine[1]/n2");


    var fuel_rich_func0 = func {
        if (if_engine0_running == 0 and fuel_rich0 <= 200 and fuel_rich0>=0) {
            fuel_rich0 =  fuel_rich0 - min_n2_0 + (internal_condition0 * 20);
	    settimer(fuel_rich_func0, 1);
	}
    }

    var fuel_rich_func1 = func {
        if (if_engine1_running == 0 and fuel_rich1 <= 200 and fuel_rich1>=0) {
            fuel_rich1 =  fuel_rich1 - min_n2_1 + (internal_condition1 * 20);
	    settimer(fuel_rich_func1, 1);
	}
    }

    if (fuel_rich0 >200) {
        fuel_rich0 = 200;
    } else if (fuel_rich0 <0) {
        fuel_rich0 = 0;
    }

    
    if (fuel_rich1 >200) {
        fuel_rich1 = 200;
    } else if (fuel_rich1 <0) {
        fuel_rich1 = 0;
    }

    fuel_rich_func0();
    fuel_rich_func1();

    if_engine0_running = getprop("engines/engine[0]/running");
    if_engine1_running = getprop("engines/engine[1]/running");

    if (getprop("engines/engine[0]/n2") >= 12 and internal_condition0 > 0 and fuel_rich0 < 25 and fwd_boost != 0 and if_engine0_serviceable and if_engine0_cutoff==0 and internal_condition0>0.382 and !getprop("sim/model/equipment/left-engine-cover")) {
       setprop("controls/engines/engine[0]/internal-condition", 1);
    } else {
       setprop("controls/engines/engine[0]/internal-condition", 0);
    }

    if (getprop("engines/engine[1]/n2") >= 12 and internal_condition1 > 0 and fuel_rich1 < 25 and aft_boost != 0  and if_engine1_serviceable and if_engine1_cutoff==0 and internal_condition1>0.382 and !getprop("sim/model/equipment/right-engine-cover")) {
       setprop("controls/engines/engine[1]/internal-condition", 1);
    } else {
       setprop("controls/engines/engine[1]/internal-condition", 0);
    }
    
    var starter_total_volts = starter_volts + starter_volts1;
    
    setprop(outPut~"starter",starter_total_volts); 
    setprop(outPut~"aft-boost-pumps",aft_boost_pumps_volts); 
    setprop(outPut~"fwd-boost-pumps",fwd_boost_pumps_volts); 

    for(var i=0; i<size(switch_list); i+=1) {
        var srvc = getprop(switch_list[i]);
        load +=srvc;
        setprop(outPut~output_list[i],bus_volts * srvc);
    }
    setprop(outPut~"flaps",bus_volts);

    return load;
}