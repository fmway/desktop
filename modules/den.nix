{ inputs, den, lib, config, ... }: let
  inherit (den.lib) policy;
  toPackages = x: keys: pkgs:
    assert builtins.all builtins.isString x || builtins.isFunction x;
    let
      value = if builtins.isFunction x then x pkgs else map (lib.flip builtins.getAttr pkgs) x;
    in lib.setAttrByPath keys value;
in {
  imports = [
    inputs.den.flakeModule
    (inputs.fmway-garden.flakeModule.without [ "clan" ])
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
        else input) inputs // builtins.mapAttrs (_: config.perInput system) (inputs.fmway-inputs.outputs.inputs or {});
      self' = inputs'.self;
    });

  den.default.includes = [
    den.policies.inputs-parametric
  ];
  den.schema = rec {
    flake.includes = [{
      inputs = {
        # core flake
        systems.url = "github:nix-systems/triplet";
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
        home-manager = {
          url = "github:nix-community/home-manager/master";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };
        fmway-inputs.url = "github:fmway/inputs";
        fmway-lib = {
          url = "github:fmway/lib";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        fmway-modules.url = "github:fmway/modules";
        fmway-modules.inputs = {
          fmway-lib.follows = "fmway-lib";
          nixpkgs.follows = "nixpkgs";
        };
        import-tree.url = "github:denful/import-tree/4ebb10ae17d5f1ad366e7aef5b92cb8eecf24f69";
        nur.url = "github:nix-community/nur";
        nur.inputs.flake-parts.follows = "flake-parts";
        nur.inputs.nixpkgs.follows = "nixpkgs";

        den.url = "github:fmway/den/feat/den.lib.pipes";
        fmway-garden = {
          url = "github:fmway/garden";
          inputs.import-tree.follows = "import-tree";
        };
      };
    }];
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

  # collect all extraCaches quirk
  flake-file.nixConfig = let
    extraCaches = lib.select
      "**.extraCaches.**.**.{?substituters:extra-substituters,?trusted-public-keys:extra-trusted-public-keys}"
      den.lib.fleetResult.pipeContexts;
  in builtins.zipAttrsWith (_: v: lib.unique (builtins.concatLists v)) extraCaches;
}
