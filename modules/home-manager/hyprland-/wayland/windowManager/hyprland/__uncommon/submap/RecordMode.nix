# TODO
{
  cause = "$mod+ALT+R";

  reset = [ "escape" "RETURN" ];
}
# configure record screen
# bind = $mod, R, submap, RecordScreenMode
# submap = RecordScreenMode
#
# # bind = , r, exec, pidof wf-recorder && notify-send "Record screen already running" || notify-send "Record screen start" && wf-recorder -p h264_qsv -f "/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mkv"
# # bind = SHIFT, R, exec, pidof wf-recorder && notify-send "Record screen already running" || notify-send "Record screen start" && wf-recorder -p h264_qsv -a -f "/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mkv"
# # bind = , s, exec, pidof wf-recorder && notify-send "Stop record screen!" && kill $(pidof wf-recorder) || notify-send "Record screen is not running!"
#
# bind = , r, exec, pidof wl-screenrec && notify-send "Record screen already running" || notify-send "Record screen start" && wl-screenrec --filename="/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mp4"
# bind = SHIFT, R, exec, pidof wl-screenrec && notify-send "Record screen already running" || notify-send "Record screen start" && wl-screenrec --audio --filename="/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mp4"
# bind = , g, exec, pidof wl-screenrec && notify-send "Record screen already running" || notify-send "Record screen start" && wl-screenrec --geometry="$(slurp)" --filename="/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mp4"
# bind = SHIFT, G, exec, pidof wl-screenrec && notify-send "Record screen already running" || notify-send "Record screen start" && wl-screenrec --audio --geometry="$(slurp)" --filename="/tmp/$(date '+%d_%B_%Y-%H.%M.%S').mp4"
# bind = , s, exec, pidof wl-screenrec && notify-send "Stop record screen!" && kill $(pidof wl-screenrec) || notify-send "Record screen is not running!"
#
# bind = , escape, submap, reset
# bind = , RETURN, submap, reset
# submap = reset
# <= reset
