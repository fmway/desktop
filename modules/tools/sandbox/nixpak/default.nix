{ den, lib, self, ... }: let
  inherit (den.lib) policy aspects;
  inherit (policy) pipe;

  toPackages = pkgs: nixpak:
    lib.mergeAttrsList (map (fn: fn pkgs) nixpak);
in {
  den.quirks.nixpak = { };
  den.default.includes = [
    den.policies.collect-nixpak
  ];
  den.policies.collect-nixpak = { user ? null, ... }: [
    (pipe.from "nixpak" [
      (pipe.for (list': let
        list = lib.unique list';
        list-packages = lib.unique (builtins.concatMap builtins.attrNames list);
        fake-aspect.includes = list;
      in map (p: pkgs: let
        evaled = lib.sandbox.nixpak pkgs {
          config.imports = [
            <sources/mnixry/nixpak/common>
            (aspects.resolve p fake-aspect)
          ];
          specialArgs = { inherit pkgs; system = pkgs.stdenv.hostPlatform.system; };
        };
        passthru = { wrapped = evaled.config.env; unwrapped = evaled.config.app.package; };
      in { ${p} = evaled.config.env // passthru // { passthru = evaled.config.env.passthru // passthru; }; }) list-packages))
      (pipe.to [ den.aspects.nixpak ])
    ])
  ] ++ lib.optionals (!isNull user) [
    (pipe.from "nixpak" [ pipe.expose ])
  ];
  den.aspects.nixpak = rec {
    packages = { pkgs, nixpak, ... }: toPackages pkgs nixpak;
    nixos = { nixpak, ... }:
    {
      nixpkgs.overlays = lib.optionals (nixpak != []) [
        (self: super: toPackages super nixpak)
      ];
    };
    darwin = nixos;
    homeManager = { osConfig, nixpak, ... }:
    {
      nixpkgs.overlays = lib.optionals (!(osConfig.home-manager.useGlobalPkgs or false) && nixpak != []) [
        (self: super: toPackages super nixpak)
      ];
    };
  };
  den.schema = rec {
    flake.includes = [ den.aspects.nixpak ];
    host = flake;
    home = flake;
  };
  flake-file/*.specialisation.dev*/.inputs = {
    nixpak.url = "github:nixpak/nixpak";
    nixpak.flake = false;
  };

  source-files."mnixry/nixpak/common" = "https://raw.githubusercontent.com/mnixry/nixos-config/refs/heads/main/pkgs/nixpaks/common.nix";
}
