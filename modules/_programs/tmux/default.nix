{ den, lib, pkgs, ... }: let
  scanPlugins = den.lib.tmux.mkScanPlugins pkgs;
in {
  tmux = {
    enable = lib.mkDefault true;
    aggressiveResize = lib.mkDefault true; # resize ampe mentok
    baseIndex = lib.mkDefault 1; # base index for window and session
    customPaneNavigationAndResize = lib.mkDefault true; # hjkl mode
    mouse = lib.mkDefault true; # set mouse on
    secureSocket = lib.mkDefault true; # close tmux when user logout
    sensibleOnTop = lib.mkDefault true; # enable tmux-sensible on top level
    terminal = lib.mkDefault "screen-256color";
    plugins = scanPlugins ./. (with pkgs.tmuxPlugins; [
      cpu
      tmux-thumbs
      battery
      logging
      resurrect
      yank
      copycat
      prefix-highlight
      pain-control
      fzf-tmux-url
    ]);
    extraConfig = lib.fileContents ./tmux.conf;
  };
}
