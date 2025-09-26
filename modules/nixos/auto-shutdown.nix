{ internal, lib, _file, ... }:
{ pkgs, config, ... }:
{
  inherit _file;
  systemd.services.auto-shutdown.script = lib.mkForce /* bash */ ''
    ctrl_c() {
      rm -rf /tmp/notify-shutdown
      exit
    }
    trap ctrl_c SIGINT
    export PATH=$PATH:${lib.makeBinPath (with pkgs;[
      systemd
      libnotify
      gnugrep
      su
      gnused
      gawk
      ps
      sysvtools
    ])}

    # reference: https://bbs.archlinux.org/viewtopic.php?pid=1280941#p1280941
    #
    ! [ -e /tmp/notify-shutdown ] || exit

    bat-now() {
      BAT="$(cat /sys/class/power_supply/BAT0/capacity)"

      if [ -e /sys/class/power_supply/BAT1 ]; then
        BAT1="$(cat /sys/class/power_supply/BAT1/capacity)"
        BAT="$(( (BAT + BAT1) / 2 ))"
      fi
      echo "$BAT"
    }

    BATTERY_STATUS="$(cat /sys/class/power_supply/AC/online)"

    NOTIFY_TITLE="Baterai sekarat"
    NOTIFY_ICON=battery_empty
    NOTIFY_MESSAGE="Mati sia anjing!!!"
    NOTIFY_SEND="$(command -v notify-send)"

    export SHUTDOWN_WITH=${toString (lib.attrByPath [ "data" "battery_limit" ] 25 config)}

    #Detect the name of the display in use
    display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

    #Detect the user using such display
    user=$(who | grep seat0 | awk '{print $1}' | head -n 1)

    #Detect the id of the user
    uid=$(id -u $user)

    echo "USER: $user"
    echo "DISPLAY: $display"
    echo "UID: $uid"

    if [ "$(bat-now)" -le "$SHUTDOWN_WITH" ] && [ "$BATTERY_STATUS" -eq 0 ]; then
      touch /tmp/notify-shutdown
      su "''${user}" -c "env DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus ''${NOTIFY_SEND} --urgency=critical --hint=int:transient:1 --icon $NOTIFY_ICON '$NOTIFY_TITLE' '$NOTIFY_MESSAGE'"
      sleep 60s
      BATTERY_STATUS="$(cat /sys/class/power_supply/AC/online)"
      if [ "$BATTERY_STATUS" -eq 0  ]; then
        exec systemctl poweroff -i
      fi
      rm /tmp/notify-shutdown
    fi
  '';

  services.udev.extraRules = /* udev */ ''
    ACTION=="change", \
      SUBSYSTEM=="power_supply", \
      ENV{POWER_SUPPLY_NAME}=="BAT*", \
      ENV{POWER_SUPPLY_STATUS}=="Discharging", \
      ATTR{capacity}=="${lib.genRegex (lib.attrByPath [ "data" "battery_limit" ] 10 config)}", \
      TAG+="systemd", \
      ENV{SYSTEMD_WANTS}="auto-shutdown.service"
  '';
}
