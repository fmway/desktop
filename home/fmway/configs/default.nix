{ config, pkgs, lib, ... } @ v: let
  dir = /. + builtins.toPath ./.;
  list = lib.filter (x: x != "default.nix") (lib.fmway.tree-path { inherit dir; prefix = ""; });
in {
  xdg.configFile = lib.listToAttrs (map (x: let
    name = lib.removeSuffix ".nix" x;
    parseify = lib.fmway.mkParse v (builtins.readFile "${dir}/${name}");
    imported = import "${dir}/${x}" v;
  in {
    inherit name;
    value.text = if lib.hasSuffix ".nix" x then
      imported
    else parseify;
  }) list);
}
