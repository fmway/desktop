inputs: let
  lib = inputs.nixpkgs.lib;
  overlayLibs = collectAllLib ++ map (fixOverlay (x: x)) [
    # additional lib
    (_: _: {
      import-tree = inputs.import-tree;
      fmway = inputs.fmway-lib.fmway;
      flake-parts = inputs.flake-parts.lib;
      den.namespace = inputs.den.namespace;
      nixvim = inputs.nxchad.lib.nixvim or {};
    })
    (inputs.home-manager.lib or {})
    (inputs.fmway-modules.lib or {})
  ];
  specialArgs = {
    # Unfortunately, we can't use _module.args to allow lib overlays inside modules
    lib = lib.fix (lib.extends (lib.composeManyExtensions overlayLibs) (_: lib));
    inherit inputs;
  };
  
  scanDir = ./modules;
  scanDir'= builtins.toPath scanDir;
  api = {
    onSuffix = self: suffix: self.filter (lib.hasSuffix suffix);
    offSuffix = self: suffix: self.filterNot (lib.hasSuffix suffix);
  };
  # FIX: too much recursive imho
  fixOverlay = f: imported: let
    t = builtins.typeOf imported;
    update = lib.flip lib.recursiveUpdate;
  in if t == "lambda" && builtins.functionArgs imported == { } then
    self: super: update (f (imported self super)) super
  else if t == "lambda" then
    self: super: update (
      f (
        imported (specialArgs // {
          lib = specialArgs.lib // { inherit super; };
        })
      )
    ) super
  else _: update (f imported);

  toKeys = p: lib.init (
    lib.splitString "/" (
      lib.removePrefix "${scanDir'}/" (toString p)));
  pathToOverlay = p: let
    keys = toKeys p;
    f = lib.setAttrByPath keys;
    imported = import p;
  in fixOverlay f imported;
  autoImport = inputs.import-tree.addAPI api;
  collectAllLib = ((((autoImport
    .map pathToOverlay)
    .pipeTo (x: x))
    .onSuffix "lib.nix")
    .withLib lib)
    scanDir
  ;
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
  imports = [
    (autoImport.offSuffix "lib.nix" scanDir)
  ];
  flake.lib = lib.fix (lib.extends (lib.composeManyExtensions collectAllLib) (_: {}));
}
