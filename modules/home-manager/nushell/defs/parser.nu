# Convert from ini to structured data.
def "from ini" [
  --comma-to-list (-c),
]: string -> record {
  $in | lines | reduce --fold { _is_list: false, _tops: [] } {|str,acc|
    if ($str | str starts-with "#") or $str == "" {
      $acc
    } else {
      $str | parse -r '^(?:(?:\[(?<top>[^\]]+)\])|(?<name>[^=#]+)\s*(?:=\s*(?<value>[^#]*))?)\s*#?.*$' | get 0 | if $in.top? != null {
        let t = $in.top | str trim
        let is_list = $t in $acc._tops
        $acc | merge { _top: $t, _is_list: $is_list, _tops: (if $is_list { $acc._tops } else { $acc._tops | append $t }) }
      } else if $in.name? != null {
        let k = $in.name | str trim
        let v = $in.value | if $in != null {
          if not $comma_to_list {
            $in | str trim
          } else {
            let r = $in | split row ',' | each {|i| $i | str trim}
            if ($r | length) == 1 { $r.0 } else { $r }
          }
        }
        if $acc._top? == null {
          $acc | upsert $k $v
        } else {
          $acc | upsert $acc._top {|o|
            $o | get -o $acc._top | if $in != null and $o._is_list {
              $in | append { $k: $v }
            } else {
              $in | default {} | upsert $k {|oo|
                $oo | get -o $k | if $in != null { $in | append $v } else $v
              }
            }
          }
        }
      } else $acc
    }
  } | reject _top _tops _is_list
}
