{
  # hide titlebar
  titlebar = false;
  border = 4;

  # window rules
  commands = let
    c = builtins.listToAttrs (map (name: {
      inherit name;
      value = command: map (x: {
        inherit command;
        criteria.${name} = x;
      });
    }) [ "app_id" "class" "title" ]);
  in [
    { command = "fullscreen enable";
      criteria = rec {
        app_id = "fullscreen-window";
        class = app_id;
        title = app_id;
      };
    }
  ] ++ c.app_id "floating enable" [
    "pop-up"
    "buble"
    "task_dialog"
    "Preferences"
    "dialog"
    "menu"
    "connman-gtk"
    "org.telegram*"
    "org.kde.kdeconnect.app"
    "mpv"
    "org.kde.kdenlive"
    "pavucontrol"
    "io.github.celluloid_player.Celluloid"
    "libfm-pref-apps"
    "floating-window"
    "org.kde.filelight"
    "scrcpy"
    "org.twosheds.iwgtk"
  ] ++ c.class "floating enable" [
    "mpv"
    "floating-window"
  ] ++ c.title "floating enable" [
    "Picture in Picture"
    "File Operation Progress"
    "Confirm to replace files"
    "Whoops!"
    "Friends List"
  ];
}
