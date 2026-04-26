{ lib, ... }:
{
  fmx.version = let
    getVersion = class: modulesPath: with builtins;
      if class == "nixos" then
        lib.fileContents "${modulesPath}/../../lib/.version"
      else (fromJSON (readFile "${modulesPath}/../release.json")).release;
  in {
    homeManager = { modulesPath, ... }:
    {
      home.stateVersion = lib.mkDefault (getVersion "homeManager" modulesPath);
    };

    nixos = { modulesPath, ... }:
    {
      system.stateVersion = lib.mkDefault (getVersion "nixos" modulesPath);
    };

    darwin = { modulesPath, ... }:
    {
      system.stateVersion = lib.mkDefault (getVersion "darwin" modulesPath);
    };
  };
}
