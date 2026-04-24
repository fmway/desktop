{ den, lib, ... }: let
  configurationLimit = lib.mkDefault 25;
in {
  fmx.boot._ = {
    systemd-boot.nixos = { config, lib, ... }:
    {
      boot.loader = {
        efi.canTouchEfiVariables = lib.mkDefault config.boot.loader.systemd-boot.enable;
        systemd-boot = {
          enable = true;
          memtest86.enable = lib.mkDefault true;
          inherit configurationLimit;
        };
      };
    };

    grub.nixos = { config, lib, ... }:
    {
      boot.loader.grub = {
        inherit configurationLimit;
        enable = true;
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
  };
}
