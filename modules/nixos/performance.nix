{ lib, ... }:
{
  services = {
    # Enale throttled.service for fix Intel CPU throttling
    throttled.enable = lib.mkDefault true;

    # Enable thermald for CPU temperature auto handling
    thermald.enable = lib.mkDefault true;

    # Enable earlyoom for handling OOM conditions
    earlyoom = {
      enable = lib.mkDefault true;
      enableNotifications = true;
      freeMemThreshold = 2;
      freeSwapThreshold = 3;
    };
    # power-profiles-daemon.enable = true;
    tuned = {
      enable = true;
      ppdSupport = true;
    };
    tlp.enable = false;
    upower.enable = true;
    hardware.bolt.enable = true;
  };
  security.rtkit.enable = true;
}
