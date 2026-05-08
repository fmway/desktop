{ lib, ... }:
{
  fmx.essentials._.auto-shutdown = {
    description = ''
      Auto shutdown when power is discharging (default: <= 15%, set in meta.battery_limit)
    '';

    __functor = _:
      { host, ... }: let
        shut_in = host.aspect.meta.battery_limit or 15;
      in {
        nixos =
        { pkgs, ... }: {
          systemd.services.auto-shutdown = {
            path = with pkgs;[
              systemd
              libnotify
              gnugrep
              su
              gnused
              gawk
              ps
              sysvtools
            ];
            environment = {
              SHUTDOWN_IN = toString shut_in;
            };
          };
          systemd.services.auto-shutdown.script = lib.mkForce /* bash */ ''
            # simple lock program
            if pidof -o %PPID -x "$0" >/dev/null; then
              echo "ERROR: Script $0 already running."
              exit 1
            fi

            ctrl_c() { exit 1; }
            trap ctrl_c SIGINT

            # reference: https://bbs.archlinux.org/viewtopic.php?pid=1280941#p1280941
            BATTERY_STATUS="$(cat /sys/class/power_supply/AC/online)"

            NOTIFY_TITLE="Baterai sekarat" NOTIFY_ICON=battery_empty NOTIFY_MESSAGE="Mati sia anjing!!!"
            NOTIFY_SEND="$(command -v notify-send)"

            bat-now() {
              cat /sys/class/power_supply/BAT*/capacity | awk '{sum+=$1} END {print int(sum/NR)}'
            }

            # thanks to: https://unix.stackexchange.com/questions/2881/show-a-notification-across-all-running-x-displays#answer-748296
            send-to() {
              local name busroute; name="$1"; shift; printf -v args " '%s'" "$@"
              busroute="/run/user/$(id -u "$name")/bus" || return 1
              su "$name" -c "env DBUS_SESSION_BUS_ADDRESS='unix:path=$busroute' $NOTIFY_SEND$args"
            }

            send-all() {
              for name in $(who | cut -f1 -d" " | sort -u); do
                send-to "$name" "$@" &
              done
              wait
            }

            if [ "$(bat-now)" -le "$SHUTDOWN_IN" ] && [ "$BATTERY_STATUS" -eq 0 ]; then
              send-all --urgency=critical --hint=int:transient:1 --icon "$NOTIFY_ICON" "$NOTIFY_TITLE" "$NOTIFY_MESSAGE"
              sleep 60s
              BATTERY_STATUS="$(cat /sys/class/power_supply/AC/online)"
              if [ "$BATTERY_STATUS" -eq 0  ]; then
                exec systemctl poweroff -i
              fi
            fi
          '';

          services.udev.extraRules = /* udev */ ''
            ACTION=="change", \
              SUBSYSTEM=="power_supply", \
              ENV{POWER_SUPPLY_NAME}=="BAT*", \
              ENV{POWER_SUPPLY_STATUS}=="Discharging|Not charging", \
              ATTR{capacity}=="${lib.genRegex shut_in}", \
              TAG+="systemd", \
              ENV{SYSTEMD_WANTS}="auto-shutdown.service"
          '';
        };
      };
  };
}
