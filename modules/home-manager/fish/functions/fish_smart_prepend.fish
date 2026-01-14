# @description fish_commandline_prepend alternative with that respects sudo (and sudo-like)
set -l sudos sudo doas please # FIXME: add other sudo-like
set -l buffer (commandline)
set -l escaped (string escape --style=regex -- $argv)
if string match -rq "^(?:\\s*(?<sudo>$(string join "|" -- $sudos))\\s+)(?:(?<ctx>$escaped)\\s+)?(?<cmds>.*)" -- $buffer
  if [ -z $ctx ]
    commandline -r "$sudo $argv $cmds"
  else
    commandline -r "$sudo $cmds"
  end
else
  fish_commandline_prepend "$argv"
end

# optional, set cursor
if [ -z $ctx ]
  set -l cursor 0
  [ -z "$sudo" ] || set cursor (math $cursor + (string split "" -- $sudo | count) + 1)
  set cursor (math $cursor + (string split "" -- "$argv" | count))
  commandline -C $cursor
end
