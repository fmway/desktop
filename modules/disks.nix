{ inputs, den, __findFile, lib, ... }:
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
      fmx.disk._ = lib.import-tree.toAttrs (
        { path, name }:
        {
          description = ''
            Usage:
              den.aspects.Namaku1801.includes = [
                <fmx/disk/${name}>
              ];
              # Set mainDisk via meta.mainDisk (default "/dev/sda")
              den.aspects.Namaku1801.meta.mainDisk = "/dev/nvme0n1";
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
