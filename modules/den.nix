{ inputs, den, lib, ... }: let
  nurOverlay = lib.optionalAttrs (inputs ? nur) rec {
    nixos.nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
    homeManager = nixos;
  };
in {
  flake-file.inputs.den.url = "github:denful/den/main";

  imports = [
    inputs.den.flakeModule
    (lib.den.namespace "fmx" true)
  ];

  den.default.includes = [
    den._.inputs'
  ];
  den.schema = rec {
    user.classes = lib.mkDefault [ "homeManager" ];
    user.includes = [
      den._.primary-user
      den._.define-user
    ];
    home.includes = user.includes ++ [
      nurOverlay
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
      nurOverlay
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
