{ lib, den, ... }: let
  programsFwd =
    { class, aspect-chain }:
    den._.forward {
      each = [ "homeManager" ];
      fromClass = _: "programs";
      intoClass = lib.id;
      intoPath = _: [ "programs" ];
      fromAspect = _: lib.head aspect-chain;
      adaptArgs = { pkgs, config, ... } @ args: args // { inherit config pkgs lib; };
    };
in {
  den.classes.programs.description = "programs -> homeManager.programs";

  den.schema.user.includes = [ programsFwd ];
  den.schema.home.includes = [ programsFwd ];
}
