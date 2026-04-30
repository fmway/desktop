# @description clone a symlink file to owned file

for link in $argv
  [ -L $link ] || begin
    echo "$link isn't a symlink" >&2
    return 1
  end

  set -l realpath "$(realpath $link)"
  unlink $link
  cat $realpath > $link
end
