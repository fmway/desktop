inputs: let
  lib = inputs.nixpkgs.lib;
  overlayLibs = map (x: if builtins.isAttrs x then _: _: x else x) [
    # additional lib
    (self: _: {
      import-tree = (import-tree.withLib lib).addAPI api;
      fmway = inputs.fmway-lib.fmway;
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
  ];
  
  api = {
    onSuffix = self: suffix: self.filter (lib.hasSuffix suffix);
    offSuffix = self: suffix: self.filterNot (lib.hasSuffix suffix);
    toAttrs = self: fn: (self
      .map (path: rec {
         name = inputs.fmway-lib.fmway.basename path;
         value = (if builtins.isFunction fn || fn ? __functor then fn else _: fn) { inherit name path; };
      }))
      .pipeTo lib.listToAttrs;
  };

  specialArgs = {
    lib = lib.fix (lib.extends (lib.composeManyExtensions overlayLibs) (_: lib));
  };
  
  scanDir = ./modules;

  import-tree = inputs.import-tree.addAPI api;
  
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } (import-tree scanDir)
