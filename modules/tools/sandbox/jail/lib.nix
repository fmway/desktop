{ inputs, require, lib, ... }: let

  combinators = c: let
    normalizePath = p: if !p?_noescape && isStartWithTilde p then c.noescape p else p;
  in {
    rw'= p: c.try-readwrite (normalizePath p);
    ro = p: c.try-readonly (normalizePath p);
    rw = p: let p' = normalizePath p; p_ = p'._noescape or "\"${p'}\""; in c.compose [
      (c.add-runtime /* sh */ "[ -d ${p_} ] || mkdir ${p_}")
      (c.readwrite p')
    ];
    regex = _regex: { inherit _regex; };

    # (env (regex "A_REGEX")) -> import all env that the name contains A_REGEX
    # (env "A_VAR" "a_value") -> set A_VAR to a_value
    # (env "A_VAR") -> import A_VAR
    env = name:
      if name ? _regex && builtins.isString name._regex then
        c.compose [
          (state: state // {
            envs = state.envs or [] ++ [ name._regex ];
          })
          (c.include-once "collect-envs" (c.defer collect-envs))
        ]
      else x: (if builtins.isString x then c.set-env else c.try-fwd-env) name x;

    # importing PATH, useful if combine with dev environment
    loose = c.compose [
      (c.rw "/nix/store")
      (c.ro "/etc/nix")
      (c.ro "/run/current-system")
      (c.ro (c.noescape "\"/etc/profiles/per-user/$USER\""))
      (c.add-path "\"$PATH\"")
    ];
  };

  parseRegex = str: let
    len = builtins.stringLength str;
    hasPrefix = builtins.substring 0 1 str == "^";
    hasSuffix =
      builtins.substring (len - 1) 1 str == "$" &&
      builtins.substring (len - 2) 1 str != "\\";
    h = if hasPrefix then 1 else 0;
    t = len - (if hasSuffix then 1 else 0) - h;
    start = if hasSuffix || !hasPrefix then "[^= ]*" else "";
    end   = if hasPrefix || !hasSuffix then "[^= ]*" else "";
    final = builtins.substring h t str;
  in if hasPrefix && hasSuffix then final else "${start}${final}${end}";

  collect-envs = state: let
    regex = "^(${lib.concatMapStringsSep "|" parseRegex (state.envs or [])})=.*$";
  in state // {
    runtime = state.runtime + "\n" + /* sh */ ''
      mapfile -t -d "" -O "''${#RUNTIME_ARGS[@]}" RUNTIME_ARGS < <(printenv --null | grep --null-data -E "${regex}" | while IFS= read -r -d "" e; do
        printf -- '--setenv\0%s\0%s\0' "''${e%%=*}" "''${e#*=}"
      done)
    '';
  };

  isStartWithTilde = s: builtins.substring 0 1 s == "~";

  patchJail = builtins.toFile "jail.nix" (builtins.replaceStrings [
    "./"
    "additionalCombinators ? _: { }"
    "allCombinators = builtinCombinators // additionalCombinators builtinCombinators"
  ] [
    "${inputs.jail-nix}/lib/"
    "overlays ? []"
    "allCombinators = lib.fix (lib.extends (lib.composeManyExtensions overlays) (_: builtinCombinators))"
  ] (builtins.readFile "${inputs.jail-nix}/lib/jail.nix"));
  jailNix = import patchJail;
  mkJail = { overlays ? [], }: let
    self = {
      init = pkgs: jailNix {
        inherit pkgs overlays;
        suppressExperimentalWarnings = true;
      };
      parse = pkgs: jails: let
        jail = self.init pkgs;
        inherit (jail) combinators;
      in builtins.zipAttrsWith (appName: vs: let
        r = builtins.zipAttrsWith (k: v:
          if k == "permissions" then
            builtins.concatMap (x: {
              lambda = x combinators;
              list = x;
              null = [];
            }.${builtins.typeOf x} or (throw "unknown type of permissions, allowed: null, function, list")) v
          else lib.fmway.resolvePriority v) vs;
        pkg = jail appName r.package r.permissions // { wrapped = pkg; unwrapped = r.package; };
      in pkg) jails;
      # mkOverlays = builtins.zipAttrsWith (appName: vs: _: pkgs: let
      #   jail = self.init pkgs; inherit (jail) combinators;
      #   r = builtins.zipAttrsWith (k: v: if k == "permissions" then builtins.concatMap (fn: fn combinators) v else lib.fmway.resolvePriority v) vs;
      #   pkg = jail appName r.package r.permissions // { wrapped = pkg; unwrapped = r.package; };
      # in pkg);
      addCombinators = fn: mkJail {
        overlays = overlays ++ [
          (self: let r = fn self; in if builtins.isFunction r then r else _: r)
        ];
      };
    };
  in self;
  finalJail = (mkJail { }).addCombinators combinators;
in require (inputs ? jail-nix) finalJail
