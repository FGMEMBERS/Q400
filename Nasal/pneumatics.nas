# Q400 Pneumatic System
# D-ECHO based on Joshua Davidson (it0uchpods) and Jonathan Redpath (legoboyvdlp)

#############
# Init Vars #
#############

var pneu_init = func {
	setprop("/controls/pneumatic/switches/bleed1", 1);
	setprop("/controls/pneumatic/switches/bleed2", 1);
	setprop("/controls/pneumatic/switches/groundair", 0);
	setprop("/controls/pneumatic/switches/pack1", 1);
	setprop("/controls/pneumatic/switches/pack2", 1);
	setprop("/controls/pneumatic/switches/hot-air", 1);
	setprop("/controls/pneumatic/switches/ram-air", 0);
	setprop("/controls/pneumatic/switches/pack-flo", 9); # LO: 7, NORM: 9, HI: 11.
	setprop("/controls/pressurization/auto", 1);
	setprop("/systems/pneumatic/bleed1", 0);
	setprop("/systems/pneumatic/bleed2", 0);
	setprop("/systems/pneumatic/bleedapu", 0);
	setprop("/systems/pneumatic/groundair", 0);
	setprop("/systems/pneumatic/total-psi", 0);
	setprop("/systems/pneumatic/start-psi", 0);
	setprop("/systems/pneumatic/pack-psi", 0);	
	setprop("/systems/pneumatic/pack1", 0);
	setprop("/systems/pneumatic/pack2", 0);
	setprop("/systems/pneumatic/startpsir", 0);
	setprop("/FMGC/internal/dep-arpt", "");
	setprop("/systems/pressurization/mode", "GN");
	setprop("/systems/pressurization/vs", "0");
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/pressurization/vs-norm", "0");
	setprop("/systems/pressurization/auto", 1);
	setprop("/systems/pressurization/deltap", "0");
	setprop("/systems/pressurization/outflowpos", "0");
	setprop("/systems/pressurization/deltap-norm", "0");
	setprop("/systems/pressurization/outflowpos-norm", "0");
	var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	setprop("/systems/pressurization/cabinalt", altitude);
	setprop("/systems/pressurization/targetalt", altitude); 
	setprop("/systems/pressurization/diff-to-target", "0");
	setprop("/systems/pressurization/ditchingpb", 0);
	setprop("/systems/pressurization/targetvs", "0");
	setprop("/systems/ventilation/cabin/fans", 0); # aircon fans
	setprop("/systems/ventilation/avionics/fan", 0);
	setprop("/systems/ventilation/avionics/extractvalve", "0");
	setprop("/systems/ventilation/avionics/inletvalve", "0");
	setprop("/systems/ventilation/lavatory/extractfan", 0);
	setprop("/systems/ventilation/lavatory/extractvalve", "0");
	setprop("/systems/pressurization/ambientpsi", "0");
	setprop("/systems/pressurization/cabinpsi", "0");
	pneu_timer.start();
}

#######################
# Main Pneumatic Loop #
#######################

