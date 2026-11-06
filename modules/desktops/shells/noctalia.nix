{ den, lib, inputs, ... }:
{
  fmx.desktops._.shells._.noctalia._.v5 = {
    nixos = { pkgs, ... }: {
      imports = [
        (inputs.fmway-inputs.noctalia.nixosModules.noctalia or inputs.noctalia.nixosModules.default)
      ];

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      environment.systemPackages = with pkgs; [
        evtest
        wl-mirror
        gpu-screen-recorder
      ];
    };

    includes = [
      <fmx/desktops/utils/ddc>
      ({ user, persistent, host, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/noctalia"
          ".local/state/noctalia"
        ];
      })
    ];

    extraCaches.noctalia = {
      substituters = [ "https://noctalia.cachix.org" ];
      trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };
  };
}
