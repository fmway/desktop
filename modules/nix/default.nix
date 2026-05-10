{ lib, ... }:
{
  fmx.nix = { config, ... }:
  {
    includes = [ config._.cache ];
    __functor = _:
      { class, aspect-chain }:
      if lib.unused aspect-chain builtins.elem class [ "nixos" "homeManager" "darwin" ] then {
        ${class}.nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = false;
        };
      } else {};
  };
}
