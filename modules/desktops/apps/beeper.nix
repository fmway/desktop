{ den, ... }:
{
  fmx.desktops._.apps._.beeper = {
    includes = [
      (den._.user-packages [ "beeper" ])
      (den._.unfree [ "beeper" ])
      ({ persistent, user, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".var/app/com.beepertexts"
        ];
      })
    ];

    nixpak.beeper = { pkgs, sloth, ... }:
    {
      imports = [ ./_chat.nix ];
      app.package = pkgs.beeper;
      flatpak.appId = "com.beepertexts";
    };
  };
}
