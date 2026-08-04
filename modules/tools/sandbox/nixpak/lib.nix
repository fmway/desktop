{ inputs, lib, require, ... }:
require (inputs ? nixpak) {
  __functor = _: pkgs: import "${inputs.nixpak}/modules" { inherit pkgs lib; };
  # mkOverlay = package: { ... } @ module: lib.genAttrs [ "nixos" "darwin" "homeManager" ] (class: {
  #   nixpkgs.overlays = [
  #     (self: super: let
  #       paths = lib.splitString "." package;
  #       pkg = lib.getAttrFromPath paths self;
  #       r = lib.sandbox.nixpak self {
  #         config.imports = [ module ];
  #         config.app.package = pkg;
  #       };
  #     in lib.setAttrByPath paths r.config)
  #   ];
  # });
}
