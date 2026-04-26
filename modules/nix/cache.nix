{ lib, fmx, ... }:
{
  # FIXME: nix classes (fmx.utils._.nix) replace arrays instead of merging
  # fmx.nix._.cache = {
  #   includes = builtins.attrValues fmx.nix._.cache._;
  #   _ = ((lib.import-tree
  #     .map (p: rec {
  #       name = lib.removeSuffix ".nix" (baseNameOf p);
  #       value = {
  #         description = "Nix Binary Caches from ${name}";
  #         nix = _: (import p).nix;
  #       };
  #     }))
  #     .pipeTo lib.listToAttrs)
  #     ./_cache;
  # };

  fmx.nix._.cache = {
    includes = builtins.attrValues fmx.nix._.cache._;
    _ = lib.import-tree.toAttrs (
      { name, path }:
      {
        description = "Nix Binary Caches from ${name}";
        __functor = _:
          { class, aspect-chain }:
          if builtins.elem class [ "nixos" "darwin" "homeManager" ] then {
            description = lib.unused aspect-chain "Nix Binary Caches from ${name}";
            ${class}.imports = [ path ];
          } else {};
      }) ./_cache;
  };
}
