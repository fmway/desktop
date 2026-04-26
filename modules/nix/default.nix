{ __findFile, den, lib, ... }:
{
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
  fmx.nix = { class, aspect-chain }:
    if lib.unused aspect-chain builtins.elem class [ "nixos" "homeManager" "darwin" ] then {
      includes = [
        <fmx/nix/cache>
      ];
      ${class}.nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = false;
      };
    } else {};
}
