###############################################################################
## $Id: dhc8-400-dual-control.nas,v 1.1 2009/12/21 05:26:54 sydadams Exp $
##
## Nasal for MP-passenger on the Dhc-400 over the multiplayer network.
## Adapted by Alex Park ori,ginal
##  Copyright (C) 2009  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

# Renaming (almost :)
var DCT = dual_control_tools;

######################################################################
# Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/dhc8-400/models/dhc8-400.xml";
var copilot_type = "";

props.globals.initNode("/sim/remote/pilot-callsign", "", "STRING");

######################################################################
# MP enabled properties.
# NOTE: These must exist very early during startup - put them
#       in the -set.xml file.


######################################################################
# Useful local property paths.



######################################################################
# Slow state properties for replication.


###############################################################################
# Pilot MP property mappings and specific copilot connect/disconnect actions.


######################################################################
# Used by dual_control to set up the mappings for the pilot.
var pilot_connect_copilot = func (copilot) {
    # Make sure dual-control is activated in the FDM FCS.
    settimer(func { setprop(l_dual_control, 1); }, 1);

    return 
        [
         ######################################################################
         # Process received properties.
         ######################################################################
         ######################################################################
         # Process properties to send.
         ######################################################################
        ];
}

######################################################################
var pilot_disconnect_copilot = func {
}


###############################################################################
# Copilot MP property mappings and specific pilot connect/disconnect actions.


######################################################################
# Used by dual_control to set up the mappings for the copilot.
var copilot_connect_pilot = func (pilot) {
    # Initialize Nasal wrappers for copilot pick anaimations.
    set_copilot_wrappers(pilot);

    return
        [
         ######################################################################
         # Process received properties.
         ######################################################################
         ######################################################################
         # Process properties to send.
         ######################################################################
        ];
}

######################################################################
var copilot_disconnect_pilot = func {
}

######################################################################
# Copilot Nasal wrappers

var set_copilot_wrappers = func (pilot) {
    var p = "instrumentation/magnetic-compass/indicated-heading-deg";
    pilot.getNode(p).alias(props.globals.getNode(p));
}
