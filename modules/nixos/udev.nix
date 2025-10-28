{ pkgs, ... }:
{
  services.udev = {
    packages = with pkgs; [
      gnome-settings-daemon
    ];
  };
}
