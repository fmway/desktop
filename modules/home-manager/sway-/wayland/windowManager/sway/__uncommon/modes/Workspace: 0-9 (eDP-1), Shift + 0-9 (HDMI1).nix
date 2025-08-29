{ mod, defaultExiters, cmd, lib, ... }:
with cmd; {
  enterBy = "${mod}+Shift+p";
  binds = seq 1 10 (x: let
    i = toString (lib.mod x 10);
  in {
    "${i}" = swaymsg' "workspace" "number" x;
    "${mod}+${i}" = swaymsg' "workspace" "number" x;

    "Shift+${i}" = swaymsg' "workspace" "number" (x + 10);
    "${mod}+Shift+${i}" = swaymsg' "workspace" "number" (x + 10);
  });
  exitBy = defaultExiters;
}
