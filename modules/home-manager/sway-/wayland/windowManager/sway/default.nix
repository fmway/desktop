{ pkgs, uncommon, lib, config, ... }: let
  cfg = config.wayland.windowManager.sway;
  env = builtins.concatStringsSep "\n" (
    lib.attrsToList (k: v:
      "export ${k}=${if builtins.isString v then v else builtins.toJSON v}"
    ) uncommon.env);
  flat = x: if builtins.isList x then x else [x];
in {
  extraSessionCommands = lib.mkAfter env;
  config = builtins.foldl' (acc: curr: acc // (
    if curr == "normal" then {
      keybindings = acc.keybindings or {} //
        lib.mapAttrs (_: toString) (uncommon.modes.${curr}.binds or {});
    } else {
      keybindings = builtins.foldl' (a: c: a // {
        "${c}" = ''mode "${curr}"'';
      }) (acc.keybindings or {}) (flat (uncommon.modes.${curr}.enterBy or []));
      modes = acc.modes or {} // {
        "${curr}" = let
          a = acc.modes.${curr} or {} //
          lib.mapAttrs (_: toString) (uncommon.modes.${curr}.binds or {});
        in builtins.foldl' (a: c: a // {
          "${c}" = ''mode "default"'';
        }) a (flat (uncommon.modes.${curr}.exitBy or []));
      };
    }
  )) {} (builtins.attrNames uncommon.modes);
  wrapperFeatures.gtk = true;
  # swayfx problems
  checkConfig = false;

  package = lib.mkDefault pkgs.swayfx;

  extraConfig = lib.mkMerge [
    ''
      xwayland enable
      font pango:Noto Sans 1 
      gaps inner 0
      gaps outer 0
      default_border pixel 4
    ''
    (lib.mkIf (cfg.package.pname == "swayfx") ''
      # swayfx feature
      corner_radius 8
      blur enable
      blur_xray disable
      blur_passes 2
      blur_radius 4
      shadows enable
      shadows_on_csd disable
      shadow_blur_radius 16
      shadow_color #0000007F

      default_dim_inactive 0.0
      dim_inactive_colors.unfocused #000000FF
      dim_inactive_colors.urgent #900000FF
    '')
  ];
}
