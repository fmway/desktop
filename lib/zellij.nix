{ lib, ... }: let
  inherit (lib.kdl) node leaf;
in rec {
  bind = node "bind";
  unbind = node "unbind";
  Resize = leaf "Resize";
  SwitchToMode = leaf "SwitchToMode";
  MoveFocus = leaf "MoveFocus";
  NewPane = leaf "NewPane";
  SwitchToNormal = SwitchToMode "Normal";
}
