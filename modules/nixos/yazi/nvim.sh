opts=()
for i in "$@"; do
  if [ -d "$i" ]; then
    opts+=( "+tcd $i" )
    break
  fi
done
exec nvim "${opts[@]}" "$@"
