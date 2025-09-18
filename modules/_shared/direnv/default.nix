{ internal, _file, name, inputs, selfInputs ? inputs, ... }:
{ inputs, pkgs, config, lib, ... }: let
  flox_direnv = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/flox/flox-direnv/v1.1.0/direnv.rc";
    hash = "sha256-c2YCane8WGmYeCDc9wIZyVL8AgbdfhPaEoM+5aFuysw=";
  };
  direnvrc = lib.concatStringsSep "\n" [
    (builtins.readFile ./direnv.sh)
    (builtins.readFile flox_direnv)
  ];
in {
  inherit _file;
  programs.direnv = lib.mkMerge [
    {
      enable = true;
      nix-direnv.enable = true;
    }
    (let
      keys = lib.optionals (name != "homeManagerModules") [
        "direnvrcExtra"
      ] ++ lib.optionals (name == "homeManagerModules") [
        "stdlib"
      ];
    in lib.setAttrByPath keys direnvrc)
  ];
}
