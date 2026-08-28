{ den, lib, ... }: let
  inherit (den.lib) policy; inherit (policy) pipe;
in {
  den.quirks.niri-config = {};
  den.policies.collect-niri-config = { user ? null, ... }: [
    # clear niri-config for non home configurations
    (pipe.from "niri-config" [
      (pipe.filter (_: false))
    ])
  ] ++ lib.optionals (!isNull user) [
    (pipe.from "niri-config" [
      (pipe.for (list: let
        flatten = builtins.concatMap (x: if builtins.isList x then x else [x]) list;
        r = builtins.partition (x: x ? _do) flatten;
        # prioritize non-query nodes
      in r.wrong ++ r.right))
      (pipe.to [ <fmx/desktops/niri> ])
    ])
  ];
  den.default.includes = [
    den.policies.collect-niri-config
  ];
  fmx.desktops._.niri.homeManager = { niri-config, pkgs, ... }: let
    finalConfig = lib.kdl.serialize.nodes niri-config;
  in {
    home.packages = [ pkgs.niri ];
    
    xdg.configFile."niri/config.kdl".text = finalConfig;
    # substitute all binds with sub to wlr-which-key
    xdg.configFile."wlr-which-key/niri.yaml".source =
      (pkgs.formats.yaml {}).generate "wlr-which-key.yaml"
        (import ./_wlr-which-key.nix {
          menu = let
            allBinds = builtins.filter (x: x.name or "" == "binds") niri-config;
            allSubs = builtins.filter (x: x._sub or false) (lib.flatten (map (x: x.children) allBinds));
          in map (x: {
            key = x._key;
            desc = x._desc;
            submenu = lib.niri.normalizeSub x._children;
          }) allSubs;
        });
  };
  fmx.desktops._.niri.nixos = { pkgs, ... }:
  {
    qt.enable = true;
    qt.platformTheme = "kde";
    qt.style = "adwaita-dark";
    programs.niri.enable = true;
    programs.dconf.enable = true;
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      # kdePackages.xdg-desktop-portal-kde
      # xdg-desktop-portal-hyprland
    ];
    xdg.portal.xdgOpenUsePortal = true;
    services.gnome.gnome-keyring.enable = true;
    services.dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
      libsecret
    ];
  };
}
