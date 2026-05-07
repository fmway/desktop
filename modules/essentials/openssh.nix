{
  fmx.essentials._.openssh.nixos.services.openssh = {
    enable = true;
    # use public key instead of password
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = true;
    settings.PermitRootLogin = "yes";
  };
}
