{ lib, ... }:
{
  tmux.mkScanPlugins = pkgs: path: extendPlugins:
    extendPlugins ++ (((lib.import-tree
      .initFilter (lib.hasSuffix ".tmux"))
      .map (p: let k = lib.fmway.basename p; in {
        plugin = pkgs.tmuxPlugins.${k};
        extraConfig = lib.fileContents p;
      }) )
      .pipeTo lib.id)
      path;
}
