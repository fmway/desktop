{ den, lib, ... }: let
  # inherit (den.lib) policy; inherit (policy) pipe;
  mkOverlay = jails: self: super: lib.sandbox.jail.parse super jails;
in {
  den.quirks.jail = {};

  den.aspects.jail.per-module = rec {
    nixos = { jail, ... }: { nixpkgs.overlays = [ (mkOverlay jail) ]; };
    darwin = nixos;
    homeManager = { osConfig, jail, ... }: {
      nixpkgs.overlays = lib.mkIf (!osConfig.home-manager.useGlobalPkgs or false) [
        (mkOverlay jail)
      ];
    };
  };

  # TODO: FIXME:
  # den.aspects.jail = {
  #   packages = { pkgs, jail, ... }: lib.sandbox.jail.parse pkgs jail;
  #   flake = { jail, ... }: {
  #     flake.overlays = lib.sandbox.jail.mkOverlays jail;
  #   };
  # };
  # den.policies.collect-jail = _: [
  #   (pipe.from "jail" [
  #     (pipe.broadcast (_: true))
  #     (pipe.to [ den.aspects.jail ])
  #   ])
  # ];
  # den.default.includes = [
  #   den.policies.collect-jail
  # ];

  den.schema = rec {
    # flake.includes = [ den.aspects.jail ];
    # flake-system = flake;
    host.includes = [ den.aspects.jail.per-module ];
    home = host;
  };
  flake-file/*.specialisation.dev*/.inputs = {
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    jail-nix.flake = false;
  };
}
