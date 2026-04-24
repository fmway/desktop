{ inputs, den, lib, ... }:
{
  flake-file.inputs.den.url = "github:vic/den/v0.16.0";

  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.ctx.user.includes = [ den._.mutual-provider ];
  den.ctx.home.includes = [ den._.mutual-provider ];
}
