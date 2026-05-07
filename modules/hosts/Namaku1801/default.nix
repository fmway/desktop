{ fmx, lib, __findFile, ... }:
{
  den.hosts.x86_64-linux.Namaku1801 = {
    meta = {
      zram.size = 16384; # 16GB
      zram.priority = 100;

      battery_limit = 10; # autoshutdown when battery under 10%
    };
  };
  den.aspects.Namaku1801 = {
    includes = [
      <fmx/essentials>
      <fmx/disk/zfs>
      <fmx/display-managers/ly>
      <fmx/privileges/doas>
      <fmx/privileges/please>
      <fmx/tools/nix-ld>
      <fmx/services/keyd>
    ];
    nixos.networking.hostId = lib.mkDefault "4970ef8d"; # required for zfs
    nixos = {
    # disable capslock
      services.xserver.xkb.options = lib.mkAfter "grp:shifts_toggle";

      services.xserver.xkb.layout = "us";
      console.keyMap = "us";
    };
    provides.to-users.includes = [
      <fmx/programs>
      <fmx/shells/fish>
      <fmx/shells/nushell>
      <fmx/editors/zed>
      <fmx/desktops/niri>
      (fmx.nix._.gc "--delete-older-than 3d" "Mon,Fri *-*-* 00:00:00")
    ];
  };

  den.ctx.host.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
}
