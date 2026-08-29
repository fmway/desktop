{ den, lib, ... }: let
  jailTo = class: keys:
    { pkgs, jail, ... }:
      lib.setAttrByPath keys (builtins.attrValues (lib.sandbox.jail.parse pkgs jail)) // {
        key = "den.aspects.jail@${class}";
      };
in {
  den.quirks.jail = {};

  den.aspects.jail.includes = [
    ({ user ? null, ... }:
    if isNull user then {
      nixos = jailTo "nixos" [ "environment" "systemPackages" ];
      darwin = jailTo "darwin" [ "environment" "systemPackages" ];

      # packages = { pkgs, jail, ... }:
      #   lib.sandbox.jail.parse pkgs jail // {
      #     key = "den.aspects.jail@flake-system";
      #   };
    } else {
      homeManager = jailTo "homeManager" [ "home" "packages" ];
    })
  ];
  den.schema = rec {
    host.includes = [ den.aspects.jail ];
    user = host;
    home = host;
  };
  flake-file/*.specialisation.dev*/.inputs = {
    jail-nix.url = "sourcehut:~alexdavid/jail.nix";
    jail-nix.flake = false;
  };
}
