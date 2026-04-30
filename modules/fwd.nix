{ den, fmx, lib, __findFile, ... }:
{
  den.default.includes = [
    <fmx/utils>
  ];

  fmx.utils.includes = builtins.attrValues fmx.utils.provides;
   # programs -> homeManager.programs
   # TODO: support nixos class
  fmx.utils._.programs =
    { class, aspect-chain }:
    den._.forward {
      each = [ "homeManager" ];
      fromClass = _: "programs";
      intoClass = lib.id;
      intoPath = _: [ "programs" ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = { pkgs, config, ... } @ args: args // { inherit config den fmx pkgs; };
    };

  fmx.utils._.disko = den.lib.take.exactly {
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
        adaptArgs = args: args // {
          mainDisk = host.aspect.meta.mainDisk or (lib.warn "${host.aspect.meta.name}: mainDisk is undefined, use default value (dev/sda)" "/dev/sda");
        };
      };
  };

  # FIXME: nix classes (fmx.utils._.nix) replace arrays instead of merging
  # fmx.utils._.nix = {
  #   description = ''
  #     Forward nix classes to (nixos|darwin|homeManager).nix
  #   '';
  #   __functor = _self:
  #     { class, aspect-chain }:
  #     den._.forward {
  #       each = [ "nixos" "homeManager" "darwin" ];
  #       fromClass = _: "nix";
  #       intoClass = lib.id;
  #       intoPath = _: [ "nix" ];
  #       fromAspect = _: lib.head aspect-chain;
  #       guard = { options, ... }: options ? nix;
  #     };
  # };
}
