# Secureboot using lanzaboote
{ inputs, lib, config, ... }:
{
  fmx.boot._.lanzaboote = {
    includes = [
      ({ persistent, ... }: {
        persistence.${persistent.defaultDirectory}.directories = [ "/var/lib/sbctl" ];     
      })
    ];

    nixos = { host, pkgs, ... }:
    {
      imports = [
        (inputs.fmway-inputs.lanzaboote or inputs.lanzaboote).nixosModules.default
      ];
      environment.systemPackages = [
        pkgs.sbctl
      ];

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
        configurationLimit = host.configurationLimit or 25;
      };
    };

    inputs = { inputs, ... }: {
      lanzaboote = {
        enable = !inputs.fmway-inputs.enable or true;
        url = "github:nix-community/lanzaboote/v1.2.0";
        inputs = {
          nixpkgs.follows = "nixpkgs";
        } // lib.optionalAttrs (inputs ? rust-overlay) {
          rust-overlay.follows = "rust-overlay";
        };
      };
    };
  };
}
