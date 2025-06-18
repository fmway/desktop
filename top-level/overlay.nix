{ lib, config, inputs, self, ... } @ v:
{
  flake.overlays.default = self: super: let
    dir = ../pkgs;
    packages = lib.pipe dir [
      (builtins.readDir)
      (lib.filterAttrs (k: v:
        (v == "directory" && lib.pathIsRegularFile "${dir}/${k}/default.nix") ||
        (v == "regular" && lib.hasSuffix ".nix" k)
      ))
      (lib.attrNames)
      (map (path: {
        name = lib.removeSuffix ".nix" path;
        value = lib.fmway.withImport "${dir}/${path}" (v // {
          inherit self super;
          inherit (config.flake) lib;
        });
      }))
      (lib.listToAttrs)
    ];
  in lib.infuse super packages;

  flake.overlays.externalPackages = self: super:
    lib.foldl' (acc: curr: acc // curr self acc) super [
      inputs.h-m-m.overlays.default
      inputs.nur.overlays.default
    ];

  perSystem = { pkgs, config, system, ... }: {
    nixpkgs.overlays = with inputs; [
      lix-module.overlays.default
      self.overlays.default
      agenix.overlays.default
      self.overlays.externalPackages
      (self: super: let
        overlayNixpkgs = arr: obj: lib.foldl' (acc: curr: let
          name = "_${curr}";
          importName =
            inputs.${curr} or
            inputs."$nixpkgs-${curr}";
        in {
          "${name}" = import importName {
            inherit system;
            inherit (config.nixpkgs) config;
          };
        } // acc) obj arr;
      in overlayNixpkgs [ "master" "24_11" "25_05" ] {})
    ];

    legacyPackages = pkgs;
  };
}
