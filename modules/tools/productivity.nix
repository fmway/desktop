{ sources, den, ... }: let
  mkAllPackages = fn: {
    nixos = { pkgs, ... }: { environment.systemPackages = fn pkgs;};
    homeManager = { pkgs, ... }: { home.packages = fn pkgs; };
  };
in {
  fmx.tools.productivity = {

    zoom = mkAllPackages (pkgs: [ pkgs.zoom-us ]) // {
      includes = [
        (den._.unfree [ "zoom" ])
      ];
    };

    libreoffice = mkAllPackages (pkgs: [ pkgs.libreoffice-fresh ]);

    zotero = mkAllPackages (pkgs: [ pkgs.zotero ]) // {
      includes = [
        ({ persistent, user, ... }: {
          persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [ "Zotero" ];
        })
      ];
    };

    # Alternative LaTex
    typst = mkAllPackages (pkgs: [ pkgs.typst ]);

    # Hacker mind map
    h-m-m = mkAllPackages (pkgs: [
      (import sources.h-m-m { inherit pkgs; version = "0.0.1-dev"; })
    ]);
  };

  source-archives.h-m-m = "https://github.com/nadrad/h-m-m/archive/main.tar.gz";
}
