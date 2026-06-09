{ den, ... }:
{
  fmx.tools.drive.megasync = {
    includes = [
      (den._.unfree [ "megasync" ])
      ({ persistent, user, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".local/share/data/Mega Limited/MEGAsync"
        ];
      })
    ];
    homeManager.services.megasync = {
      enable = true;
      forceWayland = true;
    };
  };
  fmx.tools.clipboard.cliphist = {
    includes = [
      ({ persistent, user, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".cache/cliphist"
        ];
      })
    ];
    homeManager = { pkgs, ... }:
    {
      home.packages = [ pkgs.cliphist ];
    };
  };
}
