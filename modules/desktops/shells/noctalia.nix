{ config, lib, inputs, ... }:
{
  fmx.desktops._.shells._.noctalia = {
    homeManager = { pkgs, ... }: let
      noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in {
      home.packages = with pkgs; [
        libappindicator
        libdbusmenu
        noctalia-shell
      ];
    };

    includes = [
      <fmx/desktops/utils/ddc>
      <fmx/tools/clipboard/cliphist>
      ({ user, persistent, host, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".config/noctalia"
        ];
      })
      ({ user, persistent, host, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/noctalia"
        ];
      })
    ];

    nixos = { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        evtest
        wl-mirror
        gpu-screen-recorder
      ];
    };
  };

  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      noctalia-qs.inputs.systems.follows = "systems";
    };
  };
}
