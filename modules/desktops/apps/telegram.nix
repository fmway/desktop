{
  fmx.desktops._.apps._.telegram = {
    includes = [
      ({ persistent, user, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".local/share/TelegramDesktop"
        ];
      })
    ];
    homeManager = { pkgs, ... }:
    {
      home.packages = [ pkgs.telegram-desktop ];
    };
  };
}
