let reader = { default: {|file| open $file}, }

def get_safe [name: any]: any -> any {
  if ($in | describe -d).type in [ list table record nothing ] {
    $in | get -o $name
  } else null
}

def --env "secret get" [opt: record] {
  if ($env | get --optional $opt._secret) == null {
    let read: closure = if $opt.read? == null {
      $reader.default
    } else {
      $reader | get $opt.read
    }
    load-env {
      $opt._secret: (do $read $opt._secret)
    }
  }
  $env | get $opt._secret
}

def "replace secret" []: any -> any {
  if ($in | describe -d).type == "record" {
    $in | transpose k v | reduce --fold {} {|el, acc|
      let t = $el.v | describe -d
      let value = if $t.type == "list" {
        $el.v | each {|i| $i | replace secret}
      } else if $t.type != "record" {
        $el.v
      } else if not ("_secret" in $el.v) {
        $el.v | replace secret
      } else {
        let v = secret get $el.v
        $el.v.paths? | default [] | reduce --fold $v {|i,a|
          $a | get_safe $i
        }
      }
      $acc | merge { $el.k: $value }
    }
  } else $in
}
