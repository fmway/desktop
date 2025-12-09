
{
  description = "My NixOS configuration";
  # Inputs
  inputs = {
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";
    zed.url = "github:zed-industries/zed";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input  
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    # TODO implement impermanence
    # impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fmway-lib = {
      url = "github:fmway/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fmway-modules.url = "github:fmway/modules";
    fmway-modules.inputs.fmway-lib.follows = "fmway-lib";
    fmway-pkgs.url = "github:fmway/pkgs";
    fmway-pkgs.inputs.nixpkgs.follows = "nixpkgs";
    # flox.url = "github:flox/flox/v1.3.17";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # TODO
    # nix-colors.url = "github:misterio77/nix-colors";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixgl.url = "github:nix-community/NixGL";
    nur.url = "github:nix-community/nur";
    nur.inputs.flake-parts.follows = "flake-parts";
    nur.inputs.nixpkgs.follows = "nixpkgs";
    systems.url = "github:nix-systems/default";
    nxchad.url = "github:fmway/nxchad";
    nxchad.inputs.nixpkgs.follows = "nixpkgs";
    nxchad.inputs.fmway-lib.follows = "fmway-lib";
    nxchad.inputs.fmway-modules.follows = "fmway-modules";
    nxchad.inputs.flake-parts.follows = "flake-parts";
    nxchad.inputs.nixvim.follows = "nixvim";
    nxchad.inputs.systems.follows = "systems";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.flake-parts.follows = "flake-parts";
    nixvim.inputs.systems.follows = "systems";
  };

  outputs = { home-manager, nxchad, fmway-modules, fmway-lib, ... } @ inputs:
  fmway-lib.mkFlake {
    src = ./.;
    inherit inputs;
    specialArgs = {
      sources = import ./sources;
      lib = [
        home-manager.lib
        fmway-modules.lib
        {
          inherit (nxchad.lib) nixvim;
        }
      ];
    };
  } {
    imports = [
      inputs.fmway-modules.flakeModules.packages
      {
        disabledModules = [ "${inputs.flake-parts}/modules/nixosModules.nix" ];
      }
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

