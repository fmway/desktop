{ lib, ... }:
{
  mkScanPlugins = pkgs: path: extendPlugins: let
    listTmuxConfigFiles = lib.filterAttrs (k: v:
      v == "regular" &&
      lib.hasSuffix".tmux" k
    ) (builtins.readDir path);
    result = lib.mapAttrsToList (k: _: let
      file = "${path}/${k}";
      key = lib.removeSuffix ".tmux" k;
    in {
      plugin = pkgs.tmuxPlugins.${key};
      extraConfig = lib.fileContents file;
    }) listTmuxConfigFiles;
  in extendPlugins ++ result;
}
