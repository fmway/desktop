{ pkgs, lib, ... }:
{
  qt.enable = true;
  qt.platformTheme = "kde";
  qt.style = "adwaita-dark";
  programs.niri.enable = true;
  programs.dconf.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    # kdePackages.xdg-desktop-portal-kde
    # xdg-desktop-portal-hyprland
  ];
  xdg.portal.xdgOpenUsePortal = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.packages = with pkgs; [
    gcr
    gnome-settings-daemon
    libsecret
  ];
}
