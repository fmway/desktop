{
  fmx.containers._.waydroid = { persistent, ... }:
  {
    nixos = { pkgs, ... }:
    {
      virtualisation.waydroid.enable = true;
      environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
          name = "waydroid-script";

          buildInputs = [
            (pkgs.python3.withPackages(ps: with ps; [ tqdm requests inquirerpy ]))
          ];

          src = <sources/waydroid-script>;

          postPatch = ''
            patchShebangs main.py
          '';

          installPhase = ''
            mkdir -p $out/libexec $out/bin
            cp -r . $out/libexec/waydroid_script
            ln -s $out/libexec/waydroid_script/main.py $out/bin/waydroid-script
          '';
        })
      ];
    };

    includes = [
      ({ host, user, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".local/share/waydroid"
        ];
      })
    ];
    persistence = {
      ${persistent.cacheDirectory}.directories = [
        { mode = "0755"; directory = "/var/lib/waydroid"; user = "root"; group = "root"; }
      ];
    };
  };

  source-archives."waydroid-script" = "https://github.com/casualsnek/waydroid_script/archive/main.tar.gz";
}
