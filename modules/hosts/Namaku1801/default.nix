{ inputs, fmx, lib, __findFile, ... }:
{
  den.aspects.Namaku1801 = let
    gc = fmx.nix._.gc "--delete-older-than 3d" "Mon,Fri *-*-* 00:00:00";
  in {
    includes = [
      <fmx/nix>
      <fmx/boot>
      <fmx/disk/zfs>
      <fmx/shells/fish>
      gc
    ];
    nixos.networking.hostId = lib.mkDefault "4970ef8d"; # required for zfs
    provides.to-users.includes = [
      <fmx/programs>
      gc
    ];
  };

  den.ctx.host.nixos.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
  };
}
