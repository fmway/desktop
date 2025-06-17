{ internal, lib, self, pkgs ? self, ... } @ v: let
  inherit (lib.fmway) tree-path hasSuffix' removeSuffix' mkParse';
  dir = ./.;
  parse = mkParse' (v // { pkgs = self; });
  allowed-exts = [ ".sh" ];
  list = lib.filter (hasSuffix' allowed-exts) (tree-path { inherit dir; prefix = ""; });
  result = lib.listToAttrs (map (x: rec {
    name = removeSuffix' allowed-exts x;
    value = pkgs.writeScriptBin name (parse (builtins.readFile "${dir}/${x}"));
  }) list);
in x: result // {
  all = pkgs.symlinkJoin {
    name = "my-script";
    paths = lib.attrValues result;
  };
}
