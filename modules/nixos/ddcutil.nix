{ pkgs, ... }:
{
  imports = [
    ({ config, lib, ... }: {
      options.users.users = lib.mkOption {
        type = with lib.types; attrsOf (submodule ({ config, ... }: {
          options = {};
          config.extraGroups = lib.optionals config.isNormalUser [ "i2c" ];
        }));
      };
    })
  ];
  boot.kernelModules = [
    "i2c-dev"
  ];
  boot.initrd.availableKernelModules = [
    "i2c-dev"
  ];

  environment.systemPackages = with pkgs; [
    ddcutil
  ];
  users.groups.i2c = {};
}
