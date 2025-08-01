# TODO
{
  cause = "$mod+CONTROL+S";
  enable = false;

  reset = [ "escape" "RETURN" "SHIFT+escape" "SHIFT+RETURN" ];
}
# => ScreenshotsMode
# bind = $mod CONTROL, S, submap, ScreenshotsMode
# submap = ScreenshotsMode
#
# bind =, w, exec, hyprshot --freeze --clipboard-only -m window || notify-send --urgency=critical --expire-time=$(expr 1000 \* 3) 'Screenshot canceled!'
# bind =, o, exec, hyprshot --freeze --clipboard-only -m output || notify-send --urgency=critical --expire-time=$(expr 1000 \* 3) 'Screenshot canceled!'
# bind =, r, exec, hyprshot --freeze --clipboard-only -m region || notify-send --urgency=critical --expire-time=$(expr 1000 \* 3) 'Screenshot canceled!'
# bind =, s, exec, slurp
# bind =, b, exec, slurp -s "000000ff"
#
# bind =, escape, submap, reset
# bind =, RETURN, submap, reset
# submap = reset
# <= reset


