###############################################################################
## $Id: copilot-dual-control.nas,v 1.4 2009/05/24 12:52:12 mfranz Exp $
##
## Nasal for copilot for dual control over the multiplayer network.
##
##  Copyright (C) 2007 - 2009  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

# Renaming (almost :)
var DCT = dual_control_tools;
var ADC = aircraft_dual_control;
# NOTE: By loading the aircraft specific dual control module
#       as <aircraft_dual_control> this file is generic.
#       The aircraft specific modul must set the variables
#       pilot_type and copilot_type to the name (with full path) of
#       main 3d model XML for the pilot and copilot aircraft.
#       This module should be loades under the name dual_control.

# Allow aircraft to override the copilot view name.
if (!contains(ADC, "copilot_view")) {
  ADC.copilot_view = "Copilot View";
}

# Properties for position and orientation of local aircraft.
var l_lat     = "/position/latitude-deg";
var l_lon     = "/position/longitude-deg";
var l_alt     = "/position/altitude-ft";
var l_heading = "/orientation/heading-deg";
var l_pitch   = "/orientation/pitch-deg";
var l_roll    = "/orientation/roll-deg";

# Replicate remote state.
var r_airspeed  = "velocities/true-airspeed-kt";
var l_airspeed  = "/velocities/airspeed-kt";
var vertspeed   = "velocities/vertical-speed-fps";

######################################################################
# Connect to new pilot
var process_data = 0;

var connect = func (pilot) {
  # Set view eye paths.
  var view_cfg = "/sim/view[" ~ view.indexof(ADC.copilot_view)~ "]/config";
  setprop(view_cfg ~ "/eye-lat-deg-path",
          pilot.getNode(DCT.lat_mpp).getPath());
  setprop(view_cfg ~ "/eye-lon-deg-path",
          pilot.getNode(DCT.lon_mpp).getPath());
  setprop(view_cfg ~ "/eye-alt-ft-path",
          pilot.getNode(DCT.alt_mpp).getPath());

  setprop(view_cfg ~ "/eye-heading-deg-path",
          pilot.getNode(DCT.heading_mpp).getPath());
  setprop(view_cfg ~ "/eye-pitch-deg-path",
          pilot.getNode(DCT.pitch_mpp).getPath());
  setprop(view_cfg ~ "/eye-roll-deg-path",
          pilot.getNode(DCT.roll_mpp).getPath());
  
  view_cfg = "/sim/view[" ~ view.indexof("Helicopter View")~ "]/config";
  setprop(view_cfg ~ "/eye-lat-deg-path",
          pilot.getNode(DCT.lat_mpp).getPath());
  setprop(view_cfg ~ "/eye-lon-deg-path",
          pilot.getNode(DCT.lon_mpp).getPath());
  setprop(view_cfg ~ "/eye-alt-ft-path",
          pilot.getNode(DCT.alt_mpp).getPath());
  setprop(view_cfg ~ "/eye-heading-deg-path",
          pilot.getNode(DCT.heading_mpp).getPath());
  setprop(view_cfg ~ "/at_model", 0);  

  # Tweak MP/AI filters
  pilot.getNode("controls/allow-extrapolation").setBoolValue(1);
  pilot.getNode("controls/lag-adjust-system-speed").setValue(5.0);  

  # Set up property mappings.
  process_data = 
    [
      # Map /postition/*
      DCT.Translator.new
        (pilot.getNode(DCT.lat_mpp), props.globals.getNode(l_lat)),
      DCT.Translator.new
        (pilot.getNode(DCT.lon_mpp), props.globals.getNode(l_lon)),
      DCT.Translator.new
        (pilot.getNode(DCT.alt_mpp), props.globals.getNode(l_alt)),
      # Map /orientation/*
      DCT.Translator.new
        (pilot.getNode(DCT.heading_mpp),
         props.globals.getNode(l_heading)),
      DCT.Translator.new
        (pilot.getNode(DCT.pitch_mpp),
         props.globals.getNode(l_pitch)),
      DCT.Translator.new
        (pilot.getNode(DCT.roll_mpp),
         props.globals.getNode(l_roll)),
      # Map /velocities/*
      DCT.Translator.new
        (pilot.getNode(r_airspeed),
         props.globals.getNode(l_airspeed)),
      DCT.Translator.new
        (pilot.getNode(vertspeed),
         props.globals.getNode(vertspeed)),
    ] ~ ADC.copilot_connect_pilot(pilot);

  print("Dual control ... connected to pilot.");
  setprop("/sim/messages/copilot", "Welcome aboard.");
}


######################################################################
# Main loop singleton class.
var main = {
  init : func {
    me.loopid = 0;
    me.active = 0;
    setlistener("/ai/models/model-added", func {
      settimer(func { me.activate(); }, 2);
    });
    print("Copilot dual control ... initialized");
    settimer(func { me.activate(); }, 5);
  },
  reset : func {
    me.active = 0;
    me.loopid += 1;
    me._loop_(me.loopid);
  },
  activate : func {
    if (!me.active) {
      me.reset();
    }
  },
  update : func {
    var mpplayers =
      props.globals.getNode("/ai/models").getChildren("multiplayer");
    var r_callsign = getprop("/sim/remote/pilot-callsign");

    foreach (var pilot; mpplayers) {
      if ((pilot.getChild("valid").getValue()) and
          (pilot.getChild("callsign") != nil) and
          (pilot.getChild("callsign").getValue() == r_callsign)) {

        if (me.active == 0) {
          # Note: sim/model/path contains the model XML file. 
          if ((pilot.getNode("sim/model/path") != nil) and
              (pilot.getNode("sim/model/path").getValue() ==
               ADC.pilot_type)) {
            me.active = 1;
            connect(pilot);
          } else {
            print("Dual control ... pilot rejected - wrong aircraft type.");
            me.loopid += 1;
            return;
          }
        }

        # Mess with the MP filters. Highly experimental.
        if (pilot.getNode("controls/lag-time-offset") != nil) {
          var v = pilot.getNode("controls/lag-time-offset").getValue();
          #pilot.getNode("controls/lag-time-offset").setValue(0.99 * v);
        }

        foreach (var w; process_data) {
          w.update();
        }
        return;
      }
    }
    # The pilot player is not around. Idle loop.
    if (me.active) {
      print("Dual control ... disconnected from pilot.");
      ADC.copilot_disconnect_pilot();
    }
    me.active = 0;
    me.loopid += 1;
  },
  _loop_ : func(id) {
    id == me.loopid or return;
    me.update();
    settimer(func { me._loop_(id); }, 0);
  }
};

###############################################################################
# Initialization.

var last_view = 0;

setlistener("/sim/signals/fdm-initialized", func {
  main.init();
});

