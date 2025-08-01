{
  cause = "$mod+CONTROL+G";

  binde = {
    "left" = "exec hyprctl dispatch moveintogroup l";
    "right" = "exec hyprctl dispatch moveintogroup r";
    "up" = "exec hyprctl dispatch moveintogroup u";
    "down" = "exec hyprctl dispatch moveintogroup d";

    "ALT+left" = "movefocus l";
    "ALT+right" = "movefocus r";
    "ALT+up" = "movefocus u";
    "ALT+down" = "movefocus d";
  };

  reset = [ "escape" "RETURN" ];
}
