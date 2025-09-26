{ config, lib, ... }:
{
  networking = {
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = lib.mkDefault true;
    networkmanager.wifi.powersave = lib.mkDefault true;
    networkmanager.dns = lib.mkDefault "systemd-resolved";

    nameservers = [
      "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"
    ];

    # Proxy
    # proxy = {
    #   httpProxy = "http://192.168.43.1:8080";
    #   httpsProxy = "http://192.168.43.1:8080";
    #   allProxy = "http://192.168.43.1:8080";
    # };
    # resolvconf.enable = false;
  };
  services.resolved = {
    enable = lib.mkDefault true;
    dnsovertls = "true";
    fallbackDns = [
      "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"
    ];
  };
}
