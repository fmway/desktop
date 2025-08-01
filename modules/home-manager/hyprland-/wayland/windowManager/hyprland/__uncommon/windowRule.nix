let
  mdFloating = {
    float = true;
    size = [ 1000 500 ];
  };

  smFloating = {
    float = true;
    size = [ 600 300 ];
  };
in {
  "title:^(Save File)$" = mdFloating;
  "title:^(Open File*.*)$" = mdFloating;
  "initialClass:^(xdg-desktop-portal-gtk)" = mdFloating;
  "title:^(Print)$".float = true;
  "title:^(Volume Control)$".float = true;
  "title:^(floating)$" = smFloating;
  "class:^(floating)$" = smFloating;
  "class:(xdm-app)".float = true;
  "initialClass:^(floating)$" = smFloating;
  "title:^(Picture[-/ ]in[-/ ][P/p]icture)$".float = true;
  "title:^(Clipboard Histories)$" = smFloating // {
    pin = true;
    center = 1;
    stayfocused = true;
  };
  "title:^(MainPicker)" = smFloating // { center = 1; };
  "class:^(mpv)$".float = true;

  "initialClass:^()$" = {
    float = true;
    size = [ "auto" "auto" ];
    move = [ 1888 35 ];
    center = 0;
  };
  "com-group_finity-mascot-Main" = {
    float = true;
    noblur = true;
    nofocus = true;
    noshadow = true;
    noborder = true;
  };
}
