{ inputs, ... }:
{
  den.aspects.overlays._.nur = rec {
    nixos.nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
    homeManager = nixos;
  };
}
