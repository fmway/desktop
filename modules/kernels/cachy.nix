{ inputs, lib, ... }:
{
  fmx.kernels._.cachy = { config, ... }:
  {
    includes = [
      config._.zfs
      config._.scx
    ];
    nixos = { pkgs, ... }:
    {
      boot.kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest;
      nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
    };

    _.zfs.nixos = { config, ... }:
    {
      boot.supportedFilesystems.zfs = true;
      boot.zfs.package = config.boot.kernelPackages.zfs_cachyos;
    };

    _.scx.nixos = { host, pkgs, config, ... }: let
      # standby scx
      scx.default.scheduler = host.aspect.meta.scx.default.scheduler or host.aspect.meta.scx.default or host.aspect.meta.scx or "scx_bpfland";
      scx.default.args = host.aspect.meta.scx.default.args or host.aspect.meta.scx.args or [ ];

      # when power on
      scx.alter.scheduler = host.aspect.meta.scx.alter.scheduler or host.aspect.meta.scx.alter or null;
      scx.alter.args = host.aspect.meta.scx.alter.args or scx.default.args;
    in {
      config = lib.mkMerge [
        {
          services.scx.enable = true;
          services.scx.package = lib.mkDefault pkgs.scx.full;
          services.scx.scheduler = scx.default.scheduler;
          services.scx.extraArgs = scx.default.args;
        }
        (lib.mkIf (!isNull scx.alter.scheduler) {
          # change scheduler to scx.alter when power is on
          systemd.services.scx.serviceConfig = let
            bin = lib.getExe' config.services.scx.package;
            alter = lib.concatStringsSep " " ([ (bin scx.alter.scheduler) ] ++ scx.alter.args);
            default = lib.concatStringsSep " " ([ (bin scx.default.scheduler) ] ++ scx.default.args);
          in {
            ExecStart = lib.mkForce (pkgs.writeScript "scx.sh" /* bash */ ''
              #!${lib.getExe pkgs.bash}
              
              # if discarging, use default, if else use alter
              if [ "$(cat /sys/class/power_supply/AC/online)" -eq 0 ]; then
                exec ${default}
              else
                exec ${alter}
              fi
            '');
          };

          systemd.services."scx-refresh" = {
            unitConfig = {
              Description = "refresh scx";
            };
            script = ''
              if systemctl status scx.service &>/dev/null; then
                systemctl stop scx.service
              fi
              systemctl start scx.service
            '';
            serviceConfig = {
              Type = "oneshot";
            };
          };

          services.udev.extraRules = /* udev */ ''
            ACTION=="change", \
              SUBSYSTEM=="power_supply", \
              KERNEL=="AC", TAG+="systemd", \
              ENV{SYSTEMD_WANTS}="scx-refresh.service"
          '';
        })
      ];
    };
  };
  flake-file.inputs.nix-cachyos-kernel = {
    url = "github:xddxdd/nix-cachyos-kernel";
    inputs.flake-parts.follows = "flake-parts";
  };
}
