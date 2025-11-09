{ lib, sources, config, inputs, self, ... } @ v: let
  dir = builtins.toPath ../pkgs;
  listDir = lib.attrNames (
    lib.filterAttrs (k: v:
      (v == "directory" && lib.pathIsRegularFile "${dir}/${k}/default.nix") ||
      (v == "regular" && lib.hasSuffix ".nix" k)
    ) (builtins.readDir dir)
  );
  fetcheds = let
    res = lib.listToAttrs (map (x: let
      path = "${dir}/${x}";
    in rec {
      name = lib.removeSuffix ".nix" x;
      value = self: super: {
        "${name}" = lib.fmway.withImport path (v // {
          inherit self super;
          inherit (config.flake) lib;
        });
      };
    }) listDir);
  in res // {
    default = self: super: lib.foldl' (acc: curr: acc // res.${curr} self super) {} (builtins.attrNames res);
  };
in {
flake.sources = sources;
flake.overlays = lib.mapAttrs (_: fn: self: super: lib.infuse.sugarify {
    __add = path: infusion: target: super.yaziPlugins.mkYaziPlugin infusion;
  } super (fn self super)) fetcheds // {
    externalPackages = self: super:
      lib.foldl' (acc: curr: acc // curr self acc) super [
        inputs.nur.overlays.default
        (self: super: {
          noctalia-shell = inputs.noctalia.packages.${self.stdenv.hostPlatform.system}.default;
          h-m-m = import sources.h-m-m { pkgs = self; version = "0.0.1-dev"; };
        })
      ];
  };

  perSystem = { pkgs, config, system, ... }: {
    nixpkgs.overlays = with inputs; [
      # sources.lix-module.overlays.default
      self.overlays.default
      agenix.overlays.default
      self.overlays.externalPackages
    ];

    packages = lib.listToAttrs (map (x: let
      name = lib.removeSuffix ".nix" x;
    in {
      inherit name;
      value = pkgs.${name};
    }) listDir);

    legacyPackages = pkgs;
  };
}
