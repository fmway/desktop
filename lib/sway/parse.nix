{ lib, ... }:
/*
  sway.parse :: { env :: AttrSet, modes :: AttrsOf { binds :: AttrsSet, enterBy :: Either String List, exitBy :: Either String List } } -> AttrSet
  sway.parse is just our spec that's not available in home-manager, we've:
  - env spec to define environment variable that will include in sway,
  - modes to define all sway mode, with 3 spec:
    + enterBy, to define how to enter this mode
    + binds, is the list keybindings in this mode
    + exitBy, to define how to exit this mode
  - modes.normal is the normal mode, you don't need enterBy and exitBy

  example:
  sway.parse {
    env = {
      DISPLAY = ":0";
    };

    modes.Resize = {
      enterBy = "Mod4+r";
      binds = {
        h = "resize shrink width 10 px";
        j = "resize grow height 10 px";
        k = "resize shrink height 10 px";
        l = "resize grow width 10 px";
      };
      exitBy = [
        "Return"
        "Escape"
      ];
    };

    modes.Custom = {
      enterBy = "Mod4+c";
      binds.p = ''swaymsg mode "default" && swaymsg "bar mode toggle"'';
      exitBy = [ "Escape" ];
    };
  } // {
    # other spec in wayland.windowManager.sway
    # ...
  }
 */
{ env ? {}, modes ? {} }: let
  pEnv = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v:
      "export ${k}=${if builtins.isString v then v else builtins.toJSON v}"
    ) env);
in {
  extraSessionCommands = lib.mkIf (env != {}) pEnv;
  config = builtins.foldl' (acc: curr: acc // (
    if curr == "normal" then {
      keybindings = acc.keybindings or {} //
        lib.mapAttrs (_: toString) (modes.${curr}.binds or {});
    } else {
      keybindings = builtins.foldl' (a: c: a // {
        "${c}" = ''mode "${curr}"'';
      }) (acc.keybindings or {}) (lib.fmway.flat (modes.${curr}.enterBy or []));
      modes = acc.modes or {} // {
        "${curr}" = let
          a = acc.modes.${curr} or {} //
          lib.mapAttrs (_: toString) (modes.${curr}.binds or {});
        in builtins.foldl' (a: c: a // {
          "${c}" = ''mode "default"'';
        }) a (lib.fmway.flat (modes.${curr}.exitBy or []));
      };
    }
  )) {} (builtins.attrNames modes);
}
