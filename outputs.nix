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
    onSuffix = self: suffix: self.filter (_lib.hasSuffix suffix);
    offSuffix = self: suffix: self.filterNot (_lib.hasSuffix suffix);
    toAttrs = self: fn: (self
      .map (path: rec {
         name = inputs.fmway-lib.fmway.basename path;
         value = (if builtins.isFunction fn || fn ? __functor then fn else _: fn) { inherit name path; };
      }))
      .pipeTo lib.listToAttrs;
  };

  specialArgs = {
    inherit lib;
  };
  
  scanDir = builtins.toPath ./modules;

  import-tree = ((inputs.import-tree.withLib _lib).addAPI api).map builtins.toPath;

  selfLib = lib: ((((import-tree
    .map (p: {
      keys = let k = lib.init (lib.splitString "/" (lib.removePrefix "${scanDir}/" p)); in if builtins.length k > 1 then lib.tail k else k;
      value = lib.fmway.doImport p { inherit lib inputs; };
    }))
    .pipeTo (builtins.foldl' (a: c: lib.recursiveUpdate a (lib.setAttrByPath c.keys c.value)) {}))
    .onSuffix "lib.nix")
    .withLib lib)
    scanDir;

  isAdditionalModuleExist = inputs ? module && builtins.pathExists inputs.module;

  m' = if lib.pathIsDirectory inputs.module then import-tree inputs.module else inputs.module;

  scanModules = ((import-tree
    .offSuffix "overlay.nix")
    .offSuffix "lib.nix")
    .map (p: let
      name = lib.fmway.basename p;
      toModules = name: { flake.flakeModules = { ${name} = p; default.imports = [ p ]; }; };
    in if lib.hasInfix "/classes/" p then {
      imports = [ p (toModules "class-${name}") ];
    } else if lib.hasInfix "/extras/" p then {
      imports  = [ p (toModules "extra-${name}") ];
    } else if lib.hasInfix "/flake/" p then {
      imports = [ p (toModules name) ];
    } else p)
    scanDir;
  
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
  imports = [
    scanModules
    ({ lib, config, ... }: {
      options.flake.flakeModules = lib.mkOption {
        type = lib.types.toml; # smart append for list value
      };
      config.flake.flakeModule.imports = builtins.attrValues config.flake.flakeModules;
    })
  ] ++ lib.optional isAdditionalModuleExist m';

  flake.lib = selfLib lib;

  flake.overlays = (((import-tree
    .onSuffix "overlay.nix")
    .map (p: {
      name = lib.last (lib.init (lib.splitString "/" p));
      value = import p;
    }))
    .pipeTo lib.listToAttrs)
    scanDir;
}
