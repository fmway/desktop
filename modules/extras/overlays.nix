{ inputs, lib, ... }:
{
  den.aspects.overlays._.nur = lib.mkCross {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };
}
