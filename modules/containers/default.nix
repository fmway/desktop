{ __findFile, ... }:
{
  # enable flatpak support
  fmx.containers._.flatpak.nixos.services.flatpak.enable = true;
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

  fmx.containers._.podman.nixos = {
    virtualisation.podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # TODO
  # fmx.containers._.docker._.impermanence = { persistent, ... }:
  # {
  #   nixos.environment.persistence.${persistent.cacheDirectory}.directories = [
  #     "/var/lib/docker"
  #     "/var/lib/containers/"
  #   ];
  # };
  # fmx.containers._.podman._.impermanence = { persistent, ... }:
  # {
  #   nixos.environment.persistence.${persistent.cacheDirectory}.directories = [
  #     "/var/lib/containers/"
  #   ];
  # };
}
