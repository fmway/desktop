let
  persistContainerAspect = {
    name = "persist@container";
    includes = [
      ({ persistent, ... }: {
        persistence.${persistent.cacheDirectory}.directories = [
          { directory = "/var/lib/containers"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
        ];
      })
    ];
  };
in {
  # enable flatpak support
  fmx.containers.flatpak = {
    nixos.services.flatpak.enable = true;
    includes = [
      ({ persistent, user, host, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/flatpak"
          ".local/share/flatpak"
        ];
      })
    ];
  };
  fmx.containers.bottles = {
    nixos = { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.bottles.override {
          removeWarningPopup = true;
        })
      ];
    };
    includes = [
      ({ persistent, user, host, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".local/share/bottles"
        ];
      })
    ];
  };

  fmx.containers.distrobox.nixos = { pkgs, ... }:
  {
    environment.systemPackages = [ pkgs.distrobox ];
  };

  fmx.containers.docker = {
    nixos.virtualisation.docker.enable = true;
    includes = [
      ({ user, ... }: {
        nixos.users.users.${user.userName}.extraGroups = [ "docker" ];
      })
      ({ persistent, ... }: {
        persistence.${persistent.cacheDirectory}.directories = [
          { directory = "/var/lib/docker"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
        ];
      })
      persistContainerAspect
    ];

    rootless = {
      includes = [
        <fmx/containers/docker>
      ];
      nixos.virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  fmx.containers.podman = {
    nixos.virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    includes = [
      persistContainerAspect
    ];
  };
}
