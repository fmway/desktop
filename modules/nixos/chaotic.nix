{ inputs, lib, config, pkgs, ... }:
{
  imports = [
    inputs.chaotic.nixosModules.default
  ];

  services.scx.enable = lib.mkDefault true;
  services.scx.package = lib.mkDefault pkgs.scx.full;
  services.scx.scheduler = lib.mkDefault "scx_bpfland";
  services.scx.extraArgs = [ "-f" "-k" "-p" ];
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos;
  boot.zfs.package = lib.mkDefault pkgs.zfs_cachyos;

  # change scheduler to scx_flash when power is on
  systemd.services.scx.serviceConfig = with config.services.scx; let
    alter = "${lib.getExe' package "scx_flash"} -k";
    default = lib.concatStringsSep " " ([ (lib.getExe' package scheduler) ] ++ extraArgs);
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
}
