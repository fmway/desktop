{ config, pkgs, lib, ... }:
let
  # limit boot entry
  configurationLimit = lib.mkDefault 25;
in {
  boot = {
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault config.boot.loader.systemd-boot.enable;

      systemd-boot = {
        enable = true;
        memtest86.enable = lib.mkDefault true;
        inherit configurationLimit;
      };

      grub = {
        inherit configurationLimit;
        enable = ! config.boot.loader.systemd-boot.enable;
        copyKernels = lib.mkDefault true;
        efiInstallAsRemovable = lib.mkDefault (! config.boot.loader.efi.canTouchEfiVariables);
        efiSupport = lib.mkDefault true;
        fsIdentifier = "label";
        zfsSupport = lib.mkDefault config.boot.zfs.enabled;

        mirroredBoots = lib.optionals (config.boot.zfs.enabled) [
          { devices = [ "nodev" ]; path = "/boot"; }
        ];

        devices = lib.mkDefault "nodev";
      };
    };

    plymouth.enable = lib.mkDefault true;
    plymouth.theme = lib.mkDefault "bgrt";

    tmp.cleanOnBoot = lib.mkDefault true;
    tmp.useTmpfs = lib.mkDefault false;

    kernelParams = lib.optionals config.boot.zfs.enabled [
      "zfs.zfs_arc_max=536870912" # max zfs cache (512MB)
      "zswap.enabled=0" # disable zswap
    ];

    kernel.sysctl  = {
      # REISUB
      "kernel.sysrq" = 1;
      "kernel.printk" = "3 3 3 3";

      # Swap configuration
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 5000;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };

    # Enable v4l2loopback kernel module for using Virtual Camera.
    # extraModulePackages = with config.boot.kernelPackages; [
    #   v4l2loopback
    # ];
    # extraModprobeConfig = ''
    #   options v4l2loopback devices=1 video_nr=1 card_label="Virtual Camera" exclusive_caps=1
    # '';

    # kernel.sysctl = {
      # for unlimited warnet hack, thankxs to umahdroid.com
      # https://www.umahdroid.com/2023/08/trik-axis-warnet-unlimited-hotspot.html
      # "net.ipv4.ip_default_ttl" = 65;
      # "net.inet6.ip6.hlim" = 65;
    # };
  };
}
