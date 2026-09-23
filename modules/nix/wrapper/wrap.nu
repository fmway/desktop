# TODO: support custom hostname
let hostname: string = (sys host).hostname

def read-cache [file: string]: nothing -> record<substituters: list<string>, trusted-public-keys: list<string>> {
  open $file
}

def diff [flake_path: string, prev_cache_file: string, extra_args: list<any>]: nothing -> record<substituters: list<string>, trusted-public-keys: list<string>> {
  let current_cache_file: string = ^nix build --no-link --print-out-paths $"($flake_path)#nixosConfigurations.($hostname).config.system.\"cache-info.json\"" ...$extra_args
  let prev  = read-cache $prev_cache_file
  let current = read-cache $current_cache_file
  {
    substituters: ($current.substituters | difference $prev.substituters)
    trusted-public-keys: ($current.trusted-public-keys | difference $prev.trusted-public-keys)
  }
}

def --wrapped wrap [flake_path: string, $prev_cache_file, verbose: bool, --separate-args, cmds: list<string>, ...args] {
  let help: bool = ("--help" in $args) or ("-h" in $args)
  if $help {
    ^$cmds.0 ...($cmds | skip | append $args) --help
  } else {
    let verbose_args = if $verbose { [ "--verbose" ] } else []
    let normalize_args = if $separate_args {
      let a = ($args | split list "--" | [ ($in | first) ($in | skip | flatten) ])
      { pre: ($a.0 | append $verbose_args), post: $a.1 }
    } else {
      { post: ($args | append $verbose_args), pre: [] }
    }
    let extra_args = diff $flake_path $prev_cache_file $normalize_args.post | [
      ($in.substituters | each {|e| [ "--option" "extra-substituters" $e ]})
      ($in.trusted-public-keys | each {|e| ["--option" "extra-trusted-public-keys" $e ]})
    ] | flatten | flatten

    let final_args = [ ...($cmds | skip) ...$normalize_args.pre ...(if $separate_args { ["--"] } else {[]}) ...$normalize_args.post ...$extra_args ]
    exec $cmds.0 ...$final_args
  }
}
