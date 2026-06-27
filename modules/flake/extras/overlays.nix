{ inputs, lib, ... }: let
  mkCross = module: {
    nixos = module;
    darwin = module;
    homeManager = { osConfig, ... }: lib.optionalAttrs (!osConfig.home-manager.useGlobalPkgs or false) module;
  };
in {
  den.aspects.overlays._.nur = mkCross {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };
}
