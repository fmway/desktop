{
  fmx.essentials.openssh = {
    includes = [
      ({ persistent, ... }: {
        persistence = {
          ${persistent.defaultDirectory}.directories = [
            { directory = "/etc/ssh"; mode = "u=rwx,g=rx,o=x"; }
          ];
        };
      })
    ];
    nixos.services.openssh = {
      enable = true;
      # use public key instead of password
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # TODO: cross hosts
  fmx.essentials.openssh.allow-users = { host, ... }:
  {
    nixos.imports = let
      collectKeys = builtins.concatMap (user: user.sshKeys) (builtins.attrValues host.users);
    in map (user: {
      users.users.${user}.openssh.authorizedKeys.keys = collectKeys;
    }) (builtins.attrNames host.users ++ [ "root" ]);
  };

  fmx.essentials.openssh.google-auth.nixos =
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
