var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/Q400/Dialogs/autopilot-dlg.xml");

gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");
