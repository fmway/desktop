{ lib, ... }: lib.fix (s: let
  inherit (lib.kdl) plain;
  fixKey = str: replaceOrRemove: # true = replace, false = remove
    builtins.concatStringsSep "+" (lib.unique (lib.flatten (lib.imap0 (i: x:
      if lib.toLower x == "mod" then
        if replaceOrRemove then "Mod4" else []
      else
        x
      ) (lib.splitString "+" str))));
  m = lib.listToAttrs (map (x: {
    name = "${x}ize";
    value = y: lib.listToAttrs (map (name: {
      inherit name;
      value = lib.kdl.${x} name;
    }) y);
  }) [ "leaf" "plain" "node" "flag" ]);
in
  m.leafize [ "spawn" "spawn-sh" "spawn-at-startup" "proportion" "match" "exclude" "include" ] //
  m.plainize [ "window-rule" "layer-rule" "environment" "binds" ] //
{
  sh = x: if lib.isDerivation x then "sh ${x}" else {
    cmd = [ x ];
    __toString = self: "sh -c '${lib.concatStringsSep " " (map (x: if x == "" then ''""'' else toString x) self.cmd)}'";
    __functor = self: arg: self // { cmd = self.cmd ++ lib.fmway.flat arg; };
  };

  mkSub = pkgs: {
    _sub = true;
    _children = [];
    __functor = self: args: let
      p = builtins.removeAttrs self [ "_subcommand" ];
    in
      if builtins.isString args then 
        if self._desc or "" != "" then let
          key = fixKey self._desc false;
        in plain self._desc (s.spawn "${lib.getExe pkgs.wlr-which-key}" "--initial-keys" key "niri") // { _key = key; _desc = args; } // removeAttrs p [ "_desc" ]
        else p // { _desc = args; }
      else p // {
        _children = self._children ++ lib.fmway.flat args;
      };
  };
  bind = key: desc: {
    inherit desc;
    key = fixKey key true;
    __functor = self: args: removeAttrs self [ "__functor" ] // (
      if builtins.isString args || (builtins.isAttrs args && args ? __toString) then {
        cmd = toString args;
      } else if builtins.isAttrs args && args._sub or false then {
        submenu = args;
      } else throw "(bind) unknown type ${builtins.typeOf args}");
  };

  normalizeSub = args: map ({ key, desc, ... } @ x:
  {
    inherit key desc;
  } // (if x.cmd or "" != "" then {
    cmd = x.cmd;
  } else {
    submenu = x.submenu._children;
  })) (lib.fmway.flat args);
})
