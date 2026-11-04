{ inputs, fmx, lib, ... }:
{
  fmx.kernels.cachy = {
    includes = [
      ({ from ? "xddxdd" }: {
        includes = [
          fmx.kernels.cachy.${from}
          fmx.kernels.scx
        ];
       })
    ];

    chaotic = {
      nixos = { host, config, ... }:
      {
        config = lib.mkMerge [
          { boot.kernelPackages = lib.mkDefault inputs.chaotic.legacyPackages.${host.system}.linuxPackages_cachyos; }
          (lib.mkIf (host.hasAspect <fmx/disk/zfs>) {
            boot.supportedFilesystems.zfs = true;
            boot.zfs.package = lib.mkDefault config.boot.kernelPackages.zfs_cachyos;
          })
        ];
      };

      inputs.chaotic = {
        url = "github:chaotic-cx/nyx";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "home-manager";
      };
    };

    xddxdd = {
      inputs.nix-cachyos-kernel = {
        url = "github:xddxdd/nix-cachyos-kernel";
        inputs.flake-parts.follows = "flake-parts";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-compat.follows = "flake-compat";
      };

      nixos = { pkgs, host, config, ... }:
      {
        config = lib.mkMerge [
          {
            boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest;
            nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ];
          }
          (lib.mkIf (host.hasAspect <fmx/disk/zfs>) {
            boot.supportedFilesystems.zfs = true;
            boot.zfs.package = lib.mkDefault config.boot.kernelPackages.zfs_cachyos;
          })
        ];
      };
    };
  };
}
