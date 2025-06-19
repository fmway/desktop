# NixOS configuration
<!--{=
 version = {
    home-manager = (with builtins; fromJSON (readFile "${inputs.home-manager}/release.json")).release;
    nixos-module = lib.fileContents "${inputs.nixpkgs}/lib/.version";
    lix = pkgs.lix.version;
  };
}-->
[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

[![CI](https://github.com/fmway/myOS/actions/workflows/ci.yml/badge.svg)](https://github.com/fmway/myOS/actions/workflows/ci.yml)

This is my NixOS configuration, applied to my current machine. You can apply, edit, and use it as you want.
> [!IMPORTANT]
> Documentation is still in Work In Progress

> [!NOTE]
> **System Information** : 
> - **Hardware** : [ThinkPad t480](https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/t480/default.nix)
> - **Display Manager** : GDM
> - **Desktop Environment / Window Manager** : [GNOME](https://www.gnome.org/), (and [swayfx](https://github.com/WillPower3309/swayfx))
> - **Flakes** : Yes
> - **Home Manager** : Yes, as NixOS Module
> - **Version** : <!--{ version.home-manager }--> (Home Manager), <!--{ version.nixos-module }--> (NixOS), <!--{ version.lix }--> (Lix)
