{ inputs, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
  ];

  systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

  flake-file.inputs = {
    # core flake
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    fmway-lib = {
      url = "github:fmway/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
  };

}
