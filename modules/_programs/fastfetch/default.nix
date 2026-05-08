{ lib, ... }:
{
  programs.fastfetch = {
    enable = true;
    settings = builtins.fromJSON (lib.fileContents ./settings.json);
  };
}
