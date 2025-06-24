#!{{ lib.getExe pkgs.bash }}

export PATH=$PATH:{{
  lib.makeBinPath [
    pkgs.sysctl
    pkgs.ripgrep
  ]
}}

temp="/tmp/old-ttl";

check_root() {
  [[ ! "$(whoami)" = "root" ]] &&
  # [ "$EUID" -ne 0 ] &&
    echo "You must run as root" &&
    exit 1
}

up() {
  check_root
  old="$(sysctl -n net.ipv4.ip_default_ttl)"
  echo "$old" > "$temp"
  sysctl -w net.ipv4.ip_default_ttl=65
  sysctl -a | rg 'net\.ipv6\.conf\..+\.hop_limit' | rg '([^=]+) = ([^=]+)' -r '$1' | while read i; do
    sysctl -w $i=65
  done
  echo "$old -> 65"
}

down() {
  check_root
  old="64"
  if [[ -e "$temp" ]]; then
    old="$(cat $temp | xargs)"
  fi
  sysctl -w net.ipv4.ip_default_ttl="$old"
  sysctl -a | rg 'net\.ipv6\.conf\..+\.hop_limit' | rg '([^=]+) = ([^=]+)' -r '$1' | while read i; do
    sysctl -w $i=$old
  done
  echo "65 -> $old"
  [[ -e "$temp" ]] && rm "$temp"
}

check_status() {
  if [ "$(sysctl -n net.ipv4.ip_default_ttl)" -eq 65 ]; then
    echo "enabled"
  else
    echo "disabled"
  fi
}

[ -z $1 ] && exit 1
case "$1" in
  up|u) up
  ;;
  down|d) down
  ;;
  status|s|c|check) check_status
  ;;
  *) exit 1
  ;;
esac

