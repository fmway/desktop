{ lib, den, ... }: let
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
    den.policies.disko-to-nixos
  ];

  den.schema.host.imports = [
    diskoModule
  ];

  den.policies.disko-to-nixos = { host, ... }:
    lib.optional (host.class == "nixos")
      (den.lib.policy.route {
        fromClass = "disko";
        intoClass = "nixos";
        path = [ "disko" ];
        guard = { options, ... }: options ? disko;
        adaptArgs = _: { mainDisk = host.mainDisk; };
      });
}
