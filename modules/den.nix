{ inputs, den, lib, fmx, __findFile, ... }:
{
  flake-file.inputs.den.url = "github:vic/den/v0.16.0";

  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.default.includes = [
    <fmx/utils>
    <fmx/version>
  ];

  fmx.utils.includes = builtins.attrValues (fmx.utils.provides or {});

  den.ctx = rec {
    user.includes = [
      <den/mutual-provider>
      <den/primary-user>
    ];
    home.includes = user.includes;
  };
}
