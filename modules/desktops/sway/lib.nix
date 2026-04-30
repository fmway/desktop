{ lib, ... }: {
  # defaultExiters is list of common keys to exit in sway modes
  defaultExiters = [
    "Escape"
    "Return"
    "Shift+Escape"
    "Shift+Return"
    "Mod+Return"
    "Mod+Shift+Return"
    "Mod+Escape"
    "Mod+Shift+Escape"
  ];

  cmd = let
    flat = x: if builtins.isList x then x else [x];
    template = cb: acc: elem: {
      "${elem}" = cb elem;
    } // acc;
    generator = cb: lists: builtins.foldl' (template cb) {} lists;

    mkCmd = cmd: mkCmd' (if lib.isAttrs cmd then cmd else { inherit cmd; });
    mkCmd' = { cmd, beforeCmd ? [], afterCmd ? [], children ? [], ... } @ args: args // {
      inherit cmd beforeCmd afterCmd children;
      __functor = self: args: self // {
        children = self.children ++ (flat args);
        __toString = self: let
          parseBCmd = self.beforeCmd ++ ["&&"];
          parseACmd = ["&&"] ++ self.afterCmd;
        in lib.concatStringsSep " " (map toString (
           lib.optionals (self.beforeCmd != []) parseBCmd
        ++ flat self.cmd
        ++ lib.optionals (self.children != []) self.children 
        ++ lib.optionals (self.afterCmd != []) parseACmd));
      };
    };

    a = { h = "Left"; j = "Down"; k = "Up"; l = "Right"; };
  in rec {
    directions = [ "left" "right" "up" "down" ];

    /*
      resize.<direction> :: (Number | String) -> StringLike
      a functions to resize in sway/i3 command
      e.g: 
      resize.left 5 # => "resize shrink width 5 px"
    */
    resize = let
      go = rec { left = "shrink"; right = "grow"; up = left; down = right; };
      to = rec { left = "width"; right = left; up = "height"; down = up; };
    in generator (dir: size:
      "resize ${go.${dir}} ${to.${dir}} ${toString size} px") directions;


    /*
      exec :: Any -> ...
      e.g:
      exec "${pkgs.fuzzel}/bin/fuzzel" "--dmenu" # => "exec ${pkgs.fuzzel}/bin/fuzzel --dmenu" 
    */
    exec = mkCmd "exec";

    /*
      swaymsg :: Any -> ...
      e.g:
      swaymsg "${pkgs.fuzzel}/bin/fuzzel" "--dmenu" # => "exec swaymsg ${pkgs.fuzzel}/bin/fuzzel --dmenu" 
    */
    swaymsg = exec "swaymsg";

    /*
      swaymsg' :: Any -> ...
      e.g:
      swaymsg' "${pkgs.fuzzel}/bin/fuzzel" "--dmenu" # => ''exec swaymsg mode "default" && swaymsg ${pkgs.fuzzel}/bin/fuzzel --dmenu''
    */
    swaymsg'= swaymsg DEFAULT and swaymsg;

    pipe = lib.concatStringsSep " | ";

    and = "&&";

    or' = "||";

    
    toggle = generator (x: "${x} toggle") [ "floating" "fullscreen" "border" ];
    move = generator (x: "move ${x}") (directions ++ [ "scratchpad" ]);
    focus = generator (x: "focus ${x}") (directions ++ [ "mode_toggle" "parent" ]);
    show = generator (x: "${x} show") [ "scratchpad" ];
    layout = generator (x: "layout ${x}") [ "stacking" "tabbed" "toggle split" ];
    split = generator (x: "split${x}") [ "h" "v" ];

    /*
      seq :: Number -> Number -> Function -> AttrSet
      e.g:
      seq 1 9 (i: {
        "Mod4+${toString i}" = "workspace number ${toString i}";
      })
     */
    seq = start: end: fn: let
      range = builtins.genList (x: x + start) (end - start + 1);
    in builtins.foldl' (acc: curr: acc // fn curr) {} range;

    /*
      hjkl :: Function -> AttrSet

      e.g:
      hjkl (arrow: alt: {
        "Mod4+${arrow}" = "focus ${lib.toLower arrow}";
        "Mod4+${alt}" = "focus ${lib.toLower arrow}";
      })
      # arrow = Left | Right | Up | Down
      # alt   = h | j | k | l
     */
    hjkl = fn: builtins.foldl' (acc: curr: acc // fn a.${curr} curr) {} (
      builtins.attrNames a);

    DEFAULT = ''mode "default"'';
  };

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
  parse = { env ? {}, modes ? {} }: let
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
  };
}
