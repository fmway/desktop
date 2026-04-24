{ __findFile, ... }:
{
  fmx.version = {
    homeManager = { inputs, lib, ... }:
    {
      home.stateVersion = lib.mkDefault (with builtins;
        fromJSON (
          readFile "${inputs.home-manager}/release.json"
        )
      ).release;
    };

    nixos = { inputs, lib, ... }:
    {
      system.stateVersion = lib.mkDefault (
        lib.fileContents "${inputs.nixpkgs}/lib/.version");
    };
  };
}
