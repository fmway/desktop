{ lib, super, ... }:
super.fish or {} // {
  /*
    fish.importFunctions :: Path :: Attrs
    auto imports all file with .fish ext, use this in programs.fish.functions
  */
  importFunctions = d: let
    dir = builtins.toPath d;
    scanned = builtins.readDir dir;
    filtered = lib.filterAttrs (p: t:
      t == "regular" && lib.hasSuffix ".fish" p
    ) scanned;
  in lib.mapAttrs' (x: _: let
    name = lib.removeSuffix ".fish" x;
    content = lib.fileContents "${dir}/${x}";
    value = lib.fmway.parseFish content;
  in 
    lib.nameValuePair name value
  ) filtered;
}
