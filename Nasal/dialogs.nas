var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/Q400/Systems/autopilot-dlg.xml");

gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");

var checklists_dialog = gui.Dialog.new("/sim/gui/dialogs/q400/checklists/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/checklists-dlg.xml");
