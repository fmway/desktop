{ inputs, lib, ... }:
inputs.nxchad.lib.extend (se: su: let
  k'= idx: res: x:
    if lib.isString x then
      k' (idx + 1) (res // { "__unkeyed-${toString idx}" = x; })
    else res // x;
  k = k' 1 {};
  lz-n.expand = map (x: if lib.isFunction x then let
    r = x arg;
    fArgs = builtins.functionArgs x;
    arg =
      if fArgs == {} then
        su.toLuaObject (r.opts or {})
      else
        lib.mapAttrs (k: _: r.${k}) (lib.filterAttrs (_: v: !v) fArgs);
    excludes = r.excludes or [] ++ [ "excludes" "opts" ];
  in removeAttrs r excludes else x);
in {
  toLuaObject' = x: if isNull x then "" else se.toLuaObject x;
  inherit k lz-n;
})
