{ lib, ... }: let
  inherit (lib.kdl) node leaf plain;
in rec {
  bind = node "bind";
  unbind = node "unbind";
  Resize = leaf "Resize";
  SwitchToMode = leaf "SwitchToMode";
  MoveFocus = leaf "MoveFocus";
  NewPane = plain "NewPane" // {
    __functor = self: args: removeAttrs self ["__functor"] // {
      arguments = self.arguments ++ lib.fmway.flat args;
    };
  };
  Normal = SwitchToMode "Normal";
  up = lib.toUpper;
  m = {
    Left = "h"; Down = "j"; Up = "k"; Right = "l";
    h = "Left"; j = "Down"; k = "Up"; l = "Right";
  };
  hjkl = fn: lib.flatten (
    map (x: fn m.${x}) [ "h" "j" "k" "l" ]);
  seq = start: end: fn: let
    range = builtins.genList (x: x + start) (end - start + 1);
  in map (x: fn x) range;
}
