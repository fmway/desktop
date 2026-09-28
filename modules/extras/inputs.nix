{ den, lib, inputs, ... }: let

  collected-inputs = lib.unique (lib.select "**.inputs.**" den.lib.fleetResult.pipeContexts);
  overlays-inputs  = map
    (item:
      self: super:
        let r = (item.__fn or (_: item)) { inputs = self; };
      in if builtins.isList r then lib.fmway.deepMergeList r else r) collected-inputs;

  final-inputs = lib.fix (lib.extends (lib.composeManyExtensions overlays-inputs) (_: { }));
in {
  imports = [
    inputs.flake-file.flakeModules.default
  ];
  # inputs -> flake-file.inputs
  den.quirks.inputs = { };
  flake-file.inputs = builtins.mapAttrs (k: v: removeAttrs v [ "enable" ]) (lib.filterAttrs (_: v: v.enable or true) final-inputs);

  den.schema.flake.includes = [{
    inputs.flake-file.url = "github:denful/flake-file";
  }];
}
