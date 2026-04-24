{ __findFile, ... }:
{
  fmx.nix = let
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    nix.settings.auto-optimise-store = false;
  in {
    includes = [
      <fmx/nix/cache>
    ];
    nixos.nix = nix;
    homeManager.nix = nix;
  };
}
