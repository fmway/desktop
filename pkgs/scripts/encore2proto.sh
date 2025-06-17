#!{{ lib.getExe pkgs.bash }}
export PATH=$PATH:{{
  lib.makeBinPath [
    pkgs.buf
  ]
}}

cd {{ pkgs.encore.src }}/proto
text=""
[ $# -lt 1 ] && {
  while read -r anu; do
    text+="
${anu}";
  done;
} || text="$1"
[ -z "$text" ] && exit 1
echo "$text" | buf convert --type encore.runtime.v1.RuntimeConfig --from -#format=json | base64
# pwd
# echo "$text"
