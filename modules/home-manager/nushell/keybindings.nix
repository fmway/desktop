{ lib, ... }:
# TODO: new lib with my style
[
  {
    name = "prepend_steamrun";
    modifier = "alt_shift";
    keycode = "char_s";
    mode = [ "emacs" "vi_normal" "vi_insert" ];
    event = [
      { send = "executehostcommand";
        cmd = "commandline prepend 'steam-run '";
      }
    ];
  }
  {
    name = "sudope";
    modifier = "alt";
    keycode = "char_k";
    mode = [ "emacs" "vi_normal" "vi_insert" ];
    event = [
      { send = "executehostcommand";
        cmd = "commandline prepend 'doas '";
      }
    ];
  }
  {
    name = "insert_systemd_inhibit";
    modifier = "alt";
    keycode = "char_i";
    mode = [ "emacs" "vi_normal" "vi_insert" ];
    event = [
      { send = "executehostcommand";
        cmd = "commandline prepend -s 'systemd-inhibit --what=idle '";
      }
    ];
  }
  {
    name = "nu_refresh";
    modifier = "alt_shift";
    keycode = "char_r";
    mode = [ "emacs" "vi_normal" "vi_insert" ];
    event = [
      { send = "executehostcommand";
        cmd = "exec nu";
      }
    ];
  }
] ++ map (x: let k = if x == "1080" then "0" else lib.fmway.firstChar x; in {
  name = "insert_yt_dlp_${x}p";
  modifier = "alt";
  keycode = "char_${k}";
  mode = [ "emacs" "vi_insert" ];
  event = [
    { send = "executehostcommand";
      cmd = "commandline append -e yt-dlp ' -f \"bestvideo[height<=${x}]+bestaudio/best[height<=${x}]\"'";
    }
  ];
}) [ "360" "480" "720" "1080" ]
