{ internal, sources, self, super, ... }:
_: self.stdenv.mkDerivation {
  name = "waydroid-script";

  buildInputs = [
    (self.python3.withPackages(ps: with ps; [ tqdm requests inquirerpy ]))
  ];

  src = sources.waydroid-script;

  postPatch = ''
    patchShebangs main.py
  '';

  installPhase = ''
    mkdir -p $out/libexec $out/bin
    cp -r . $out/libexec/waydroid_script
    ln -s $out/libexec/waydroid_script/main.py $out/bin/waydroid-script
  '';
}
