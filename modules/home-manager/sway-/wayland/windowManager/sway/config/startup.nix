{ pkgs, lib, ... }: let
  lock = "${pkgs.swaylock-effects}/bin/swaylock";
  cliphist = lib.getExe pkgs.cliphist;
in [
  { command = "${lib.getExe pkgs.foot} --server"; }
  { command = "${lib.getExe pkgs.light} -S 5%"; }
  { command = ''wl-paste -t text --watch ${cliphist} store''; }
  { command = ''wl-paste -t image --watch ${cliphist} store''; }
  { command = "systemctl --user import-environment XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"; }
  { command = "dbus-update-activation-environment WAYLAND_DISPLAY"; }
  { command = "wayland-pipewire-idle-inhibit"; }
  {
    command = ''${lib.getExe pkgs.swayidle} w timeout 300 '${lock} -f -c 000000' timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' before-sleep "${lock} -f -c 000000"'';
  }
]
