{ inputs, den, lib, config, ... }: let
  inherit (den.lib) policy;
  toPackages = x: keys: pkgs:
    assert builtins.all builtins.isString x || builtins.isFunction x;
    let
      value = if builtins.isFunction x then x pkgs else map (lib.flip builtins.getAttr pkgs) x;
    in lib.setAttrByPath keys value;
in {
  flake-file.inputs.den.url = "github:denful/den/main";
  flake-file.inputs.fmway-garden = {
    url = "github:fmway/garden";
    inputs.import-tree.follows = "import-tree";
  };

  imports = [
    inputs.den.flakeModule
    (inputs.fmway-garden.flakeModule.full.without [ "clan" ])
    (lib.den.namespace "fmx" true)
  ];

  den._.user-packages = x: {
    homeManager = { pkgs, ... }: toPackages x [ "home" "packages" ] pkgs;
  };

  den._.system-packages = x: rec {
    darwin = { pkgs, ... }: toPackages x [ "environment" "systemPackages" ] pkgs;
    nixos = darwin;
  };

  den._.packages = x:
    lib.mkCross ({ class, pkgs, ... }: let
      key = if class == "homeManager" then [ "home" "packages" ] else [ "environment" "systemPackages" ];
    in toPackages x key pkgs);

  den.policies.inputs-parametric = { host ? null, home ? null, ... } @ c:
    lib.optional (c ? host || c ? home)
    (policy.resolve.shared rec {
      system = host.system or home.system;
      inputs' = builtins.mapAttrs (name: input:
        if name == "self" || input._type or "" == "flake" then
          config.perInput system input
        else input) inputs // builtins.mapAttrs (_: config.perInput system) (inputs.fmway-inputs or {});
      self' = inputs'.self;
    }) ++ [
      (policy.resolve { inherit inputs; })
    ];

  den.default.includes = [
    den.policies.inputs-parametric
  ];
  den.schema = rec {
    user.classes = lib.mkDefault [ "homeManager" ];
    user.includes = [
      den._.primary-user
      den._.define-user
    ];
    home.includes = user.includes ++ [
      # Respect mutual-provider to-users
      (policy.mkPolicy "mutual-hm"
        ({ home, ... }: [
          (policy.include (home.host.aspect._.${home.name} or home.host.aspect.${home.name} or {}))
          (policy.include (home.host.aspect._.to-users or home.host.aspect.to-users or {}))
        ])
      )
    ];

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
