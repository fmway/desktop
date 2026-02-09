def --wrapped  nvim [...params] {
  let has_zoxide = which zoxide | is-not-empty
  let fix_first_param = if ($params.0 | path type) == "dir" {
    if $has_zoxide {
      zoxide add $params.0
    }
    $'+tcd ($params.0)'
  } else if not ($params.0 | path exists) and $has_zoxide {
    let q = zoxide query $params.0 | complete
    if $q.exit_code == 0 {
      $'+tcd ($q.stdout | str trim)'
    } else $params.0
  } else $params.0
  ^nvim ...($params | slice 1..-1 | prepend $fix_first_param)
}
