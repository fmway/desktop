{ internal, self, pkgs ? self, super, lib, inputs, ... }: let
  mkScrollPkg = fn: let
    unwrapped = super.sway-unwrapped.overrideAttrs (finalAttrs: prevAttrs: let
      args = if lib.isAttrs fn then fn else let x = fn prevAttrs; in if lib.isAttrs x then x else fn finalAttrs prevAttrs;
    in args // {
      pname = "scroll";
      patches = let
        replaces = {
          "fix-paths.patch" = replaceVars ./fix-paths.patch {
            inherit swaybg;
          };
          "load-configuration-from-etc.patch" = ./load-configuration-from-etc.patch;
          "sway-config-nixos-paths.patch" = ./sway-config-nixos-paths.patch;
          "sway-config-no-nix-store-references.patch" = ./sway-config-no-nix-store-references.patch;
        };
      in map (x: let file = lib.fmway.getFilename (x.drvAttrs.src or x); in
        replaces.${file} or x
      ) (args.patches or prevAttrs.patches or []);
      buildInputs = args.buildInputs or prevAttrs.buildInputs or [] ++ [
        lua5_4
      ];
      passthru.tests = args.tests or {} // {
        version = testers.testVersion {
          package = finalAttrs.finalPackage;
          command = "scroll --version";
          version = "scroll version ${finalAttrs.version}";
        };
      };
      meta = args.meta or prevAttrs.meta // {
        description = "i3-compatible Wayland compositor (sway) with a PaperWM layout like niri or hyprscroller";
        homepage = "https://github.com/dawsers/scroll";
        changelog = "https://github.com/dawsers/scroll/releases/tag/${finalAttrs.version}";
        mainProgram = "scroll";
        longDescription = ''
          scroll is an opinionated, i3-compatible Wayland compositor built as a fork of sway that replaces or augments sway’s default window layout with a PaperWM-style layout inspired by projects such as niri and hyprscroller. It targets users who like the keyboard-driven, tiling workflows of i3 and sway but want a distinctive, paper-like stacking/scrolling layout model that emphasizes smooth window motion, progressive stacking, and an ergonomically different window arrangement.
        '';
      };
    });
  in super.sway.override {
    sway-unwrapped = unwrapped;
  } // {
    inherit unwrapped;
  };

  inherit (pkgs) swaybg replaceVars lua5_4 fetchFromGitHub testers;
in _: mkScrollPkg (f: p: {
  version = "1.11.7";
  src = fetchFromGitHub {
    owner = "dawsers";
    repo = "scroll";
    rev = f.version;
    hash = "sha256-DkRDi99jirGsbZMR0rMuQbsGCIFnhJS7xyCh9o/Duc8=";
  };
}) // {
  buildScrollPackage = mkScrollPkg;
}
