{ den, lib, ... }:
{
  fmx.desktops._.apps._.appflowy = {
    includes = [
      (den._.user-packages [ "appflowy" ])
      (den._.unfree [ "appflowy" ])
      ({ persistent, user, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".local/share/io.appflowy.appflowy"
        ];
      })
    ];
  };
}
