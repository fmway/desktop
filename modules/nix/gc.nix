{ lib, ... }:
{
  fmx.nix._.gc = {
    description = ''
      Automatic nix gc

      # Usage
        fmx.nix._.gc "--delete-older-than 3d" "Mon,Fri *-*-* 00:00:00";
        # or in darwin
        fmx.nix._.gc "--delete-older-than 3d" [
          { Hour = 0; Minute = 0; WeekDay = 5; }
          { Hour = 0; Minute = 0; WeekDay = 1; }
        ];
    '';

    __functor = _s: options: dates:
      { class, aspect-chain }:
      if lib.unused aspect-chain builtins.elem class [ "nixos" "homeManager" "darwin" ] then {
        ${class}.nix.gc = {
          automatic = true; inherit options;
          ${if class == "darwin" then "interval" else "dates"} = dates;
        };
      } else {};
  };
}
