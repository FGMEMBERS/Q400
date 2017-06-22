# Q400 Hydraulic System
# Joshua Davidson (it0uchpods); D-ECHO

######
#Description
#There are 4 hydraulic systems: three main one auxiliary
#No. 1 and No.2:
#   -3000PSI
#   -seperated, PTU avail
#   -both supply power to: elevators (lh, rh), rudder
#No.1 supplies power to flaps, inboard roll spoilers, normal brakes(anti-skid)
#   -8 US Quarts capacity
#   -Engine Driven Pump (EDP1) and Standby Power Unit(SPU)
#No.2 supplies power to outboard roll spoilers, nose wheel steering, emergency/park brakes, landing gear extension
#   -12 US Quarts capacity
#   -Engine Driven Pump (EDP2) only
#No. 3:
#   -jumps in when no.1 and/or no.2 fail 
#   -supplies power to elevators (lh, rh)
#   -accumulator-based DC motor pump (2600-3250PSI)
#   -2.6 US Quarts capacity
#Alternate Hydraulic System:
#   -1 US Quarts capacity
#   -driven by hand pump
#   -supplies main landing gear extension

#############
# Init Vars #
#############

var hyd_init = func {
	setprop("/controls/hydraulic/eng1-pump", 1);
	setprop("/controls/hydraulic/eng2-pump", 1);
	setprop("/controls/hydraulic/elec-pump-sys3", 1);
	setprop("/controls/hydraulic/ptu", 1);
	#setprop("/controls/hydraulic/rat-man", 0);
	#setprop("/controls/hydraulic/rat", 0);
	#setprop("/controls/hydraulic/rat-deployed", 0);
	setprop("/systems/hydraulic/ptu-active", 0);
	setprop("/systems/hydraulic/psi1", 0);
	setprop("/systems/hydraulic/psi2", 0);
	setprop("/systems/hydraulic/psi3", 0);
	setprop("/systems/hydraulic/spoiler3and4-inhibit", 0);
	setprop("/systems/hydraulic/spoiler-inhibit", 0);
	setprop("/controls/gear/brake-parking", 0);
	hyd_timer.start();
}

#######################
# Main Hydraulic Loop #
#######################

var master_hyd = func {
	var eng1_pump_sw = getprop("/controls/hydraulic/eng1-pump");
	var eng2_pump_sw = getprop("/controls/hydraulic/eng2-pump");
	var elec_pump_3_sw = getprop("/controls/hydraulic/elec-pump-sys3");
	var spu_sw = getprop("/controls/hydraulic/spu_sw");
	var spu_act = getprop("/controls/hydraulic/spu_act");
	var ptu_sw = getprop("/controls/hydraulic/ptu");
	var psi1 = getprop("/systems/hydraulic/psi1");
	var psi2 = getprop("/systems/hydraulic/psi2");
	var psi3 = getprop("/systems/hydraulic/psi3");
	var isol_valve_open3 = getprop("/controls/hydraulic/isol-valve3");
	var isol_valve_open_btn3 = getprop("/controls/hydraulic/isol-valve-btn3");
	var rpmapu = getprop("/engines/APU/rpm");
	var runningL = getprop("/engines/engine[0]/running");
	var runningR = getprop("/engines/engine[1]/running");
	var dc_ess = getprop("/systems/electrical/bus/dc-ess");
	var psi_diff = psi1 - psi2;
	var gs = getprop("/velocities/groundspeed-kt");
	var blue_leak = getprop("/systems/failures/hyd-blue") or 0;
	var green_leak = getprop("/systems/failures/hyd-green") or 0;
	var yellow_leak = getprop("/systems/failures/hyd-yellow")or 0;
	var blue_pump_fail = getprop("/systems/failures/pump-blue") or 0;
	var green_pump_fail = getprop("/systems/failures/pump-green") or 0;
	var yellow_pump_eng_fail = getprop("/systems/failures/pump-yellow-eng") or 0;
	var yellow_pump_elec_fail = getprop("/systems/failures/pump-yellow-elec") or 0;
	var ptu_fail = getprop("/systems/failures/ptu") or 0;
	var parkbrake = getprop("/controls/gear/brake-parking");
	var flaps = getprop("/controls/flight/flaps");
	var wow1 = getprop("/gear/gear[1]/wow");
	
	
	if (parkbrake==0 and flaps>0 and psi1>2400 or ptu_sw) {
		setprop("/systems/hydraulic/ptu-active", 1);
	} else{
		setprop("/systems/hydraulic/ptu-active", 0);
	}
	
	
	var ptu_active = getprop("/systems/hydraulic/ptu-active");
	
	if(spu_sw or !wow1 and !runningL or flaps>0 and !parkbrake){
            setprop("/controls/hydraulic/spu_act", 1);
        }else{
            setprop("/controls/hydraulic/spu_act", 0);
        }
        
	
        
        if(isol_valve_open_btn3 or !wow1 and !runningL and !runningR){
            setprop("/controls/hydraulic/isol-valve3", 1);
        }else{
            setprop("/controls/hydraulic/isol-valve3", 0);
        }
	
	if(eng1_pump_sw and runningL or spu_act){
            interpolate("/systems/hydraulic/psi1", 3000, 2);
        }else{
            interpolate("/systems/hydraulic/psi1", 0, 2);
        }
	
	if(eng2_pump_sw and runningR or psi1>2400 and ptu_active){
            interpolate("/systems/hydraulic/psi2", 3000, 2);
        }else{
            interpolate("/systems/hydraulic/psi2", 0, 2);
        }
        
        if(getprop("/systems/electrical/outputs/volts") or 0>20){
            interpolate("/systems/hydraulic/psi3", 3000, 2);
        }else{
            interpolate("/systems/hydraulic/psi3", 0, 2);
        }
        
        
        
        var gearDownInp = getprop("/controls/gear/gear-down");
        if(psi2>2900){
            setprop("/controls/gear/gear-down-int", gearDownInp);
        }
}

#######################
# Various Other Stuff #
#######################

setlistener("/controls/gear/gear-down", func {
	var down = getprop("/controls/gear/gear-down");
	if (!down and (getprop("/gear/gear[0]/wow") or getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow"))) {
		setprop("/controls/gear/gear-down", 1);
	}
});

###################
# Update Function #
###################

var update_hydraulic = func {
	master_hyd();
}

var hyd_timer = maketimer(0.2, update_hydraulic);



setlistener("/sim/signals/fdm-initialized", func{
    hyd_init();
    print("Hydraulic system loaded");
});
