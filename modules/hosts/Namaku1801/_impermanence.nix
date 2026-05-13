{ lib, config, ... }: {
  config = let
    postHook = ''
      zfs rollback -r zroot/ROOT@blank
    '';
    lanzabooteOrSystemdEnabled = config.boot.loader.systemd-boot.enable;
    # lanzabooteOrSystemdEnabled = config.boot.loader.systemd-boot.enable || (config.boot.lanzaboote.enable or false);
    systemdAsStage1 = config.boot.initrd.systemd.enable;
  in lib.mkMerge [
    {
      fileSystems."/persist".neededForBoot = true;
      fileSystems."/persist/home".neededForBoot = true;
      fileSystems."/persist/root".neededForBoot = true;
      fileSystems."/persist/shared_cache".neededForBoot = true;
    }
    (lib.mkIf (!systemdAsStage1 && lanzabooteOrSystemdEnabled) {
       boot.initrd.postDeviceCommands = lib.mkAfter postHook;
    })
    (lib.mkIf (!systemdAsStage1 && !lanzabooteOrSystemdEnabled) {
      boot.initrd.postResumeCommands = lib.mkAfter postHook;
    })
    (lib.mkIf systemdAsStage1 {
      boot.initrd.systemd.services.rollback = {
        description = "Rollback root filesystem";
        wantedBy = [ "initrd.target" ];
        after = [ "zfs-import-zroot.service" ];
        before = [ "sysroot.mount" ];
        path = [
          config.boot.zfs.package
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = postHook;
      };
    })
  ];
}
