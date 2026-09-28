{ inputs, lib, ... }: let
  deps = {
    name = "deps@disko";
    inputs.disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
in {
  imports = [
    {
      fmx.disk._ = lib.import-tree.toAttrs (
        { path, name }:
        {
          includes = [ deps ];
          description = ''
            Usage:
              den.aspects.Namaku1801.includes = [
                <fmx/disk/${name}>
              ];
              # Set mainDisk via <host>.mainDisk (default "/dev/sda")
              den.hosts.x86_64-linux.Namaku1801.mainDisk = "/dev/nvme0n1";
          '';
          nixos.imports = [ inputs.disko.nixosModules.default ];
          disko = { mainDisk, ... } @ v: (import path (v // { inherit mainDisk; })).disko;
        }) ./_disks;
    }
  ];

  fmx.disk._.zfs._.auto-snapshot = {
    description = "enable zfs autosnapshot per 2 week and 1 month";
    nixos.services.zfs.autoSnapshot = {
      enable = true;
      frequent = 0;
      hourly = 0;
      daily = 0;
      weekly = 2;
      monthly = 1;
    };
  };

  fmx.disk._.zfs._.auto-scrub = interval: {
    nixos.services.zfs.autoScrub.interval = interval;
  };
}
