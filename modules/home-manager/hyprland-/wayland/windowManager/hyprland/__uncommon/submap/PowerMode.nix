{
  cause = "$mod+CONTROL+P";

  bind = {
    "p" = "exec systemctl poweroff";
    "s" = "exec systemctl suspend";
    "r" = "exec systemctl reboot";
    "SHIFT+r" = "exec systemctl reboot --firmware-setup";
  };

  reset = [ "RETURN" "escape" ];
}
