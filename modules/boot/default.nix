{ __findFile, ... }:
{
  fmx.boot = {
    includes = [
      <fmx/boot/systemd-boot>
      <fmx/boot/plymouth>
    ];

    nixos = { lib, config, ... }:
    {
      boot = {
        tmp.cleanOnBoot = lib.mkDefault true;
        tmp.useTmpfs = lib.mkDefault false;

        kernel.sysctl  = {
          # REISUB
          "kernel.sysrq" = 1;
          "kernel.printk" = "3 3 3 3";

          # Swap configuration
          "vm.swappiness" = 150;
          "vm.watermark_boost_factor" = 5000;
          "vm.watermark_scale_factor" = 125;
          "vm.page-cluster" = 0;
        };

        kernelParams = lib.optionals config.boot.zfs.enabled [
          "zfs.zfs_arc_max=536870912" # max zfs cache (512MB)
          "zswap.enabled=0" # disable zswap
        ] ++ [
          "quiet"
          "splash"
          "intremap=on"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];
      };
    };
  };
}
