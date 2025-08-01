{
  cause = "$mod+CONTROL+B";

  binde = {
    "up" = "exec brightnessctl set 2%+ -s";
    "down" = "exec brightnessctl set 2%- -s";
    "right" = "exec brightnessctl set 1%+ -s";
    "left" = "exec brightnessctl set 1%- -s";

    "SHIFT+up" = "exec brightnessctl set 10%+ -s";
    "SHIFT+down" = "exec brightnessctl set 10%- -s";
    "SHIFT+right" = "exec brightnessctl set 5%+ -s";
    "SHIFT+left" = "exec brightnessctl set 5%- -s";
  };

  reset = [
    "escape"
    "RETURN"
  ];
}
