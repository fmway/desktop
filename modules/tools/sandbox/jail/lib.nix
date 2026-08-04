{ inputs, require, lib, ... }: let

  combinators = c: let
    normalizePath = p: if isStartWithTilde p then c.noescape p else p;
  in {
    rw'= p: c.try-readwrite (normalizePath p);
    ro = p: c.try-readonly (normalizePath p);
    rw = p: let p' = normalizePath p; p_ = p'._noescape or "\"${p'}\""; in c.compose [
      (c.add-runtime /* sh */ "[ -d ${p_} ] || mkdir ${p_}")
      (c.readwrite p')
    ];
    env = c.set-env;
  };

  isStartWithTilde = s: builtins.substring 0 1 s == "~";

  jailNix = import "${inputs.jail-nix}/lib/jail.nix";
  mkJail = { combinators ? _: {}, }: let
    self = {
      init = pkgs: let s = jailNix { inherit pkgs; suppressExperimentalWarnings = true; additionalCombinators = _: combinators s; }; in s;
      parse = pkgs: jails: let
        jail = self.init pkgs;
        inherit (jail) combinators;
      in builtins.zipAttrsWith (appName: vs: let
        r = builtins.zipAttrsWith (k: v: if k == "permissions" then builtins.concatMap (fn: fn combinators) v else lib.fmway.resolvePriority v) vs;
        pkg = jail appName r.package r.permissions // { wrapped = pkg; unwrapped = r.package; };
      in pkg) jails;
      # mkOverlays = builtins.zipAttrsWith (appName: vs: _: pkgs: let
      #   jail = self.init pkgs; inherit (jail) combinators;
      #   r = builtins.zipAttrsWith (k: v: if k == "permissions" then builtins.concatMap (fn: fn combinators) v else lib.fmway.resolvePriority v) vs;
      #   pkg = jail appName r.package r.permissions // { wrapped = pkg; unwrapped = r.package; };
      # in pkg);
      addCombinators = fn: mkJail {
        combinators = jail: let
          r = combinators jail // fn c;
          c = jail.combinators // r;
        in r;
      };
    };
  in self;
  finalJail = (mkJail { }).addCombinators combinators;
in require (inputs ? jail-nix) finalJail
