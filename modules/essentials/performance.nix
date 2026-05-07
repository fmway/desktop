{
  fmx.essentials._.performance = { config, ... }:
  {
    includes = builtins.attrValues config.provides;
    nixos = {
      security.rtkit.enable = true;
      services.upower.enable = true;
      services.hardware.bolt.enable = true;
    };

    # Enale throttled.service for fix Intel CPU throttling
    _.throttled.nixos.services.throttled.enable = true;

    # Enable thermald for CPU temperature auto handling
    _.thermald.nixos.services.thermald.enable = true;

    # Enable earlyoom for handling OOM conditions
    _.earlyoom.nixos.services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 2;
      freeSwapThreshold = 3;
    };

    # power-profiles-daemon.enable = true;
    _.tuned.nixos = {
      services.tuned = {
        enable = true;
        ppdSupport = true;
      };
      services.tlp.enable = false;
    };
  };
}
