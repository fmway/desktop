{ internal, _file, lib, fmway ? lib.fmway, ... }:
{ lib, ... }:
{
  inherit _file;
  imports = [
    ./binds.nix
  ];
  programs.fish.generateCompletions = lib.mkDefault false; # dont create fish completions by manpage, very very useless
  programs.fish.enable = lib.mkDefault true;
  programs.fish.interactiveShellInit = /* fish */ ''
    set fish_greeting # Disable greeting
    printf '\e[5 q'
  '';

  programs.fish.functions = lib.fish.importFunctions ./functions;
}
