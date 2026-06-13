{ inputs, lib, ... }:
{
  flake-file.inputs.disko = {
    url = "github:nix-community/disko";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # den.schema.host.imports = [
  #   fmx.schema.host
  # ];
  #
  # fmx.schema.host = { host, ... }:
  # {
  #   options.mainDisk = lib.mkOption {
  #     type = lib.disko.optionTypes.absolute-pathname;
  #     description = "Main disk Device";
  #     default = "/dev/sda";
  #   };
  # };

  imports = [
    {
      fmx.disk = lib.import-tree.toAttrs (
        { path, name }:
        {
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

  fmx.disk.zfs.auto-snapshot = {
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

  fmx.disk.zfs.auto-scrub = interval: {
    nixos.services.zfs.autoScrub.interval = interval;
  };
}
