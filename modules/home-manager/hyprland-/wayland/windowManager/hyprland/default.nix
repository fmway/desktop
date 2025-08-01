{ pkgs, uncommon, lib, config, ... }: let
  parseBind = prefix: obj:
    lib.pipe obj [
      (lib.attrNames)
      (map (x: let
        key = lib.pipe x [
          (lib.splitString "+")
          (map (x: if x == "" then "+" else x))
          (y: let
            length = lib.length y;
            h = lib.concatStringsSep " " (if length == 1 then [""] else lib.take (length - 1) y);
            t = lib.last y;
          in [ h t ])
        ];
        toValue = v:
          lib.pipe obj.${x} [
            (lib.splitString " ")
            (y: let
              h = lib.head y;
              t = lib.pipe y [ lib.tail (lib.concatStringsSep " ") ];
            in [ h ] ++ lib.optionals (lib.length y != 1) [ t ])
          ];
        value = lib.pipe [ obj.${x} ] [
          (lib.flatten)
          (map toValue)
        ];
      in map (z: lib.pipe (key ++ z) [
          (lib.concatStringsSep ", ")
          (zz: "${prefix} = ${lib.trim zz}")
        ]) value
      ))
    ];

  parseBinds = { ... } @ args: let
    binds = lib.pipe args [
      (lib.attrNames)
      (lib.filter (lib.hasPrefix "bind"))
    ];
    result = map (x: parseBind x args.${x}) binds;
  in lib.optionals (binds != [] && lib.any (x: args.${x} != {}) binds) result;

  parseEnv = obj:
    lib.pipe obj [
      (lib.attrNames)
      (map (key: let
        value = if lib.isString obj.${key} then
          obj.${key}
        else builtins.toJSON obj.${key};
      in "env = ${key},${value}"))
    ];

  parseWindowRule = obj: let
    parseVal = key: o:
      lib.pipe o [
        (lib.attrNames)
        (lib.filter (x: ! lib.isBool o.${x} || o.${x}))
        (map (x: let
          value = toValue o.${x};
          name = "windowrule" + lib.optionalString (!isNull (lib.match ".*:.*" key)) "v2";
        in "${name} = ${lib.concatStringsSep " " ([ x ] ++ lib.optionals (!lib.isBool o.${x}) [ value ])}, ${key}"))
        (lib.concatStringsSep "\n")
      ];
    toValue = value:
      (if lib.isString value then
        [ value ]
      else if lib.isList value then
        lib.concatStringsSep " " (map (x: if lib.isString x then x else builtins.toJSON x) value)
      else builtins.toJSON value);
  in lib.pipe obj [
    (lib.attrNames)
    (map (x: parseVal x obj.${x}))
  ];

  parseSubMap = name: { cause, reset ? [], ... } @ args:
    [ "# ==> ${name}" ] ++ lib.pipe [cause] [
      (lib.flatten)
      (map (x: { name = x; value = "submap ${name}"; }))
      (lib.listToAttrs)
      (parseBind "bind")
    ] ++
    ["submap = ${name}"] ++
    (parseBinds args) ++ [ "" ] ++ lib.pipe [reset] [
      (lib.flatten)
      (map (x: { name = x; value = "submap reset"; }))
      (lib.listToAttrs)
      (parseBind "bind")
    ]++ [
      "submap = reset"
      "# <== ${name}"
    ]
  ;
in {
  enable = lib.mkDefault true;

  systemd.enableXdgAutostart = true;
  xwayland.enable = true;

  extraConfig = let
    parse = { env ? {}, submap ? {} , windowRule ? {}, ... } @ args:
      lib.pipe (
        lib.optionals (env != {}) ([ "# Environment" ] ++ parseEnv uncommon.env ++ [""]) ++
        (let binds = parseBinds args; in lib.optionals (binds != []) ([ "" "# General Keybindings" ] ++ binds)) ++
        lib.optionals (submap != {}) (lib.pipe submap [
          (lib.attrNames)
          (map (x: parseSubMap x submap.${x} ++ [ "" ]))
        ]) ++ lib.optionals (windowRule != {}) ([ "# Window Rule" ] ++ parseWindowRule windowRule)
      ) [ lib.flatten (lib.concatStringsSep "\n") ];
  in parse uncommon;
}
