{ internal, _file, name, ... }:
{ lib, pkgs, ... }:
{
  inherit _file;
  nix.settings = {
    substituters = [];
    trusted-public-keys = [];

    auto-optimise-store = lib.mkDefault false;
  };

  nix.gc = lib.mkMerge [
    {
      automatic = true;
      options = "--delete-older-than 3d";
    }

    # automatic nix gc every mondays and fridays
    # can't use lazy mkIf because interval doesn't exist in nixos/home-manager, and vice versa
    (let
      key  = if name == "nixDarwinModules" then ["interval"] else ["dates"];
      value= if name == "nixDarwinModules" then
        [
          { Hour = 0; Minute = 0; WeekDay = 5; }
          { Hour = 0; Minute = 0; WeekDay = 1; }
        ]
      else "Mon,Fri *-*-* 00:00:00";
    in lib.setAttrByPath key value)
  ];
}
