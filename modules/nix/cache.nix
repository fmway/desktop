{ lib, ... }:
{
  fmx.nix.cache = {
    includes = [ <fmx/nix/cache/_> ];
  } // lib.import-tree.toAttrs (
    { name, path }:
    {
      name = "fmx@nix.cache.${name}";
      description = "Nix Binary Caches from ${name}";
    } // lib.genAttrs [ "nixos" "darwin" "homeManager" ] (class: {
      imports = [ path ];
    })) ./_cache;
}
