{ internal, _file, self, name, inputs, selfInputs ? inputs, ... }:
{ inputs, lib, pkgs, config, osConfig ? {}, ... }:

{
  inherit _file;
  config = lib.mkIf (name != "homeManagerModules" || ! osConfig.home-manager.useGlobalPkgs or true) {
    nixpkgs.overlays = [
      self.overlays.default
    ];
  };
}