var master_pneu = func {
	var bleed1_sw = getprop("/controls/pneumatic/switches/bleed1");
	var bleed2_sw = getprop("/controls/pneumatic/switches/bleed2");
	var bleedapu_sw = getprop("/controls/APU/bleedair");
	var pack1_sw = getprop("/controls/pneumatic/switches/pack1");
	var pack2_sw = getprop("/controls/pneumatic/switches/pack2");
	var hot_air_sw = getprop("/controls/pneumatic/switches/hot-air");
	var ram_air_sw	= getprop("/controls/pneumatic/switches/ram-air");
	var pack_flo_sw = getprop("/controls/pneumatic/switches/pack-flo");
	var groundair = getprop("/systems/pneumatic/groundair");
	var groundair_supp = getprop("/controls/pneumatic/switches/groundair");
	var rpmapu = getprop("/engines/APU/rpm");
	var runningL = getprop("/engines/engine[0]/running");
	var runningR = getprop("/engines/engine[1]/running");
	var bleedapu_fail = getprop("/systems/failures/bleed-apu") or 0;
	var bleedext_fail = getprop("/systems/failures/bleed-ext")or 0;
	var bleedeng1_fail = getprop("/systems/failures/bleed-eng1")or 0;
	var bleedeng2_fail = getprop("/systems/failures/bleed-eng2")or 0;
	var pack1_fail = getprop("/systems/failures/pack1") or 0;
	var pack2_fail = getprop("/systems/failures/pack2") or 0;
	
	# Air Sources/PSI
	if (rpmapu >= 95 and bleedapu_sw and !bleedapu_fail) {
		setprop("/systems/pneumatic/bleedapu", 34);
	} else {
		setprop("/systems/pneumatic/bleedapu", 0);
	}
	
	if (runningL and bleed1_sw and !bleedeng1_fail) {
		setprop("/systems/pneumatic/bleed1", 31);
	} else {
		setprop("/systems/pneumatic/bleed1", 0);
	}
	
	if (runningR and bleed2_sw and !bleedeng2_fail) {
		setprop("/systems/pneumatic/bleed2", 32);
	} else {
		setprop("/systems/pneumatic/bleed2", 0);
	}
	
	var bleed1 = getprop("/systems/pneumatic/bleed1");
	var bleed2 = getprop("/systems/pneumatic/bleed2");
	var bleedapu = getprop("/systems/pneumatic/bleedapu");
	var ground = getprop("/systems/pneumatic/groundair");
	
	if (pack1_sw == 1 and (bleed1 >= 20 or bleedapu >= 20 or ground >= 20) and !pack1_fail) {
		setprop("/systems/pneumatic/pack1", pack_flo_sw);
	} else {
		setprop("/systems/pneumatic/pack1", 0);
	}
	
	if (pack2_sw == 1 and (bleed2 >= 20 or bleedapu >= 20) and !pack2_fail) {
		setprop("/systems/pneumatic/pack2", pack_flo_sw);
	} else {
		setprop("/systems/pneumatic/pack2", 0);
	}
	
	var pack1 = getprop("/systems/pneumatic/pack1");
	var pack2 = getprop("/systems/pneumatic/pack2");
	
	if (pack1_sw == 1 and pack2_sw == 1) {
		setprop("/systems/pneumatic/pack-psi", pack1 + pack2);
	} else if (pack1_sw == 0 and pack2_sw == 0) {
		setprop("/systems/pneumatic/pack-psi", 0);
	} else {
		setprop("/systems/pneumatic/pack-psi", pack1 + pack2 + 5);
	}
	
	var pack_psi = getprop("/systems/pneumatic/pack-psi");
	var start_psi = getprop("/systems/pneumatic/start-psi");
	
	if ((bleed1 + bleed2 + bleedapu) > 42) {
		setprop("/systems/pneumatic/total-psi", 42);
	} else {
		var total_psi_calc = ((bleed1 + bleed2 + bleedapu + ground) - start_psi - pack_psi);
		setprop("/systems/pneumatic/total-psi", total_psi_calc);
	}
	
	if (groundair_supp) {
		setprop("/systems/pneumatic/groundair", 39);
	} else {
		setprop("/systems/pneumatic/groundair", 0);
	}
	
	var total_psi = getprop("/systems/pneumatic/total-psi");
	
	var phase = getprop("/FMGC/status/phase");
	var pressmode = getprop("/systems/pressurization/mode");
	var wowl = getprop("/gear/gear[1]/wow");
	var wowr = getprop("/gear/gear[2]/wow");
	var deltap = getprop("/systems/pressurization/deltap");
	var outflow = getprop("/systems/pressurization/outflowpos"); 
	var speed = getprop("/velocities/groundspeed-kt");
	var altitude = getprop("/instrumentation/altimeter/indicated-altitude-ft");
	var airport_arr_elev_ft = getprop("autopilot/route-manager/destination/field-elevation-ft");
	var vs = getprop("/systems/pressurization/vs-norm");
	var ditch = getprop("/systems/pressurization/ditchingpb");
	var outflowpos = getprop("/systems/pressurization/outflowpos");
	var cabinalt = getprop("/systems/pressurization/cabinalt");
	var targetalt = getprop("/systems/pressurization/targetalt");
	var targetvs = getprop("/systems/pressurization/targetvs");
	var ambient = getprop("/systems/pressurization/ambientpsi");
	var cabinpsi = getprop("/systems/pressurization/cabinpsi");
	var pause = getprop("/sim/freeze/master");
	var auto = getprop("/systems/pressurization/auto");
	
	setprop("/systems/pressurization/diff-to-target", targetalt - cabinalt); 
	setprop("/systems/pressurization/deltap", cabinpsi - ambient); 

	#if ((pressmode == "GN") and (pressmode != "CL") and (wowl and wowr) and ((state1 == "MCT") or (state1 == "TOGA")) and ((state2 == "MCT") or (state2 == "TOGA"))) {
	#	setprop("/systems/pressurization/mode", "TO");
	#} else if (((!wowl) or (!wowr)) and (speed > 100) and (pressmode == "TO")) {
	#	setprop("/systems/pressurization/mode", "CL");	
	#}
	
	if (vs != targetvs and !wowl and !wowr) {
		setprop("/systems/pressurization/vs", targetvs);
	}
	
	if (cabinalt != targetalt and !wowl and !wowr and !pause) {
		setprop("/systems/pressurization/cabinalt", cabinalt + ((vs / 60) / 10));
	}
	
	if (ditch and auto) {
		setprop("/systems/pressurization/outflowpos", "1");
		setprop("/systems/ventilation/avionics/extractvalve", "1");
		setprop("/systems/ventilation/avionics/inletvalve", "1");
	}
	
	var dcess = getprop("/systems/electrical/bus/dc-ess");
	var acess = getprop("/systems/electrical/bus/ac-ess");
	var fanon = getprop("/systems/ventilation/avionics/fan");
	
#	if ((dcess > 25) or (acess > 110)) {
#		setprop("/systems/ventilation/avionics/fan", 1);
#		setprop("/systems/ventilation/lavatory/extractfan", 1);
#	} else if ((dcess == 0) and (acess == 0)) {
#		setprop("/systems/ventilation/avionics/fan", 0);
#		setprop("/systems/ventilation/lavatory/extractfan", 0);
#	}
}

###################
# Update Function #
###################

var update_pneumatic = func {
	master_pneu();
}

var pneu_timer = maketimer(0.2, update_pneumatic);

setlistener("/sim/signals/fdm-initialized", func{
    pneu_init();
    print("Pneumatic system loaded");
});

