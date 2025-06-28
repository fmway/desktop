{ internal, inputs, self, super, ... }:
_: self.stdenv.mkDerivation {
  name = "waydroid-script";

  buildInputs = [
    (self.python3.withPackages(ps: with ps; [ tqdm requests inquirerpy ]))
  ];

  src = inputs.waydroid_script.outPath;

  postPatch = ''
    patchShebangs main.py
  '';

  installPhase = ''
    mkdir -p $out/libexec
    cp -r . $out/libexec/waydroid_script
    mkdir -p $out/bin
    ln -s $out/libexec/waydroid_script/main.py $out/bin/waydroid-script
  '';
}
