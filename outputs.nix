inputs: let
  _lib = inputs.nixpkgs.lib;
  lib = _lib.fix (_lib.extends (_lib.composeManyExtensions overlayLibs) (_: _lib));
  overlayLibs = map (x: if builtins.isAttrs x then _: _: x else x) [
    # additional lib
    inputs.fmway-lib.overlays.default
    (self: _: {
      inherit import-tree;
      flake-parts = inputs.flake-parts.lib;
      den.namespace = inputs.den.namespace;
      nixvim = inputs.nxchad.lib.nixvim or {};
      disko = inputs.disko.lib;
      # den.lib.unused
      const' = self.flip self.const;
      unused = self.const';
    })
    (inputs.home-manager.lib or {})
    (inputs.fmway-modules.lib or {})
    (self: super: super.recursiveUpdate super (selfLib super))
  ];

  api = {
    addPaths = self: paths:
      builtins.foldl' (s: s.addPath) self (lib.flatten paths);
    onSuffix = self: suffix: self.filter (_lib.hasSuffix suffix);
    offSuffix = self: suffix: self.filterNot (_lib.hasSuffix suffix);
    toAttrs = self: fn: (self
      .map (path: rec {
         name = inputs.fmway-lib.fmway.basename path;
         value = (if builtins.isFunction fn || fn ? __functor then fn else _: fn) { inherit name path; };
      }))
      .pipeTo lib.listToAttrs;

    # auto export flakeModules.<x> if the module inside */flake/(classes|extras/)?
    # respect to import-tree.addScope except the flakeModules 
    collectModules = self:
      self.map (p: let
        name = lib.fmway.basename p;
        m = builtins.match ".*([/]flake[/]((classes|extras|quirks)[/])?).*" p;
        m'= builtins.elemAt m 0;
        fixModule =
          if self.__config.scoped == {  } then
            p
          else
            lib.modules.setDefaultModuleLocation p (scopedImport self.__config.scoped p);
        r = {
          "/flake/".imports = [ p (toModules name p) ];
          "/flake/extras/".imports = [ p (toModules "extra-${name}" p) ];
          "/flake/classes/".imports = [ p (toModules "class-${name}" p) ];
          "/flake/quirks/".imports = [ p (toModules "quirk-${name}" p) ];
        };
      in if isNull m then fixModule else r.${m'})
      (s: s.pipeTo (modules: { imports = modules; }));
  };

  toModules = name: p: { flake.flakeModules = { ${name} = p; default.imports = [ p ]; }; };

  specialArgs = {
    inherit lib;
  };
  
  scanDir = builtins.toPath ./modules;

  import-tree =
    (s: s.addAPI api)
    (s: s.map builtins.toPath)
    # for local flake
    (inputs._wrapImportTree or (s: s)); 

  selfLib = lib: import-tree
    (s: s.map (p: {
      keys = let k = lib.init (lib.splitString "/" (lib.removePrefix "${scanDir}/" p)); in if builtins.length k > 1 then lib.tail k else k;
      value = lib.fmway.doImport p { inherit lib inputs; };
    }))
    (s: s.pipeTo (builtins.foldl' (a: c: lib.recursiveUpdate a (lib.setAttrByPath c.keys c.value)) {}))
    (s: s.onSuffix "lib.nix")
    scanDir;

  isAdditionalModuleExist = let
    m = inputs.module or [];
  in m != [] && builtins.all (x: let r = builtins.pathExists x; in r) (lib.flatten m);

  scanModules = import-tree
    (s: s.offSuffix "overlay.nix")
    (s: s.offSuffix "lib.nix")
    (s: if isAdditionalModuleExist then s.addPaths inputs.module else s) # for local use
    ;

  # Priority
  # 1. args.source (<source/...>)
  # 3. builtin den.lib.__findFile
  scoped = { den, sources }:
  {
    __findFile = nixP: p: let
      pathLike = lib.hasInfix "/" p;
      paths = lib.splitString "/" p;
      h = builtins.head paths;
      t = builtins.tail paths;
      p'= builtins.concatStringsSep "/" t;
      r = sources.${p'} or (throw "<sources/${p'}> is missing");
    in if pathLike && h == "sources" && t != [] then
      r
    else den.lib.__findFile nixP p;
  };
  
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
  imports = [
    ({ den, sources ? {}, ... }: scanModules.addScoped (scoped { inherit den sources; }) (s: s.collectModules) scanDir)
    ({ lib, config, ... }: {
      options.flake.flakeModules = lib.mkOption {
        type = lib.types.toml; # smart append for list value
      };
      config.flake.flakeModule.imports = builtins.attrValues config.flake.flakeModules;
    })
  ];

  flake.lib = selfLib lib;

  flake.overlays = import-tree
    (s: s.onSuffix "overlay.nix")
    (s: s.map (p: {
      name = lib.last (lib.init (lib.splitString "/" p));
      value = import p;
    }))
    (s: s.pipeTo lib.listToAttrs)
    scanDir;

  flake = {
    _inputs = inputs;
  };
}
