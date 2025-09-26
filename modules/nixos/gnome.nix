{ lib, pkgs, config, ... }: let
  isGnomeEnabled = config.services.desktopManager.gnome.enable;
in {
   # GDM
  services.displayManager.gdm.enable = lib.mkDefault isGnomeEnabled;
  services.desktopManager.gnome.enable = lib.mkDefault true;

  # enable GNOME keyring
  services.gnome.gnome-keyring.enable = lib.mkDefault true;

  # Exclude packages from the gnome.
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gnome-maps
    geary
    gnome-tour
    # gnome-software
    gnome-contacts
    gnome-software
  ];

  # Override default Dconf settings.
  services.desktopManager.gnome = {
    extraGSettingsOverridePackages = with pkgs;[
      gsettings-desktop-schemas # for org.gnome.desktop
      gnome-shell # for org.gnome.shell
    ];
  };

  # packages
  environment.systemPackages = (with pkgs; [
    adw-gtk3
  ] ++ lib.optionals isGnomeEnabled [
    dconf-editor
    gnome-tweaks
    evolution
    # gdm-settings
    gnome-extension-manager
  ]) ++ lib.optionals isGnomeEnabled (with pkgs.gnomeExtensions; [
    burn-my-windows
    paperwm
    appindicator
    clipboard-indicator
    thinkpad-battery-threshold
    blur-my-shell
    # net-speed
    lilypad
    emoji-copy
    day-progress
    totp
    # bing-wallpaper-changer
    # cloudflare-warp-toggle
    system-monitor
    weather-oclock
  ]);

  # add gsconnect connection configuration
  programs.kdeconnect.package = lib.mkIf isGnomeEnabled pkgs.gnomeExtensions.gsconnect;
}
