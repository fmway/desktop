{ internal, lib, ... }:
{ pkgs, inputs, config, ... }: let
  cfg = config.wayland.windowManager.niri;
  noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
    copyNoctalia = lib.hm.dag.entryAfter ["linkGeneration"] /* sh */ ''
      [ -e "$HOME/.config/niri/noctalia.kdl" ] || touch "$HOME/.config/niri/noctalia.kdl"
      [ ! -e "$HOME/.local/share/noctalia" ] || rm -rf "$HOME/.local/share/noctalia"
      cp --dereference -r "${noctalia-shell}/share/noctalia-shell" "$HOME/.local/share/noctalia"
      chmod +rw -R "$HOME/.local/share/noctalia"
    '';
  };

  # substitute all binds with sub to wlr-which-key
  xdg.configFile."wlr-which-key/niri.yaml".source =
    (pkgs.formats.yaml {}).generate "wlr-which-key.yaml"
      (import ./wlr-which-key.nix {
        menu = let
          allBinds = builtins.filter (x: x.name or "" == "binds") cfg.config;
          allSubs = builtins.filter (x: x._sub or false) (lib.flatten (map (x: x.children) allBinds));
        in map (x: {
          key = x._key;
          desc = x._desc;
          submenu = lib.niri.normalizeSub x._children;
        }) allSubs;
      });
}
