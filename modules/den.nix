{ inputs, den, lib, fmx, __findFile, ... }: let
  sources = builtins.mapAttrs (k: v: let
    type = v.type or "tarball";
    fn = if type == "file" then
      builtins.fetchurl
    else if type == "tarball" then
      fetchTarball
    else throw "undefined";
    source = fn {
      name = v.name or "source";
      inherit (v) url;
      sha256 = v.sha256 or v.hash;
    };
  in source) (builtins.fromJSON (builtins.readFile ../sources.json));
in {
  flake-file.inputs.den.url = "github:vic/den/v0.16.0";

  _module.args.sources = sources;
  _module.args.__findFile = nixP: p: let
    paths = lib.splitString "/" p;
    h = builtins.head paths;
    t = builtins.tail paths;
    p'= builtins.concatStringsSep "/" t;
    r = sources.${p'} or (throw "<sources/${p'}> is missing");
  in if h == "sources" && t != [] then r else den.lib.__findFile nixP p;
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
