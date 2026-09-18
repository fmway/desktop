{ fmx, lib, ... }:
{
  fmx.nix.proxy = {
    includes = [
      ({ mode ? "selector4nix", ... }: {
        includes = [ fmx.nix.proxy.${mode} ];
      })
    ];

    selector4nix = {
      nixos = { extraCaches, inputs, ... }: let
        caches = builtins.zipAttrsWith (_: v: lib.unique (builtins.concatLists v)) (lib.select "**.**.{?substituters,?trusted-public-keys}" extraCaches);
      in {
        key = "fmx.nix.proxy@selector4nix";
        imports = [
          inputs.selector4nix.nixosModules.default
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
