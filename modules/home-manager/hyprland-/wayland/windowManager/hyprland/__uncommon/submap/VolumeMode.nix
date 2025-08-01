{
  cause = "$mod+CONTROL+V";

  binde = {
    "right" = "exec amixer set 'Master' 5%+";
    "left" = "exec amixer set 'Master' 5%-";
    "up" = "exec amixer set 'Master' 1%+";
    "down" = "exec amixer set 'Master' 1%-";

    "SHIFT+right" = "exec amixer set 'Master' 15%+";
    "SHIFT+left" = "exec amixer set 'Master' 15%-";
    "SHIFT+up" = "exec amixer set 'Master' 10%+";
    "SHIFT+down" = "exec amixer set 'Master' 10%-";

    "SPACE" = "exec amixer set 'Master' toggle";
  };

  reset = [
    "escape"
    "RETURN"
  ];
}
