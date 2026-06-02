{
  # enable flatpak support
  fmx.containers._.flatpak = {
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
  fmx.containers._.bottles.includes = [
    ({ persistent, user, host, ... }: {
      persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
        ".local/share/bottles"
      ];
    })
  ];
  fmx.containers._.bottles.nixos = { pkgs, ... }:
  {
    environment.systemPackages = [
      (pkgs.bottles.override {
        removeWarningPopup = true;
      })
    ];
  };
  fmx.containers._.distrobox.nixos = { pkgs, ... }:
  {
    environment.systemPackages = [ pkgs.distrobox ];
  };

  fmx.containers._.docker = {
    nixos.virtualisation.docker.enable = true;
    includes = [
      ({ user, ... }: {
        nixos.users.users.${user.userName}.extraGroups = [ "docker" ];
      })
      ({ persistent, ... }: {
        persistence.${persistent.cacheDirectory}.directories = [
          { directory = "/var/lib/docker"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
          { directory = "/var/lib/containers"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
        ];
      })
    ];
  };
  fmx.containers._.docker._.rootless = {
    includes = [
      <fmx/containers/docker>
    ];
    nixos.virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  fmx.containers._.podman = {
    nixos.virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

    includes = [
      ({ persistent, ... }: {
        persistence.${persistent.cacheDirectory}.directories = [
          { directory = "/var/lib/containers"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
        ];
      })
    ];
  };
}
