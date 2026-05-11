{ inputs, sources ? {}, den, lib, ... }:
{
  flake-file.inputs.den.url = "github:denful/den/main";

  # Priority
  # 1. args.source (<source/...>)
  # 2. args.den.ful.<namespace/...> (<namespace/...>)
  # 3. builtin den.lib.__findFile
  _module.args.__findFile = nixP: p: let
    pathLike = lib.hasInfix "/" p;
    paths = lib.splitString "/" p;
    h = builtins.head paths;
    t = builtins.tail paths;
    p'= builtins.concatStringsSep "/" t;
    r = sources.${p'} or (throw "<sources/${p'}> is missing");
    # override, disable warn from den.lib.__findFile
    r'= builtins.tryEval (let
      h' = builtins.head t; t' = builtins.tail t; v = den.ful.${h}.${h'};
    in if t' == [ h' ] then v else lib.getAttrFromPath (builtins.concatMap (x: [ "_" x ]) t') v);
  in if pathLike && h == "sources" && t != [] then
    r
  else if pathLike && den ? ful.${h} && r'.success then
    r'.value
  else den.lib.__findFile nixP p;

  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.schema = rec {
    user.classes = lib.mkDefault [ "homeManager" ];
    user.includes = [
      den._.primary-user
      den._.define-user
    ];
    home.includes = user.includes;
    flake-packages.includes = [ (den.aspects.flake or {}) ];

    host.includes = [
      ({ user, ... }: if builtins.elem "homeManager" user.classes then {
        nixos.home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
        };
      } else {})
      {
        # Force hostName
        nixos = { host, ... }:
        {
          networking.hostName = lib.mkForce host.name;
        };
      }
    ];
  };
}
