{ lib, den, ... }: let
  diskoClass = { host, ... } @ v:
    if v == { inherit host; } then
      den._.forward {
        # only support for nixos
        each = [ "nixos" ];
        fromClass = _: "disko";
        intoClass = lib.id;
        intoPath = _: [ "disko" ];
        fromAspect = _: host.aspect;
        guard = { options, ... }: options ? disko;
        adaptArgs = args: args // { mainDisk = host.mainDisk; };
      }
    else {};

  diskoModule = { config, ... }:
  {
    options.mainDisk = lib.mkOption {
      description = "mainDisk for disko (default: /dev/sda)";
      type = lib.types.str;
      default = lib.warn "${config.name}: mainDisk is undefined, use default value (dev/sda)" "/dev/sda";
    };
  };
in {
  den.classes.disko.description = "Disko class";
  den.schema.host.includes = [
    diskoClass
    # den.policies.expose-mainDisk-to-disko
  ];

  den.schema.host.imports = [
    diskoModule
  ];

  # FIXME: i'm minsunderstand with the policy.resolve
  # den.policies.expose-mainDisk-to-disko = { host, ... }: den.lib.policy.resolve.to "disko" { mainDisk = host.mainDisk; };
}
