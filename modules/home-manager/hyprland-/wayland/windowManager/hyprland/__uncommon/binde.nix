{
  # reload config
  "$mod+SHIFT+r" = "exec hyprctl reload";

  "$mod+SHIFT+Q" = "killactive";

  # move active window in floating mode like i3 wm do
  # "$mod+right" = "moveactive 15 0";
  # "$mod+left" = "moveactive -15 0";
  # "$mod+up" = "moveactive 0 -15";
  # "$mod+down" = "moveactive 0 15";

  # swap window
  "$mod+SHIFT+left" = "movewindow l";
  "$mod+SHIFT+down" = "movewindow d";
  "$mod+SHIFT+up" = "movewindow u";
  "$mod+SHIFT+right" = "movewindow r";
  "$mod+SHIFT+h" = "movewindow l";
  "$mod+SHIFT+j" = "movewindow d";
  "$mod+SHIFT+k" = "movewindow u";
  "$mod+SHIFT+l" = "movewindow r";

  # Move focus with $mod + arrow keys
  "$mod+left" = "movefocus l";
  "$mod+down" = "movefocus d";
  "$mod+up" = "movefocus u";
  "$mod+right" = "movefocus r";
  "$mod+h" = "movefocus l";
  "$mod+j" = "movefocus d";
  "$mod+k" = "movefocus u";
  "$mod+l" = "movefocus r";

  # Move active window to a workspace with $mod + SHIFT + [0-9]
  "$mod+SHIFT+1" = "movetoworkspace 1";
  "$mod+SHIFT+2" = "movetoworkspace 2";
  "$mod+SHIFT+3" = "movetoworkspace 3";
  "$mod+SHIFT+4" = "movetoworkspace 4";
  "$mod+SHIFT+5" = "movetoworkspace 5";
  "$mod+SHIFT+6" = "movetoworkspace 6";
  "$mod+SHIFT+7" = "movetoworkspace 7";
  "$mod+SHIFT+8" = "movetoworkspace 8";
  "$mod+SHIFT+9" = "movetoworkspace 9";
  "$mod+SHIFT+0" = "movetoworkspace 10";

  # Move active window to a workspace with silent
  "$mod+CONTROL+1" = "movetoworkspacesilent 1";
  "$mod+CONTROL+2" = "movetoworkspacesilent 2";
  "$mod+CONTROL+3" = "movetoworkspacesilent 3";
  "$mod+CONTROL+4" = "movetoworkspacesilent 4";
  "$mod+CONTROL+5" = "movetoworkspacesilent 5";
  "$mod+CONTROL+6" = "movetoworkspacesilent 6";
  "$mod+CONTROL+7" = "movetoworkspacesilent 7";
  "$mod+CONTROL+8" = "movetoworkspacesilent 8";
  "$mod+CONTROL+9" = "movetoworkspacesilent 9";
  "$mod+CONTROL+0" = "movetoworkspacesilent 10";

  # Scroll through existing workspaces with $mod + scroll
  "$mod+mouse_down" = "workspace e+1";
  "$mod+mouse_up" = "workspace e-1";

  # move to workspace with keyboard instead of gestures
  "$mod+ALT+left" = "workspace e-1";
  "$mod+ALT+right" = "workspace e+1";
}
