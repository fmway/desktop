{ __findFile, den, lib, ... }:
{
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
