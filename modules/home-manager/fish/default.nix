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

  programs.fish.functions = let
    dir = builtins.toPath ./functions;
    scanned = builtins.readDir dir;
    filtered = lib.filterAttrs (p: t:
      t == "regular" && lib.hasSuffix ".fish" p
    ) scanned;
  in lib.mapAttrs' (x: _: let
    name = lib.removeSuffix ".fish" x;
    content = lib.fileContents "${dir}/${x}";
    value = fmway.parseFish content;
  in 
    lib.nameValuePair name value
  ) filtered;
}
