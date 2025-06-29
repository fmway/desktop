{ internal, lib, _file, ... } @ v:
{ config, pkgs, osConfig ? {}, ... } @ w:
{
  inherit _file;
  wayland.windowManager.hyprland = lib.fmway.treeImport {
    folder = builtins.toPath ./__still_need_to_fix;
    depth = 0;
    variables = v // w;
  };
}
