{ config, lib, inputs, ... }:
{
  fmx.desktops._.shells._.noctalia = {
    homeManager = { pkgs, ... }: let
      noctalia-shell = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in {
      home.packages = with pkgs; [
        libappindicator
        libdbusmenu
        cliphist
        noctalia-shell
      ];
    };

    includes = [
      ({ user, ... }: {
        nixos.users.users.${user.userName}.extraGroups = [ "i2c" "input" ];
      })
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
      boot.kernelModules = [
        "i2c-dev"
      ];
      boot.initrd.availableKernelModules = [
        "i2c-dev"
      ];

      environment.systemPackages = with pkgs; [
        ddcutil
        evtest
        wl-mirror
        gpu-screen-recorder
      ];
      services.udev.packages = with pkgs; [
        ddcutil
      ];
      users.groups.i2c = {};
    };
  };

  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs = {
      nixpkgs.follows = "nixpkgs";
    } // lib.optionalAttrs (config ? flake-file.inputs.nixvim) {
      noctalia-qs.inputs.systems.follows = "nixvim/systems";
    };
  };
}
