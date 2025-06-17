{ config, pkgs, lib, ... } @ v: let
  dir = ./.;
  list = lib.filter (x: x != "default.nix") (lib.fmway.tree-path { inherit dir; prefix = ""; });
in {
  xdg.configFile = lib.listToAttrs (map (name: {
    inherit name;
    value.text = lib.fmway.mkParse' v (builtins.readFile "${dir}/${name}");
  }) list);
}
