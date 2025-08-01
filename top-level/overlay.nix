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
  flake.overlays = lib.mapAttrs (_: fn: self: super: lib.infuse super (fn self super)) fetcheds // {
    externalPackages = self: super:
      lib.foldl' (acc: curr: acc // curr self acc) super [
        inputs.h-m-m.overlays.default
        inputs.nur.overlays.default
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
