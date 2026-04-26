{ mainDisk, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = mainDisk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };
    zpool.zroot = {
      type = "zpool";
      rootFsOptions = {
        # https://wiki.archlinux.org/title/Install_Arch_Linux_on_ZFS
        acltype = "posixacl";
        atime = "off";
        compression = "zstd";
        mountpoint = "none";
        xattr = "sa";
      };
      options.ashift = "12";

      datasets = {
        "local" = {
          type = "zfs_fs";
          options.mountpoint = "none";
        };
        "local/home" = {
          type = "zfs_fs";
          mountpoint = "/persist/home";
          # Used by services.zfs.autoSnapshot options.
          options."com.sun:auto-snapshot" = "true";
          options."dedup" = "on";
        };
        "local/root" = {
          type = "zfs_fs";
          mountpoint = "/persist/root";
          options."com.sun:auto-snapshot" = "true";
          # options."dedup" = "on";
       };
        "local/nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options."com.sun:auto-snapshot" = "false";
        };
        "local/shared_cache" = {
          type = "zfs_fs";
          mountpoint = "/persist/shared_cache";
          options."com.sun:auto-snapshot" = "false";
          options."dedup" = "on";
        };
        "local/persist" = {
          type = "zfs_fs";
          mountpoint = "/persist";
          options."com.sun:auto-snapshot" = "false";
          # options."dedup" = "on";
        };
        "ROOT" = {
          type = "zfs_fs";
          mountpoint = "/";
          options."com.sun:auto-snapshot" = "true";
          postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/ROOT@blank$' || zfs snapshot zroot/ROOT@blank";
        };
        # refreservation=10G -o mountpoint=none zroot/reserved
        "reserved" = {
          type = "zfs_fs";
          options.mountpoint = "none";
          options."refreservation" = "10G";
        };
      };
    };
  };
}
