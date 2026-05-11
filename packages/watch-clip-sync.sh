# usage: wl-paste --type text --watch watch-clip-sync
# @require cliphist ripgrep net-tools

TEXT="$(cat)"

cliphist store <<<"$TEXT"
# share to kdeconnect
if type kdeconnect-cli &>/dev/null && netstat -tulpn 2>/dev/null | rg kdeconnectd &>/dev/null; then
  kdeconnect-cli -a | rg '^.*: ([0-9a-fA-F]+).*$' -r '$1' | while read id; do
    kdeconnect-cli --share-text "$TEXT" --device "$id" &
  done
fi
