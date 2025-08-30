{ pkgs, uncommon, superLib, lib, config, ... }:
{
  enable = lib.mkDefault true;

  systemd.enableXdgAutostart = true;
  xwayland.enable = true;

  extraConfig = superLib.hyprland.parse uncommon;
}
