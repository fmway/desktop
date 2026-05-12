{ inputs, sources ? {}, __findFile, den, lib, ... }:
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
  in if pathLike && h == "sources" && t != [] then
    r
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
    home.includes = user.includes ++ [
      # Respect mutual-provider to-users
      ({ home, ... }: den.lib.policy.include (home.host.aspect._.to-users or {}))
    ];
    flake-packages.includes = [ (den.aspects.flake or {}) ];

    host.includes = [
      ({ user, ... }: lib.optionalAttrs (builtins.elem "homeManager" user.classes) {
        nixos.home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          verbose = true;
        };
      })
      {
        # Force hostName, useful when integrated with clan.nix with different hostName machine
        nixos = { host, ... }:
        {
          networking.hostName = lib.mkForce host.name;
        };
      }
    ];
  };
}
