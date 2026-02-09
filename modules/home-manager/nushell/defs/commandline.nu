def "commandline prepend" [str: string, --smart (-s)] {
  let cmd = commandline | if ($in | str trim | is-empty) {
    $in + (history | last 1 | get 0.command | str trim)
  } else $in
  let ctx = do {
    let sudos = if $smart { [sudo doas please] | str join "|" | $"\(?:($in)\) " } else ""
    let re = $cmd | parse -r $"^\(?<space1>\\s*\)\(?<sudo>($sudos)\)?\(?<space2>\\s*\)\(?<tail>.*\)$" | get -o 0
    { head: $'($re.space1?)($re.sudo?)($re.space2?)', tail: $re.tail }
  }
  if ($ctx.tail | str starts-with $'($str)') {
      commandline edit --replace $'($ctx.head)($ctx.tail | str substring ($str | str length)..-1)'
  } else {
      commandline edit --replace $'($ctx.head)($str)($ctx.tail)'
  }
}

def "commandline append" [
  str: string,
  --exclusive (-e): string = ""
] {
  let cmd = commandline | if ($in | str trim | is-empty) {
    $in + (history | last 1 | get 0.command | str trim)
  } else $in
  if $exclusive != "" and not ($cmd | str trim | str starts-with $exclusive) { return }
  
  if ($cmd | str ends-with $'($str)') {
      commandline edit --replace $'($cmd | str substring 0..($str | str length | $in * -1 - 1))'
  } else {
      commandline edit --replace $'($cmd)($str)'
  }
}
