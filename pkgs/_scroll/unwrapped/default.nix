{ pkgs, lib, ... }:
pkgs.sway-unwrapped.overrideAttrs (finalAttrs: prevAttrs: {
  pname = "scroll";
  version = "1.12.1";
  src = pkgs.fetchFromGitHub {
    owner = "dawsers";
    repo = "scroll";
    rev = finalAttrs.version;
    hash = "sha256-DBXRF1gG+g3F43oF1M+1W/b1vFp8QnI7IhtWQWD+xIc=";
  };
  patches = let
    replaces = {
      "fix-paths.patch" = pkgs.replaceVars ./fix-paths.patch {
        inherit (pkgs) swaybg;
      };
      "load-configuration-from-etc.patch" = ./load-configuration-from-etc.patch;
      "sway-config-nixos-paths.patch" = ./sway-config-nixos-paths.patch;
      "sway-config-no-nix-store-references.patch" = ./sway-config-no-nix-store-references.patch;
    };
  in map (x: let file = lib.fmway.getFilename (x.drvAttrs.src or x); in
    replaces.${file} or x
  ) (prevAttrs.patches or []);
  nativeBuildInputs = prevAttrs.nativeBuildInputs or [] ++ (with pkgs; [
    glslang
    lcms
    hwdata
    libliftoff
  ]);
  buildInputs = prevAttrs.buildInputs or [] ++ (with pkgs; [
    lua5_4
    libgbm
    vulkan-loader
    seatd
    lcms
    libdisplay-info
    libliftoff
    libxcb-render-util
    libxcb-errors
    xwayland
  ]);
  passthru.tests = {
    version = pkgs.testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "scroll --version";
      version = "scroll version ${finalAttrs.version}";
    };
  };
  meta = prevAttrs.meta // {
    description = "i3-compatible Wayland compositor (sway) with a PaperWM layout like niri or hyprscroller";
    homepage = "https://github.com/dawsers/scroll";
    changelog = "https://github.com/dawsers/scroll/releases/tag/${finalAttrs.version}";
    mainProgram = "scroll";
    longDescription = ''
      scroll is an opinionated, i3-compatible Wayland compositor built as a fork of sway that replaces or augments sway’s default window layout with a PaperWM-style layout inspired by projects such as niri and hyprscroller. It targets users who like the keyboard-driven, tiling workflows of i3 and sway but want a distinctive, paper-like stacking/scrolling layout model that emphasizes smooth window motion, progressive stacking, and an ergonomically different window arrangement.
    '';
  };
})
