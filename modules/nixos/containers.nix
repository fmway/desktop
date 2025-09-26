{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    # qemu_full
    # qemu with efi 
    # (writeShellScriptBin "qemu-system-x86_64-uefi" ''
    #   qemu-system-x86_64 \
    #     -bios ${OVMF.fd}/FV/OVMF.fd \
    #     "$@"
    # '')
    # quickemu
    podman-compose
    # docker-compose
    distrobox
  ];

  # Podman configurations
  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = lib.mkDefault true;
  virtualisation = {
    # podman = {
    #   enable = lib.mkDefault true;
    #
    #   # Create a `docker` alias for podman, to use it as a drop-in replacement
    #   dockerCompat = true;
    #
    #   # Required for containers under podman-compose to be able to talk to each other.
    #   defaultNetwork.settings.dns_enabled = true;
    # };

    docker.enable = lib.mkDefault true;
    # docker.rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };

    # virtualbox = {
    #   host = {
    #     enable = true;
    #     package = pkgs.virtualbox;
    #   };
    #   guest.enable = true;
    # };
    #
    # waydroid.enable = true;
  };
}
