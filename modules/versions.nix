{
  den.default.includes = [
    <fmx/version>
  ];
  fmx.version = {
    homeManager = { modulesPath, lib, ... }:
    {
      home.stateVersion = lib.mkDefault (with builtins;
        fromJSON (
          readFile "${modulesPath}/../release.json"
        )
      ).release;
    };

    nixos = { modulesPath, lib, ... }:
    {
      system.stateVersion = lib.mkDefault (
        lib.fileContents "${modulesPath}/../../lib/.version");
    };
  };
}
