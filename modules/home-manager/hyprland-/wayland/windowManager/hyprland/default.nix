{ pkgs, uncommon, lib, config, ... }: let
  parseBind = prefix: obj:
    map (x: let
      key = let
        y = map (x: if x == "" then "+" else x) (lib.splitString "+" x);
        length = lib.length y;
        h = lib.concatStringsSep " " (if length == 1 then [""] else lib.take (length - 1) y);
        t = lib.last y;
      in [ h t ];
      toValue = v: let
        y = lib.splitString " " obj.${x};
        h = lib.head y;
        t = lib.concatStringsSep " " (lib.tail y);
      in [ h ] ++ lib.optionals (lib.length y != 1) [ t ];
      value = map toValue (lib.flatten [ obj.${x} ]);
    in map (z: 
      "${prefix} = ${lib.trim (lib.concatStringsSep ", " (key ++ z))}") value
    ) (lib.attrNames obj);

  parseBinds = { ... } @ args: let
    binds = lib.filter (lib.hasPrefix "bind") (lib.attrNames args);
    result = map (x: parseBind x args.${x}) binds;
  in lib.optionals (binds != [] && lib.any (x: args.${x} != {}) binds) result;

  parseEnv = obj:
    map (key: let
      value = if lib.isString obj.${key} then
        obj.${key}
      else builtins.toJSON obj.${key};
    in "env = ${key},${value}") (lib.attrNames obj);

  parseWindowRule = obj: let
    parseVal = key: o:
      lib.concatStringsSep "\n" (
        map (x: let
          value = toValue o.${x};
          name = "windowrule" + lib.optionalString (!isNull (lib.match ".*:.*" key)) "v2";
        in "${name} = ${lib.concatStringsSep " " ([ x ] ++ lib.optionals (!lib.isBool o.${x}) [ value ])}, ${key}")
        (lib.filter (x: ! lib.isBool o.${x} || o.${x}) (lib.attrNames o))
      );
    toValue = value:
      (if lib.isString value then
        [ value ]
      else if lib.isList value then
        lib.concatStringsSep " " (map (x: if lib.isString x then x else builtins.toJSON x) value)
      else builtins.toJSON value);
  in map (x: parseVal x obj.${x}) (lib.attrNames obj);

  parseSubMap = name: { cause, reset ? [], ... } @ args:
    [ "# ==> ${name}" ]
  ++parseBind "bind" (lib.listToAttrs (
      map (x: { name = x; value = "submap ${name}"; }) (lib.flatten [cause])
    ))
  ++["submap = ${name}"]
  ++parseBinds args
  ++[ "" ]
  ++parseBind "bind" (lib.listToAttrs (
      map (x: { name = x; value = "submap reset"; }) (lib.flatten [reset])
    ))
  ++[
      "submap = reset"
      "# <== ${name}"
    ]
  ;
in {
  enable = lib.mkDefault true;

  systemd.enableXdgAutostart = true;
  xwayland.enable = true;

  extraConfig = let
    parse = { env ? {}, submap ? {} , windowRule ? {}, ... } @ args: let
      binds = parseBinds args;
      r.envs = [ "# Environment" ] ++ parseEnv env ++ [""];
      r.binds = [ "" "# General Keybindings" ] ++ binds;
      r.submaps = map (x: parseSubMap x submap.${x} ++ [ "" ]) (lib.attrNames submap);
      r.windowrules = [ "# Window Rule" ] ++ parseWindowRule windowRule;
    in lib.concatStringsSep "\n" (lib.flatten (
        lib.optionals (env != {}) r.envs
      ++lib.optionals (binds != []) r.binds
      ++lib.optionals (submap != {}) r.submaps
      ++lib.optionals (windowRule != {}) r.windowrules
      ));
  in parse uncommon;
}
