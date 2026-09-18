{ lib, den, inputs, ... }:
{
  den.quirks.extraCaches = { };
  fmx.nix.includes = [ <fmx/nix/collect-cache> ];
  fmx.nix.collect-cache = lib.genAttrs [ "nixos" "homeManager" "darwin" ] (_: { host ? null, user ? null, extraCaches, ... }:
  lib.optionalAttrs (!(host.hasAspect or user.hasAspect or (_: false)) <fmx/nix/proxy>)
  {
    nix.settings =
      builtins.zipAttrsWith (_: v: lib.unique (builtins.concatLists v)) (
        lib.select "**.**.{?substituters,?trusted-public-keys}" extraCaches);
  });
  fmx.nix.extraCaches =
    lib.select
      "*.??extraCaches.{?substituters,?trusted-public-keys}" inputs.fmway-inputs.collections // {
    clan = {
      substituters = [ "https://cache.clan.lol" ];
      trusted-public-keys = [ "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28=" ];
    };

    devenv = {
      substituters = [ "https://devenv.cachix.org" ];
      trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
    };

    fmcachix = {
      substituters = [ "https://fmcachix.cachix.org" ];
      trusted-public-keys = [ "fmcachix.cachix.org-1:Z5j9jk83ctoCK22EWrbQL6AAP3CTYnZ/PHljlYSakrw=" ];
    };

    nix-community = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };
}
