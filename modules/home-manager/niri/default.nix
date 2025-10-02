{ internal, lib, ... }:
{ pkgs, config, ... }: let
  cfg = config.wayland.windowManager.niri;
in {

  wayland.windowManager.niri = {
    enable = true;
    config = import ./config.nix { inherit lib pkgs; };
  };

  home.packages = with pkgs; [
    libappindicator
    libdbusmenu
    swaylock-effects
    cliphist
    swayidle
    noctalia-shell
    hyprpolkitagent
  ];

  home.activation = {
    copyNoctalia = lib.hm.dag.entryAfter ["writeBoundary"] /* sh */ ''
      [ ! -e "$HOME/.local/share/noctalia" ] || rm -rf "$HOME/.local/share/noctalia"
      cp --dereference -r "${pkgs.noctalia-shell}/share/noctalia-shell" "$HOME/.local/share/noctalia"
      chmod +rw -R "$HOME/.local/share/noctalia"
    '';
  };

  # substitute all binds with sub to wlr-which-key
  xdg.configFile."wlr-which-key/niri.yaml".source =
    (pkgs.formats.yaml {}).generate "wlr-which-key.yaml"
      (import ./wlr-which-key.nix {
        menu = let
          allBinds = builtins.elemAt (builtins.filter (x: x.name or "" == "binds") cfg.config) 0;
          allSubs = builtins.filter (x: x._sub or false) allBinds.children;
        in map (x: {
          key = x._key;
          desc = x._desc;
          submenu = lib.niri.normalizeSub x._children;
        }) allSubs;
      });
}
