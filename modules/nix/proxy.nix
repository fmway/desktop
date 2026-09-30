{ fmx, lib, inputs, ... }:
{
  fmx.nix.proxy = {
    includes = [
      ({ mode ? "selector4nix", ... }: {
        includes = [ fmx.nix.proxy.${mode} ];
      })
    ];

    selector4nix = {
      inputs = { inputs, ... }:
      {
        selector4nix = {
          enable = !inputs.fmway-inputs.enable or true;
          url = "github:StarryReverie/selector4nix";
          inputs = {
            nixpkgs.follows = "nixpkgs";
            flake-parts.follows = "flake-parts";
          };
        };
      };
      extraCaches.selector4nix = inputs.fmway-inputs.selector4nix.extraCaches or {}; 
      nixos = { extraCaches, ... }: let
        caches = builtins.zipAttrsWith (_: v: lib.unique (builtins.concatLists v)) (lib.select "**.**.{?substituters,?trusted-public-keys}" extraCaches);
      in {
        key = "fmx.nix.proxy@selector4nix";
        imports = [
          (inputs.fmway-inputs.selector4nix or inputs.selector4nix).nixosModules.default
        ];
        services.selector4nix = {
          enable = true;
          enablePersistentCaching = true;
          configureSubstituter = "overwrite";
          settings.substituters = [
            { url = "https://cache.nixos.org/"; }
          ] ++ map (url: { inherit url; }) caches.substituters;
        };

        nix.settings.trusted-public-keys = caches.trusted-public-keys;
      };
    };
  };
}
