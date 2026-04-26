inputs: let
  lib = inputs.nixpkgs.lib;
  overlayLibs = collectAllLib ++ map (fixOverlay []) [
    # additional lib
    (self: _: {
      import-tree = (inputs.import-tree.withLib lib).addAPI api;
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
  specialArgs = {
    # Unfortunately, we can't use _module.args to allow lib overlays inside modules
    lib = lib.fix (lib.extends (lib.composeManyExtensions overlayLibs) (_: lib));
    inherit inputs;
  };

  collectAllLib = autoImport.toOverlays.onSuffix "lib.nix" scanDir;
  
  scanDir = ./modules;
  scanDir'= builtins.toPath scanDir;

  api = {
    onSuffix = self: suffix: self.filter (lib.hasSuffix suffix);
    offSuffix = self: suffix: self.filterNot (lib.hasSuffix suffix);
    toOverlays = self: ((self
      .withLib lib)
      .map (p: pathToOverlay (builtins.toPath p)))
      .pipeTo lib.id;
    toAttrs = self: fn: (self
      .map (path: rec {
         name = inputs.fmway-lib.fmway.basename path;
         value = (if builtins.isFunction fn || fn ? __functor then fn else _: fn) { inherit name path; };
      }))
      .pipeTo lib.listToAttrs;
  };

  autoImport = inputs.import-tree.addAPI api;
  # FIXME: too much recursive imho
  fixOverlay = keys: imported: let
    f = lib.setAttrByPath keys;
    t = builtins.typeOf imported;
    update = lib.flip lib.recursiveUpdate;
  in if t == "lambda" && builtins.functionArgs imported == { } then
    self: super: update (f (imported self super)) super
  else if t == "lambda" then
    self: super: update (
      f (
        imported (specialArgs // {
          lib = specialArgs.lib // { inherit super; };
          extend = x: let
            k = if t == "string" then lib.splitString "." x else x;
            t = builtins.typeOf x;
          in if builtins.elem t ["string" "list"] then
            mkExtend super (keys ++ k)
          else mkExtend super keys x;
        })
      )
    ) super
  else _: update (f imported);

  # FIXME: nested extend
  mkExtend = superLib: pathToExtend: newLib: let
    origLib = lib.attrByPath pathToExtend {} superLib;
  in
    if builtins.isAttrs newLib then ({
      _super = origLib;
      _new = newLib;
    } // lib.recursiveUpdate origLib newLib)
    else newLib;

  toKeys = p: lib.init (
    lib.splitString "/" (
      lib.removePrefix "${scanDir'}/" (toString p)));
  pathToOverlay = p: let
    keys = toKeys p;
  in fixOverlay keys (import p);

  fetchOnlyNew = o:
    if o ? _new then
      fetchOnlyNew o._new
    else if builtins.isAttrs o then
      builtins.mapAttrs (lib.const fetchOnlyNew) o
    # no way lib as list 🗿
    # else if builtins.isList o then
    #   map fetchOnlyNew o
    else o;

  fixLib = exts: let
    f = lib.fix exts;
  in fetchOnlyNew f;
in inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } {
  imports = [
    (autoImport.offSuffix "lib.nix" scanDir)
  ];
  flake.lib = fixLib (lib.extends (lib.composeManyExtensions collectAllLib) (_: {}));
}
