# NixOS configuration
<!--{=
  cfg = inputs.self.nixosConfigurations.Namaku1801.config;
  pkgs = inputs.self.nixosConfigurations.Namaku1801.pkgs;
  version = {
    home-manager = cfg.home-manager.users.fmway.home.stateVersion;
    nixos-module = cfg.system.stateVersion;
  };
  nix = {
    name = lib.toSentenceCase cfg.nix.package.pname;
    version = cfg.nix.package.version;
  };
  kernel = with cfg.boot; {
    name = kernelPackages.kernel.cachyConfig.taste or kernelPackages.kernel.pname;
    inherit (kernelPackages.kernel) version;
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
> - **Display Manager** : GDM <!--{ "(v${pkgs.gdm.version})" }-->
> - **Desktop Environment / Window Manager** : [GNOME<!--{ " v" + pkgs.gnome-shell.version }-->](https://www.gnome.org/)
> - **Flakes** : Yes
> - **Home Manager** : Yes, as NixOS Module
> - **Version** : <!--{ version.home-manager }--> (Home Manager), <!--{ version.nixos-module }--> (NixOS) <!--{ ", ${nix.version} (${nix.name})" }-->
> - **Kernel** : <!--{ "${kernel.version} (${kernel.name})" }-->
