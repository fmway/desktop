{ lib, den, ... }:
{
  fmx.tools.cli = {
    rclone.includes = [
      (den._.system-packages [ "rclone" ])
      ({ user, persistent, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.files = [ ".config/rclone/rclone.conf" ];
      })
    ];
    cachix.includes = [
      (den._.system-packages [ "cachix" ])
      ({ user, persistent, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.files = [ ".config/cachix/cachix.dhall" ];
      })
    ];
    nh.nixos = {
      programs.nh.enable = true;
      environment.sessionVariables = {
        NH_OS_FLAKE = "/etc/nixos";
      };
    };
    gnu-parallel.includes = [
      (den._.system-packages [ "parallel" ])
      ({ persistent, host, ... }: {
        persistence.${persistent.cacheDirectory} = {
          files = [ "/root/.parallel/will-cite" ];
          users = lib.mapAttrs' (_: user: {
            name = user.userName;
            value.files = [ ".parallel/will-cite" ];
          }) host.users;
        };
      })
    ];
  };
}
