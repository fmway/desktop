{ inputs, den, lib, fmx, __findFile, ... }:
{
  flake-file.inputs.den.url = "github:vic/den/v0.16.0";

  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.ctx = rec {
    user.includes = [
      <den/mutual-provider>
      <den/primary-user>
      <den/define-user>
    ];
    home.includes = user.includes;
    flake-packages.includes = [ (den.aspects.flake or {}) ];
  };

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
}
