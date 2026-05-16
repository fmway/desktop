{ den, fmx, lib, ... }:
{
  # FIXME: infinite recursion
  # fmx.utils._.nixvim = {
  #   description = "nixvim -> nixos.programs.nixvim";
  #   includes = [
  #     ({ class, aspect-chain }: den._.forward {
  #       each = [ "nixos" ];
  #       fromClass = _: "nixvim";
  #       intoClass = lib.id;
  #       intoPath = _: [ "programs" "nixvim" ];
  #       fromAspect = _: lib.head aspect-chain;
  #       guard = { options, ... }: options ? programs.nixvim;
  #       adaptArgs = { config, ... }: { osConfig = config; };
  #     })
  #   ];
  # };
}
