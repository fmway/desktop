{ config, lib, inputs, ... }:
{
  fmx.desktops._.shells._.noctalia._.v4 = {
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
    ];

    nixos = { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        evtest
        wl-mirror
        gpu-screen-recorder
      ];
    };

    inputs.noctalia-v4 = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        noctalia-qs.inputs.systems.follows = "systems";
      };
    };
  };
}
