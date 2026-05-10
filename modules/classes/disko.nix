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
        adaptArgs = args: {
          mainDisk = host.aspect.meta.mainDisk or (lib.warn "${host.aspect.meta.name}: mainDisk is undefined, use default value (dev/sda)" "/dev/sda");
        };
      }
    else {};
in {
  den.classes.disko.description = "Disko class";
  den.schema.host.includes = [
    diskoClass
  ];
}
