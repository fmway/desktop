{ lib, ... }:
{
  nix.settings = {
    substituters = [];
    trusted-public-keys = [];

    auto-optimise-store = lib.mkDefault false;
  };
}
