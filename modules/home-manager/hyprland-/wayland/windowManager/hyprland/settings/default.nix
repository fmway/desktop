{  }:
{
  "$mod" = "WINDOW";
  binds = {
    allow_workspace_cycles = true;
    workspace_back_and_forth = true;
  };

  exec = [
    "pidof hyprnotify || hyprnotify"
  ];

  
  exec-once = [
    "foot --server"
    "swaybg -i ~/.wallpaper -m fill"
    # "waybar -c ~/.config/waybar/alter/hyprland.json -s ~/.config/waybar/alter/hyprland.css" # TODO
  ];

  # See https://wiki.hyprland.org/Configuring/Monitors/
  monitor = [
    "eDP-1,highres,auto,1,bitdepth,8"
    # "eDP-1,highres,auto,1"
    # "HDMI-A-1,preferred,auto,auto"
    # "HDMI-A-1, highres, 0x0, 1"
    # "eDP-1, 1920x1080, 1920x0, 1"
  ];


  debug.disable_logs = true;
}
