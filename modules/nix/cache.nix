{ lib, ... }: let
  nix.settings.substituters = ["https://cache.nixos.org/"];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];

  autoImport = lib.import-tree ./_cache;
in {
  fmx.nix._.cache = {
    nixos.nix = nix;
    nixos.imports = [ autoImport ];
    homeManager.nix = nix;
    homeManager.imports = [ autoImport ];
  };

  # TODO: export to nixConfig
  # flake-file.nixConfig = ...;
}
