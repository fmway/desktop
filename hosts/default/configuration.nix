{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.fmway-conf.nixosModules.default
    inputs.fmway-pkgs.nixosModules.default
  ];

  # Enable fwupd for updating firmware
  services.fwupd.enable = true;

  programs.git.enable = true;

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
