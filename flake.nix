
{
  description = "My NixOS configuration";
  # Inputs
  inputs = {
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input  
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    h-m-m.url = "github:nadrad/h-m-m";
    h-m-m.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-24_11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-25_05.url = "github:NixOS/nixpkgs/nixos-24.05";
    master.url = "github:NixOS/nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    # TODO implement impermanence
    # impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };
    fmway-nix = {
      url = "github:fmway/fmway.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # flox.url = "github:flox/flox/v1.3.17";
    fmpkgs.url = "github:fmway/fmpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # TODO
    # nix-colors.url = "github:misterio77/nix-colors";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixgl.url = "github:nix-community/NixGL";
    nur.url = "github:nix-community/nur";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    systems.url = "github:nix-systems/default";
    nxchad.url = "github:fmway/nxchad";
    nxchad.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { home-manager, nxchad, fmway-nix, ... } @ inputs: let
    inherit (fmway-nix) lib;
  in lib.mkFlake {
      inherit inputs;
      specialArgs = {
        lib = [
          home-manager.lib
          {
            inherit (fmway-nix) infuse readTree fmway;
            inherit (nxchad.lib) nixvim;
          }
          (self: super: import ./lib { lib = self; inherit self super; })
        ];
      };
    } {
      imports = lib.fmway.genImports ./top-level ++ [
        ({ self, config, lib, ... } @ v: let
        in {
          disabledModules = [ "${inputs.flake-parts}/modules/nixosModules.nix" ];
          flake = lib.fmway.genModules ./modules v;
        })
        ({ lib, ... }: { flake = { inherit lib; }; })
      ];
    };
  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cache.lix.systems"
      "https://fmcachix.cachix.org"
      "https://devenv.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://catppuccin.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "fmcachix.cachix.org-1:Z5j9jk83ctoCK22EWrbQL6AAP3CTYnZ/PHljlYSakrw="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}

