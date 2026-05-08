{
  fmx.editors._.yazi = {
    _.smart-tab.nixos = {
      programs.yazi.plugins.smart-tab = ./smart-tab.yazi;
      programs.yazi.settings.keymap.mgr.prepend_keymap = [
        { on = "t"; run = "plugin smart-tab"; desc = "Create a tab and enter the hovered directory"; }
      ];
    };

    _.confirm-quit.nixos.programs.yazi = {
      plugins.confirm-quit = ./confirm-quit.yazi;
      settings.keymap.mgr.prepend_keymap = [
        { on = "q"; run = "plugin confirm-quit"; }
      ];
    };
  };
}
