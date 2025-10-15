<!--{=
  cfg      = inputs.self.nixosConfigurations.Namaku1801.config;
  pkgs     = inputs.self.nixosConfigurations.Namaku1801.pkgs;
  ver.h    = cfg.home-manager.users.fmway.home.stateVersion;
  ver.n    = cfg.system.stateVersion;
  nix.name = lib.toSentenceCase cfg.nix.package.pname;
  nix.ver  = cfg.nix.package.version;
  kernel   = with cfg.boot; {
    name   = kernelPackages.kernel.cachyConfig.taste or kernelPackages.kernel.pname;
    inherit (kernelPackages.kernel) version;
  };
  re.ver   = "[0-9]{2}[.][0-9]{2}";
  re.ver2  = "[0-9]+[.][0-9]+[.][0-9]+";
  re.ver3  = "v[0-9]+[.][0-9]+";
}-->
# NixOS configuration

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

[![CI](https://github.com/fmway/myOS/actions/workflows/ci.yml/badge.svg)](https://github.com/fmway/myOS/actions/workflows/ci.yml)

This is my NixOS configuration, applied to my current machine. You can apply, edit, and use it as you want.
> [!IMPORTANT]
> Documentation is still in Work In Progress

> [!NOTE]
> **System Information** : 
> - **Hardware** : [ThinkPad t480](https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/t480/default.nix)
> - **Display Manager** : [ly (1.1.2)](https://github.com/fairyglade/ly) <!--{< rr re.ver2 cfg.services.displayManager.ly.package.version >}-->
>  <!--{# rr re.ver cfg.programs.niri.package.version #}-->
> - **Window Manager** : [Niri (25.08)](https://github.com/YaLTeR/niri) (disabled by default: sway and hyprland)
> - **Flakes** : Yes
> - **Home Manager** : Yes, as NixOS Module
>   <!--{# replace_re "${re.ver} \\((.+)\\), ${re.ver} \\((.+)\\), ${re.ver2} \\((.+)\\)" "${ver.h} ($1), ${ver.n} ($2), ${nix.ver} (${nix.name})"  #}-->
> - **Version** : 25.11 (Home Manager), 25.11 (NixOS), 2.31.2 (Nix)
> - **Kernel** : 6.17.1 (linux-cachyos) <!--{< rm [ (rver kernel.version) (rbet "(" ")" kernel.name) ] >}-->
