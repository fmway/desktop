{ inputs, lib, ... }:
{
  den.aspects.overlays.nur = lib.mkCross {
    nixpkgs.overlays = [
      inputs.nur.overlays.default
    ];
  };

  den.aspects.overlays.gvfs.google-drive = {
    description = "Restore Google Drive support to gvfs and gnome-online-accounts";
  } // lib.mkCross {
    nixpkgs.overlays = [
      ((import <sources/nix-gvfs-googledrive/flake.nix>).outputs { self = {}; nixpkgs = {}; }).overlays.default
    ];
  };

  source-files."nix-gvfs-googledrive/flake.nix" = "https://raw.githubusercontent.com/j-a-sunny/nix-gvfs-googledrive/refs/heads/main/flake.nix";
}
