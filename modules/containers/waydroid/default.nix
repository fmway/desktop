{ __findFile, ... }:
{
  fmx.containers._.waydroid.nixos = { pkgs, ... }:
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

  source-archives."waydroid-script" = "https://github.com/casualsnek/waydroid_script/archive/main.tar.gz";
}
