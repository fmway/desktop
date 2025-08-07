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
}
