{ inputs, ... }:
{
  den.aspects.overlays.nur = rec {
    nixos.nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
    homeManager = nixos;
  };
}
