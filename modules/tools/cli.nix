{ lib, ... }:
{
  fmx.tools.cli = {
    nh.nixos = {
      programs.nh.enable = true;
      environment.sessionVariables = {
        NH_OS_FLAKE = "/etc/nixos";
      };
    };
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
