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
          { boot.kernelPackages = lib.mkDefault (inputs.fmway-inputs.chaotic.outputs or inputs.chaotic).legacyPackages.${host.system}.linuxPackages_cachyos; }
          (lib.mkIf (host.hasAspect <fmx/disk/zfs>) {
            boot.supportedFilesystems.zfs = true;
            boot.zfs.package = lib.mkDefault config.boot.kernelPackages.zfs_cachyos;
          })
        ];
      };
    };

    xddxdd = {
      extraCaches.lantian = {
        substituters = [ "https://attic.xuyh0120.win/lantian" ];
        trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
      };
      inputs = {
        nix-cachyos-kernel = {
          url = "github:xddxdd/nix-cachyos-kernel";
          inputs.flake-parts.follows = "flake-parts";
        };
      };

      nixos = { pkgs, host, config, ... }:
      {
        config = lib.mkMerge [
          {
            boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest;
            nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
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
