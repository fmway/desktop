{ config, lib, ... }: let
  cfg = config.wayland.windowManager.sway;
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
in {
  mod = cfg.config.modifier;
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
  cmd = rec {
    directions = [ "left" "right" "up" "down" ];

    resize = let
      go = rec { left = "shrink"; right = "grow"; up = left; down = right; };
      to = rec { left = "width"; right = left; up = "height"; down = up; };
    in generator (dir: size:
      "resize ${go.${dir}} ${to.${dir}} ${toString size} px") directions;

    exec = mkCmd "exec";
    swaymsg = mkCmd "swaymsg";
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

    seq = start: end: fn: let
      range = builtins.genList (x: x + start) (end - start + 1);
    in builtins.foldl' (acc: curr: acc // fn curr) {} range;

    hjkl = fn: builtins.foldl' (acc: curr: acc // fn a.${curr} curr) {} (
      builtins.attrNames a);

    DEFAULT = ''mode "default"'';
  };
}
