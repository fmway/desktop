# @description simple suck for handling folder
if set -q argv[1] && not string match -rq '^[+-]' -- $argv[1]
  # if first args is directory
  if [ -d "$argv[1]" ]
    ! command -q zoxide || zoxide add $argv
    set argv[1] +"tcd $argv[1]"
  else if ! [ -e "$argv[1]" ]
    and command -q zoxide
    and set dir (zoxide query "$argv[1]" 2>/dev/null)
    set argv[1] +"tcd $dir"
  end
end
command nvim $argv
