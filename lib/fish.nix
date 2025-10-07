{ lib, ... }: let
  mkBind = initial: keys: x:
  if builtins.isAttrs x then
    { inherit keys; } // initial // x
  else mkBind (initial // {
    commands = initial.commands or [] ++ lib.fmway.flat x;
  }) keys;
  op = { bind' = "preset"; bind_ = "user"; bind = null; };
  modes = [ "default" "insert" "replace" "replace_one" "visual" ];
  setsBind = lib.listToAttrs (lib.mapAttrsToList (name: operate: {
    inherit name;
    value = let
      i = lib.optionalAttrs (!isNull operate) { inherit operate; };
      mkErase = initial: mkBind ({ erase = true; } // initial);
      r = lib.listToAttrs (map (x: {
        name = if isNull x then "__functor" else x;
        value = let
          i' = i // lib.optionalAttrs (!isNull x) { mode = x; };
          y = mkBind i';
        in if isNull x then _: y else { __functor = _: y; erase = mkErase i'; };
      }) ([ null ] ++ modes));
    in { erase = mkErase i; } // r;
  }) op);
in setsBind // {
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
