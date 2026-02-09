$env.ARGC_COMPLETIONS_ROOT = $env.HOME | path join ".local" "share" "argc-completions"
$env.ARGC_COMPLETIONS_PATH = $env.ARGC_COMPLETIONS_ROOT | path join "completions"

def generate-completion [--save (-s), ...args] {
  for cli in $args {
    let res = ^$"($env.ARGC_COMPLETIONS_ROOT)/scripts/generate.sh" $cli | complete
    print --stderr $"generate a ($cli) completion"
    if $res.exit_code == 0 and not ($res.stdout | is-empty) {
      if $save {
        $res.stdout | save -f $"($env.ARGC_COMPLETIONS_PATH)/($cli).sh"
      } else {
        print $res.stdout
      }
    } else {
      print --stderr "generate completion failed successfully."
    }
  }
}
