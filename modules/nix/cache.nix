{ lib, fmx, ... }:
{
  fmx.nix.cache = {
    includes = [ <fmx/nix/cache/_> ];
  } // lib.import-tree.toAttrs ({ name, path }: {
    description = "Nix Binary Caches from ${name}";
  } // lib.genAttrs [ "nixos" "darwin" "homeManager" ] (class: {
    imports = [ path ];
  })) ./_cache;
}
