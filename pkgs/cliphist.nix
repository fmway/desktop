{ internal, self, lib, pkgs ? self, ... }:
pkg: pkgs.symlinkJoin {
  inherit (pkg) name pname version meta;
  paths = [ pkg ] ++ lib.optionals (!lib.pathExists "${pkg}/bin/cliphist-fuzzel-img") [
    (let
      txt = lib.fileContents (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/sentriz/cliphist/refs/heads/master/contrib/cliphist-fuzzel-img";
        hash = "sha256-NgQ87yZCusF/FYprJJ+fvkA3VdrvHp4LyylQ0ajBvjU=";
      });
    in pkgs.writeScriptBin "cliphist-fuzzel-img" (
      lib.replaceStrings
        [ "#!/usr/bin/env bash" ]
        [ "#!${lib.getExe pkgs.bash}\nexport PATH=$PATH:${lib.makeBinPath [ pkgs.imagemagick pkg ]}" ]
        txt
    ))
  ];
 }
