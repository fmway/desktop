{ lib, ... }:
lib.hm.nushell // rec {
  mkNushellFn' = indent: fn: let
    args = builtins.attrNames (builtins.functionArgs fn);
    args'= builtins.listToAttrs (map (name: {
      inherit name;
      value = "$" + name;
    }) args);
    str =
      "{|"
    + builtins.concatStringsSep ", " args
    + "| \n"
    + lib.fmway.addIndent "  " (fn args')
    + "}";
  in lib.fmway.addIndent indent str;
  mkNushellFn = mkNushellFn' "";
  mkNushellFnInline = x: lib.hm.nushell.mkNushellInline (mkNushellFn x);
  mkNushellFnInline' = indent: x: lib.hm.nushell.mkNushellInline (mkNushellFn' indent x);
}
