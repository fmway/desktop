{ den, ... }:
{
  fmx.boot._ = {
    systemd-boot.nixos = { host, config, lib, ... }:
    {
      _module.args.babi = host;
      _module.args.den = den;
      boot.loader = {
        efi.canTouchEfiVariables = lib.mkDefault config.boot.loader.systemd-boot.enable;
        systemd-boot = {
          enable = true;
          memtest86.enable = lib.mkDefault true;
          configurationLimit = host.aspect.meta.configurationLimit or 25;
        };
      };
    };

    grub.nixos = { host, config, lib, ... }:
    {
      boot.loader.grub = {
        configurationLimit = host.aspect.meta.configurationLimit or 25;
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
