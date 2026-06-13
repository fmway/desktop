{ lib, ... }:
{
  fmx.programs.fastfetch.homeManager.programs.fastfetch = {
    enable = true;
    settings = builtins.fromJSON (lib.fileContents ./settings.json);
  };
}
