# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  nixConfig = {
    extra-substituters = [
      "https://catppuccin.cachix.org"
      "https://selector4nix.cachix.org/"
      "https://nix-community.cachix.org"
      "https://nyx-cache.chaotic.cx/"
      "https://cache.clan.lol"
      "https://devenv.cachix.org"
      "https://fmcachix.cachix.org"
      "https://moku.cachix.org"
      "https://cache.numtide.com"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "selector4nix.cachix.org-1:wovVlT07In5JCVz2tFgxPQTLpnN8hZT6P/RwfFcz3KE="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
      "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "fmcachix.cachix.org-1:Z5j9jk83ctoCK22EWrbQL6AAP3CTYnZ/PHljlYSakrw="
      "moku.cachix.org-1:EnMXp6/uQVI6IRbKW0xEQylSYoV2N4vszOsoW6/Pq1s="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  inputs = {
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "github:fmway/den/feat/den.lib.pipes";
    disko = {
      url = "github:nix-community/disko";
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
    fmway-inputs.url = "github:fmway/inputs";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.inputs.systems.follows = "systems";
      };
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
    import-tree.url = "github:denful/import-tree/4ebb10ae17d5f1ad366e7aef5b92cb8eecf24f69";
    jail-nix = {
      url = "sourcehut:~alexdavid/jail.nix";
      flake = false;
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs.flake-parts.follows = "flake-parts";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      flake = false;
    };
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.inputs.systems.follows = "systems";
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
        systems.follows = "systems";
      };
    };
    systems.url = "github:nix-systems/triplet";
  };
}
