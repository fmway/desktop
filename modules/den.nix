{ inputs, den, lib, config, ... }: let
  inputs-param = ctx: builtins.mapAttrs (_: input: if input._type or "" == "flake" then config.perInput ctx.system input else input) inputs;
in {
  flake-file.inputs.den.url = "github:denful/den/main";

  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.policies.inputs-param-for-host = { host, ... }:
    (den.lib.policy.resolve { inputs' = inputs-param host; });
  den.policies.inputs-param-for-user = { host, user, ... }:
    (den.lib.policy.resolve { inputs' = inputs-param host; });
  den.policies.inputs-param-for-home = { home, ... }:
    (den.lib.policy.resolve { inputs' = inputs-param home; });

  den.default.includes = [
    den.policies.inputs-param-for-host
    den.policies.inputs-param-for-home
    den.policies.inputs-param-for-home
  ];
  den.schema = rec {
    user.classes = lib.mkDefault [ "homeManager" ];
    user.includes = [
      den._.primary-user
      den._.define-user
    ];
    home.includes = user.includes ++ [
      # Respect mutual-provider to-users
      (den.lib.policy.mkPolicy "to-users-to-standalone-hm"
        ({ home, ... }: den.lib.policy.include (home.host.aspect._.to-users or {})))
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
