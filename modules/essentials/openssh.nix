{
  fmx.essentials._.openssh.nixos.services.openssh = {
    enable = true;
    # use public key instead of password
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = true;
    settings.PermitRootLogin = "yes";
  };

  fmx.essentials._.openssh._.google-auth.nixos =
  { pkgs, ... }:
  {
    # enable google totp in ssh login
    security.pam.services.sshd.googleAuthenticator.enable = true;
    # only allow otp when user already set
    security.pam.services.sshd.googleAuthenticator.allowNullOTP = true;
    environment.systemPackages = [
      pkgs.google-authenticator
    ];
  };
}
