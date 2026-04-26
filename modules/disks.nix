{ inputs, den, __findFile, lib, ... }:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # den.schema.host.imports = [
  #   fmx.schema.host
  # ];
  #
  # fmx.schema.host = { host, ... }:
  # {
  #   options.mainDisk = lib.mkOption {
  #     type = lib.disko.optionTypes.absolute-pathname;
  #     description = "Main disk Device";
  #     default = "/dev/sda";
  #   };
  # };

  fmx.disk._ = lib.import-tree.toAttrs (
    { path, name }:
    {
      description = ''
        Usage:
          den.aspects.Namaku1801.includes = [
            <fmx/disk/${name}>
          ];
          # Set mainDisk via meta.mainDisk (default "/dev/sda")
          den.aspects.Namaku1801.meta.mainDisk = "/dev/nvme0n1";
      '';
      nixos.imports = [ inputs.disko.nixosModules.default ];
      disko = { mainDisk, ... } @ v: (import path (v // { inherit mainDisk; })).disko;
    }) ./_disks;

  fmx.utils._.disko = {
    description = "Add disko classes";
    __functor = _:
      { host }:
      den._.forward {
        # only support for nixos
        each = [ "nixos" ];
        fromClass = _: "disko";
        intoClass = lib.id;
        intoPath = _: [ "disko" ];
        fromAspect = _: den.lib.parametric.fixedTo { inherit host; } host.aspect;
        guard = { options, ... }: options ? disko;
        adaptArgs = args: args // { mainDisk = host.aspect.meta.mainDisk or "/dev/sda"; };
      };
  };
}
