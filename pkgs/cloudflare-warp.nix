{ internal, self, ... }: pkg: self.symlinkJoin {
  inherit (pkg) pname name version meta;
  paths = [pkg];
  postBuild = /* sh */ ''
    cp -rf * $out/
    rm -rf $out/etc $out/lib
  ''; # remove autostart, very annoying
}
