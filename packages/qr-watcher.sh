# Usage: wl-paste --type image --watch qr-watcher
#
# @require zbar libnotify cliphist net-tools ripgrep file

TMP_FILE=$(mktemp /tmp/image.XXXXXX.png)
cat > "$TMP_FILE"
trap 'rm -f "$TMP_FILE"' EXIT
file --mime-type "$TMP_FILE" | rg '(image/.*)' &>/dev/null || exit

# share to kdeconnect
if type kdeconnect-cli &>/dev/null && netstat -tulpn 2>/dev/null | rg kdeconnectd &>/dev/null; then
  kdeconnect-cli -a | rg '^.*: ([0-9a-fA-F]+).*$' -r '$1' | while read id; do
    kdeconnect-cli --share "$TMP_FILE" --device $id &
  done
fi
# --quiet: hide technical info, --raw: remove prefix, -Sqrcode.enable: focus on QR
DECODED=$(zbarimg --quiet --raw -Sqrcode.enable "$TMP_FILE" 2>/dev/null)

if [ $? -eq 0 ] && [ ! -z "$DECODED" ]; then
  ACTION="$(notify-send -t 3000 "QR Code Detected" "$DECODED" --action="open=Open in Browser" --action="copy=Copy to Clipboard" --wait)"
  case "$ACTION" in
    "open")
      xdg-open "$DECODED"
      ;;
    *)
      echo -n "$DECODED" | wl-copy
      ;;
  esac
else
  cat "$TMP_FILE" | cliphist store
fi
