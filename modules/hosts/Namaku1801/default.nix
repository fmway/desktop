{ inputs, fmx, __findFile, ... }:
{
  den.hosts.x86_64-linux.Namaku1801 = {};

  den.aspects.Namaku1801 = {
    includes = [
      <fmx/nix>
      <fmx/boot>
      <fmx/version>
      (fmx.disk._.zfs "/dev/sda")
      (fmx.nix._.gc "--delete-older-than 3d" "Mon,Fri *-*-* 00:00:00")
    ];
  };
}
