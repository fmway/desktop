# Secureboot using lanzaboot
{ inputs, lib, config, ... }:
{
  fmx.boot._.secure.nixos = { pkgs, ... }:
  {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
    environment.systemPackages = [
      pkgs.sbctl
    ];

    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.grub.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
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
