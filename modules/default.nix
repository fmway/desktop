{ inputs, config, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    # core flake
    systems.url = "github:nix-systems/triplet";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    fmway-lib = {
      url = "github:fmway/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fmway-modules.url = "github:fmway/modules";
    fmway-modules.inputs = {
      fmway-lib.follows = "fmway-lib";
      nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:denful/flake-file";
    import-tree.url = "github:denful/import-tree";
    nur.url = "github:nix-community/nur";
    nur.inputs.flake-parts.follows = "flake-parts";
    nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  # auto update lock (if adding / removing inputs)
  flake-file.write-hooks = [
    {
      index = 1000;
      program = pkgs: pkgs.writeShellApplication {
        name = "nix-flake-lock";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          nix flake lock
        '';
      };
    }
  ];

  perSystem = { pkgs, lib, ... }:
  {
    packages = import ../packages { inherit pkgs lib; };
  };
}
