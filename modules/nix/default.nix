{ lib, ... }:
{
  fmx.nix = { config, ... }:
  {
    includes = [
      config._.cache
      ({ class, aspect-chain }:
      lib.optionalAttrs (builtins.elem class [ "nixos" "homeManager" "darwin" ]) {
        ${class}.nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = false;
        };
      })
    ];
    homeManager = { pkgs, ... }: {
      nix.package = lib.mkDefault pkgs.nix;
    };
  };
}
