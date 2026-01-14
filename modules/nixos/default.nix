{ internal, sources, allModules, _file, ... }:
{ inputs ? {}, lib, ... }:
{
  inherit _file;
  imports = allModules ++ [
    inputs.fmway-modules.nixosModules.all
    sources."kaku/hardware/bluetooth"
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.adb.enable = lib.mkDefault true;

  # emulate /bin
  services.envfs.enable = true;

  services.xserver.xkb.options = lib.mkAfter "grp:shifts_toggle";
}
