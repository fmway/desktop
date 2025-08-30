{ lib, ... }: let
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
}
