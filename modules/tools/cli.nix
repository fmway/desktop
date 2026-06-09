{ lib, ... }:
{
  fmx.tools.cli = {
    gnu-parallel = {
      nixos = { pkgs, ... }: {
        environment.systemPackages = [ pkgs.parallel ];
      };
      includes = [
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
  };
}
