{
  fmx.essentials.performance = {
    includes = [ <fmx/essentials/performance/_> ];
    nixos = {
      security.rtkit.enable = true;
      services.upower.enable = true;
      services.hardware.bolt.enable = true;
    };

    # Enale throttled.service for fix Intel CPU throttling
    throttled.nixos.services.throttled.enable = true;

    # Enable thermald for CPU temperature auto handling
    thermald.nixos.services.thermald.enable = true;

    # Enable earlyoom for handling OOM conditions
    earlyoom.nixos.services.earlyoom = {
      enable = true;
      enableNotifications = true;
      freeMemThreshold = 2;
      freeSwapThreshold = 3;
    };

    # power-profiles-daemon.enable = true;
    tuned.nixos = {
      services.tuned = {
        enable = true;
        ppdSupport = true;
      };
      services.tlp.enable = false;
    };
  };
}
