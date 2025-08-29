{ mod, defaultExiters, cmd, ... }:
with cmd; {
  enterBy = "${mod}+p";

  binds = rec {
    "p" = swaymsg' "bar" "mode" "toggle";
    "Shift+p" = p;
    "${mod}+p" = p;
    "${mod}+Shift+p" =  p;
  };

  exitBy = defaultExiters;
}
