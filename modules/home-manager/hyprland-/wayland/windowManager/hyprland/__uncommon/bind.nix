{ pkgs, ... }:
{
  "$mod+D" = "exec fuzzel";
  "$mod+SHIFT+D" = "exec hyprctl dispatch exec $(${pkgs.dmenu}/bin/dmenu_path | fuzzel -d | xargs)";

  # terminal
  "$mod+RETURN" = "exec footclient";
  "$mod+SHIFT+RETURN" = "exec foot";

  # hyprpicker
  "$mod+ALT+P" = "exec echo -n \"$(hyprpicker)\" | wl-copy";

  # kill window
  "$mod+x" = "exec hyprctl kill";

  "$mod+SHIFT+E" = "exit";

  # pin current window
  "$mod+p" = "exec hyprctl dispatch pin";
  # "$mod+p" = ''exec, w="$(hyprctl -j activewindow)" && [ "$(echo $j | jq '.floating')" = "true" ] && (hyprctl dispatch pin && wtitle="$(echo $j | jq '.title')" && [ "$(echo $w | jq '.pinned')" = "true" ] && notify-send "Window $wtitle pinned\!" || notify-send "Window $wtitle unpinded\!" )'';

  # lock
  # "$mod+i" = "exec hyprlock";
  "$mod+i" = "exec swaylock --screenshots --clock --indicator --indicator-radius 100 --indicator-thickness 10 --effect-blur 7x5 --effect-vignette 0.5:0.5 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color  00000000 --fade-in 0.15 --ignore-empty-password --show-failed-attempts";

  # toggle on/off bar
  # "$mod+b" = ''exec, s="$(systemctl --property=StatusText --user status waybar  | grep Active | cut -d '(' -f 1 | cut -d ':' -f 2 | cut -d ' ' -f 2)" && [ "$s" = "active"  ] && systemctl --user stop waybar || systemctl --user start waybar'';

  # zoom screen
  "$mod+CONTROL+z" = "exec woomer";

  # move active window out from group
  "$mod+CONTROL+RETURN" = ''exec hyprctl dispatch "moveoutofgroup"'';
  "$mod+CONTROL+right" = "changegroupactive f";
  "$mod+CONTROL+left" = "changegroupactive b";

  # set layout
  "$mod+m" = "exec hyprctl --batch 'keyword general:layout master'";
  "$mod+d" = "exec hyprctl --batch 'keyword general:layout dwindle'";

  "$mod+P" = "pseudo"; # dwindle
  "$mod+S" = "togglesplit"; # dwindle
  "$mod+W" = "togglegroup";


  # windows management
  "$mod+F" = "fullscreen";
  "$mod+SHIFT+SPACE" = "togglefloating";

  # Switch workspaces with $mod + [0-9]
  "$mod+1" = "workspace 1";
  "$mod+2" = "workspace 2";
  "$mod+3" = "workspace 3";
  "$mod+4" = "workspace 4";
  "$mod+5" = "workspace 5";
  "$mod+6" = "workspace 6";
  "$mod+7" = "workspace 7";
  "$mod+8" = "workspace 8";
  "$mod+9" = "workspace 9";
  "$mod+0" = "workspace 10";

  # Scratchpad mode
  # Win [ Shift ] -
  "$mod+SHIFT+code:20" = "movetoworkspace special";
  "$mod+code:20" = "togglespecialworkspace";

  #
  # fn keys
  "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+";
  "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-";
  "XF86AudioMute" = "exec amixer set 'Master' toggle";
  "XF86MonBrightnessUp" = "exec brightnessctl s +2%";
  "XF86MonBrightnessDown" = "exec brightnessctl s 2%-";
}
