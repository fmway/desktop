{ den, fmx, lib, ... }: let
  dir = builtins.toPath ./_programs;
in {
  fmx.programs = ((lib.import-tree
    .map (p: let k = lib.splitString "/" (lib.removePrefix "${dir}/" (lib.removeSuffix ".nix" p)); l = lib.last k; in {
      keys = if k == [ "default" ] then [ "programs" ] else [ "_" ] ++ lib.init k ++ lib.optional (l != "default") l ++ [ "programs" ];
      value = args: (x: if builtins.isFunction x then x args else x) (import p);
    }))
    .pipeTo (builtins.foldl' (a: c: lib.recursiveUpdate a (lib.setAttrByPath c.keys c.value)) {
      includes = builtins.attrValues fmx.programs.provides;
    }))
    dir;
}
