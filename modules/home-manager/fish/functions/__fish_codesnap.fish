# @description screenshot fish code
type -q codesnap || return 1 # require codesnap-cli
set -l cmdline
if isatty stdin
  set cmdline (commandline --current-selection | fish_indent --only-indent | string collect)
  [ -n "$cmdline" ] || set cmdline (commandline | fish_indent --only-indent | string collect)
else
  while read -lz line
    set -a cmdline $line
  end
end
set -l t (mktemp --suffix ".png")
# FIXME: use current theme
set -l opts --has-breadcrumbs true --has-line-number
[ ! -e /etc/codesnap/config.json ] || set -a opts --config /etc/codesnap/config.json
codesnap -c "$cmdline" -l fish --file-path "init.fish" --title (whoami) $opts -o "$t" &>/dev/null
if type -q pbcopy
  pbcopy < "$t"
else if set -q WAYLAND_DISPLAY && type -q wl-copy
  wl-copy < "$t"
else if set -q DISPLAY && type -q xclip
  xclip -selection clipboard < "$t"
else if set -q DISPLAY && type -q xsel
  xsel --clipboard < "$t"
else if type -q clip.exe
  clip.exe < "$t"
end
rm "$t"
