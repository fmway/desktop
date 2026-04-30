let _carapace_completer = {|spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

let _argc_completer = {|args: list<string>|
  argc --argc-compgen nushell "" ...$args
  | split row "\n"
  | each { |line| $line | split column "\t" value description }
  | flatten 
}

let _fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else {$value}
  }
}

$env.config.completions.external.completer = ({|spans| 
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -o 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }
  let sudos = ["doas" "sudo" "please"]
  let use_fish = [ "zfs" "zpool" "nix" ]
  let use_argc = [ "devenv" ]
  if ($spans.0 in $sudos) and ($spans.1? in $use_fish) {
    $_fish_completer
  } else if ($spans.0 in $sudos) and ($spans.1? in $use_argc) {
    $_argc_completer
  } else if ($spans.0 in $use_fish) {
    $_fish_completer
  } else if ($spans.0 in $use_argc) {
    $_argc_completer
  } else $_carapace_completer | do $in $spans
})
