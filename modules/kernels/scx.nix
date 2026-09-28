{ lib, ... }:
{
  fmx.kernels.scx = {
    nixos = { pkgs, host, config, ... }:
    {
      config = lib.mkMerge [
        (lib.mkIf (!isNull (host.scx.default.scheduler or null)) {
          services.scx.enable = true;
          services.scx.package = lib.mkDefault pkgs.scx.full;
          services.scx.scheduler = host.scx.default.scheduler;
          services.scx.extraArgs = host.scx.default.args or [];
        })
        (lib.mkIf (!isNull (host.scx.alter.scheduler or null)) {
          # change scheduler to scx.alter when power is on
          systemd.services.scx.serviceConfig = let
            bin = lib.getExe' config.services.scx.package;
            alter = lib.concatStringsSep " " ([ (bin host.scx.alter.scheduler) ] ++ host.scx.alter.args or []);
            default = lib.concatStringsSep " " ([ (bin config.services.scx.package) ] ++ host.scx.default.args or []);
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
}
