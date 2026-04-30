inputs: let
  _lib = inputs.nixpkgs.lib;
  lib = _lib.fix (_lib.extends (_lib.composeManyExtensions overlayLibs) (_: _lib));
  overlayLibs = map (x: if builtins.isAttrs x then _: _: x else x) [
    # additional lib
    (self: _: {
      import-tree = ((import-tree.withLib lib).addAPI api).map builtins.toPath;
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

  import-tree = inputs.import-tree.addAPI api;

  selfLib = lib: ((((import-tree
    .map (p: {
      keys = let k = lib.init (lib.splitString "/" (lib.removePrefix "${scanDir}/" p)); in if builtins.length k > 1 then lib.tail k else k;
      value = lib.fmway.doImport p { inherit lib; };
    }))
    .pipeTo (builtins.foldl' (a: c: lib.recursiveUpdate a (lib.setAttrByPath c.keys c.value)) {}))
    .onSuffix "lib.nix")
    .withLib lib)
    scanDir;
  
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
  imports = [
    (import-tree.offSuffix "lib.nix" scanDir)
  ];

  flake.lib = selfLib lib;
}
