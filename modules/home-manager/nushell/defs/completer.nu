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
