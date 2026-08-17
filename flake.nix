# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:denful/den/main";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dsearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:denful/flake-file";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    fmway-garden = {
      url = "github:fmway/garden";
      inputs.import-tree.follows = "import-tree";
    };
    fmway-lib = {
      url = "github:fmway/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fmway-modules = {
      url = "github:fmway/modules";
      inputs = {
        fmway-lib.follows = "fmway-lib";
        nixpkgs.follows = "nixpkgs";
      };
    };
    helium = {
      url = "github:vikingnope/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    import-tree.url = "github:denful/import-tree";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.inputs.systems.follows = "nixvim/systems";
      };
    };
    nur = {
      url = "github:nix-community/nur";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nxchad = {
      url = "github:fmway/nxchad";
      inputs = {
        flake-parts.follows = "flake-parts";
        fmway-lib.follows = "fmway-lib";
        fmway-modules.follows = "fmway-modules";
        nixpkgs.follows = "nixpkgs";
        nixvim.follows = "nixvim";
        systems.follows = "nixvim/systems";
      };
    };
  };
}
