{ lib, ... }:
{
  bun = {
    enable = lib.mkDefault true;
    settings = {
      smol = true;
      telemetry = false;
      # test = {
      #   coverage = true;
      #   coverageThreshold = 0.9;
      # };
      install.lockfile = {
        print = "yarn";
      };
    };
  };
}
