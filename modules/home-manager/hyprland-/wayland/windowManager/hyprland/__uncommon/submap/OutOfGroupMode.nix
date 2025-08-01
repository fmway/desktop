{
  cause = "$mod+CONTROL+G+O";

  binde = {
    "left" = "exec hyprctl dispatch moveoutofgroup l";
    "right" = "exec hyprctl dispatch moveoutofgroup r";
    "up" = "exec hyprctl dispatch moveoutofgroup u";
    "down" = "exec hyprctl dispatch moveoutofgroup d";

    "ALT+left" = "movefocus l";
    "ALT+right" = "movefocus r";
    "ALT+up" = "movefocus u";
    "ALT+down" = "movefocus d";
  };

  reset = [ "escape" "RETURN" ];
}
