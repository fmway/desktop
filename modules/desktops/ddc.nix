{
  fmx.desktops.utils.ddc = {
    includes = [
      ({ user, ... }: {
        nixos.users.users.${user.userName}.extraGroups = [ "i2c" "input" ];
      })
    ];
    nixos = { pkgs, ... }:
    {
      boot.kernelModules = [
        "i2c-dev"
      ];
      boot.initrd.availableKernelModules = [
        "i2c-dev"
      ];
      users.groups.i2c = {};
      environment.systemPackages = [ pkgs.ddcutil ];
      services.udev.packages = [ pkgs.ddcutil ];
    };
  };
}
