# df with nu compliant table
def --wrapped df [...args] {
  let exec = ^df ...$args | complete
  if $exec.exit_code != 0 { return (if ($exec.stdout | is-empty) { $exec.stderr } else $exec.stdout) }
  $exec.stdout
  | lines
  | if ($in | first | str starts-with Filesystem) {
      $in
      | parse -r '^(?<filesystem>.+)\s+(?<size>[^\s]+)\s+(?<used>[^\s]+)\s+(?<available>[^\s]+)\s+(?<use>[^\s]+)\s+(?<mountpoint>.+)$'
      | slice 1..-1
      | each {|i| $i | merge {
        size: ($i.size | into filesize)
        used: ($i.used | into filesize)
        available: ($i.available | into filesize)
      }}
    } else $exec.stdout 
}
