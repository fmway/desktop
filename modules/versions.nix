{ lib, __findFile, ... }:
{
  den.default.includes = [
    <fmx/version>
  ];
  fmx.version = let
    getVersion = class: modulesPath: with builtins;
      if class == "nixos" then
        lib.fileContents "${modulesPath}/../../lib/.version"
      else (fromJSON (readFile "${modulesPath}/../release.json")).release;
  in {
    homeManager = { modulesPath, ... }:
    {
      home.stateVersion = getVersion "homeManager" modulesPath;
    };

    nixos = { modulesPath, ... }:
    {
      system.stateVersion = getVersion "nixos" modulesPath;
    };

    darwin = { modulesPath, ... }:
    {
      system.stateVersion = getVersion "darwin" modulesPath;
    };
  };
}
