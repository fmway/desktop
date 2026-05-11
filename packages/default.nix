{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, ... }: let
  utils = import ./_utils.nix { inherit pkgs lib; };
in {
  qr-watcher = utils.toPkg ./qr-watcher.sh;
  watch-clip-sync = utils.toPkg ./watch-clip-sync.sh;
}
