{ lib, ... }:
{
  fmx.nix._.gc =
  options: dates: let
    nix.gc = {
      automatic = true;
      inherit options dates;
    };
  in {
    nixos.nix = nix;
    homeManager.nix = nix;
  };
}
