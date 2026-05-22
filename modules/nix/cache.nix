{ lib, fmx, ... }:
{
  fmx.nix._.cache = {
    includes = builtins.attrValues fmx.nix._.cache._;
    _ = lib.import-tree.toAttrs (
      { name, path }:
      {
        description = "Nix Binary Caches from ${name}";
      } // lib.genAttrs [ "nixos" "darwin" "homeManager" ] (class: {
        imports = [ path ];
      })) ./_cache;
  };
}
