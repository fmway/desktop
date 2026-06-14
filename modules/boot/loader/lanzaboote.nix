# Secureboot using lanzaboote
{ inputs, lib, config, ... }: let
  moduleFile = "${inputs.lanzaboote}/nix/modules/lanzaboote.nix";
  moduleStr = builtins.readFile moduleFile;
  replace = {
    "boot.bootspec = {\n      enable = true;" = "boot.bootspec = {";
  };
  replaceK = builtins.attrNames replace; replaceV = builtins.attrValues replace;
  patchModule =
    if builtins.any (lib.flip lib.hasInfix moduleStr) replaceK then
      builtins.toFile "lanzaboote.nix" (builtins.replaceStrings replaceK replaceV moduleStr)
    else moduleFile;
in {
  fmx.boot._.lanzaboote = {
    includes = [
      ({ persistent, ... }: {
        persistence.${persistent.defaultDirectory}.directories = [ "/var/lib/sbctl" ];     
      })
    ];

    nixos = { host, pkgs, ... }:
    {
      imports = [ patchModule ];
      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = host.configurationLimit or 25;
        package = lib.mkDefault inputs.lanzaboote.packages.${host.system}.lzbt;
      };
    };
  };

  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/v1.0.0";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    } // lib.optionalAttrs (config.flake-file.inputs ? rust-overlay) {
      rust-overlay.follows = "rust-overlay";
    };
  };
}
