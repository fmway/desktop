{ sources, den, ... }:
{
  fmx.tools.productivity = {
    zoom.includes = [
      (den._.unfree [ "zoom" ])
      (den._.user-packages [ "zoom" ])
    ];

    libreoffice.includes = [
      (den._.user-packages [ "libreoffice-fresh" ])
    ];

    zotero.includes = [
      (den._.user-packages [ "zotero" ])
      ({ persistent, user, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [ "Zotero" ];
      })
    ];

    # Alternative LaTex
    typst.includes = [
      (den._.user-packages [ "typst" ])
    ];

    # Hacker mind map
    h-m-m.includes = [
      (den._.user-packages (pkgs: import sources.h-m-m { inherit pkgs; version = "0.0.1-dev"; }))
    ];
  };

  source-archives.h-m-m = "https://github.com/nadrad/h-m-m/archive/main.tar.gz";
}
