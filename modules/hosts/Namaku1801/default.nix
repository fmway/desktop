{ inputs, fmx, __findFile, ... }:
{
  den.hosts.x86_64-linux.Namaku1801 = {};

  den.aspects.Namaku1801 = {
    includes = [
      <fmx/boot>
      <fmx/version>
      (fmx.disk._.zfs "/dev/sda")
    ];
  };
}
