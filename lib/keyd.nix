{ lib, ... }: let
  #======================== KEYWORDS ============================
  characters = "1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./"; # without shift include
  controls = [ "alt" "meta" "shift" "control" ];
  others = [
    "home" "end" "pageup" "pagedown"
    "up" "down" "left" "right"
    "capslock" "tab" "esc"
    "insert" "delete" "backspace"
    "wakeup" # fn button
    "mute" "volumedown" "volumeup" "micmute" "brightnessdown" "brightnessup" "switchvideomode" "wlan" "config" "bluetooth" "favorites"
  ] ++ lib.kdl.seq 1 15 (x: "f${toString x}"); # FIXME add others

  _actions = [
    { __nullish = [ "repeat" ]; __macroer = [ "clear" ]; }
    { __nullish = [
      { name = "setlayout";
        check = arg: let x = builtins.elemAt arg 0; in {
          assertion = x._type or "" == "layout";
          message = "first param \"${toString x}\" doesn't seem to be layout";
        };
      }
    ]; __macroer = map (name: { inherit name; check = checkfirstislayer; }) [ "layer" "oneshot" "swap" "toggle" ]; }
    (map (name: { inherit name; check = checkfirstislayer; }) ["oneshotk" "overload"])
    (map (name: { inherit name; check = checkfirstislayer; }) ["overloadt" "overloadt2"] ++ ["overloadi" "timeout" "macro2"])
    [{ name = "lettermod"; check = checkfirstislayer; }]
  ];

  #================ END KEYWORDS ===================

  checkfirstislayer = arg: let x = builtins.elemAt arg 0; in {
    assertion = x._type or "" == "layer";
    message = "first param \"${toString x}\" doesn't seem to be layer";
  };
  mkAction = check: nparams: name: params:
    (if nparams == 0 then let ass = check params; msg = "(${name}): ${ass.message}"; in
      lib.throwIfNot ass.assertion msg "${name}(${lib.concatMapStringsSep ", " toString params})"
    else arg: mkAction check (nparams - 1) name (params ++ [arg]))
  ;
  mkAction' = name: arg: {
    params = [arg];
    __functor = self: arg: self // { params = self.params ++ [arg]; };
    __toString = self: "${name}(${lib.concatMapStringsSep " " toString self.params})";
  };
  defaultCheck = _: { assertion = true; message = ""; };
  listToObj = lib.foldl' (a: c: a // { ${c} = c; }) {};
  defaultLayers = listToObj (lib.foldl' (acc: c: acc ++ [ c "left${c}" "right${c}" ]) [ "altgr" ] controls);

  keys =
    listToObj (lib.splitString "" characters)
    //
    defaultLayers
    //
    listToObj others
    ;
  functions = lib.listToAttrs (map (x: let
    name = lib.toUpper (lib.fmway.firstChar x);
  in {
    inherit name;
    value = {
      __name = name;
      chains = [];
      __functor = self: args: self // {
        chains = self.chains ++ [args];
      };
      __toString = self: lib.concatStringsSep "-" ([self.__name] ++ self.chains);
    };
  }) (controls ++ [ "G" /* for AltGr */ ]));
  actions = lib.flip lib.removeAttrs [ "__idx" ] (lib.foldl' (acc: curr: acc // (
    if builtins.isString curr then {
      ${curr} = mkAction defaultCheck acc.__idx curr [];
    }
    else if builtins.isList curr then
      builtins.foldl' (a: c: let name = c.name or c; in a // { "${name}" = mkAction (c.check or defaultCheck) acc.__idx name []; }) {} curr
    else
      builtins.foldl' (a: c: let name = c.name or c; in a // { "${name}" = mkAction (c.check or defaultCheck) acc.__idx name []; }) {} (curr.__nullish or [] ++ curr.__macroer or [])
      //
      lib.optionalAttrs (curr ? __macroer) (builtins.foldl' (a: c: let name = c.name or c; in a // { "${name}m" = mkAction (c.check or defaultCheck) (acc.__idx + 1) "${name}m" []; }) {} curr.__macroer)
  ) // { __idx = acc.__idx + 1; }) { __idx = 0; } _actions) // {
    macro = mkAction' "macro";
    command = mkAction' "command";
  };

  fix' = x: lib.mapAttrs (k: v:
    if k == "layout" then
      lib.mapAttrs (k': v': v' // { _type = "layout"; __toString = self: k'; }) v
    else lib.optionalAttrs (lib.isAttrs v) v // { _type = "layer"; __toString = self: k; } # assume either layout are layer
  ) (defaultLayers // x);

  fix = x: let
    fixLayout = lib.fmway.foldAttrs' (acc: k: v: acc // {
      "${k}:layout" = lib.mapAttrs (_: toString) (removeAttrs v [ "__toString" "_type" ]);
    }) {} x.layout;
    init = lib.optionalAttrs (x ? layout) fixLayout;
  in lib.fmway.foldAttrs' (fixLayer []) init (removeAttrs x ["layout"]);

  fixLayer = names: acc: k: v:
    if builtins.isAttrs v && ! v ? __toString then
      lib.fmway.foldAttrs' (fixLayer (names ++ [k])) acc v
    else let key = lib.concatStringsSep "+" names; in acc // {
      ${key} = acc.${key} or {} // {
        ${k} = toString v;
      };
    }
  ;
in {
  inherit actions keys functions;
  parse = fn: let
    res = fn (actions // keys // functions // fix' res);
  in fix res;
}

