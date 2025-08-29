{ mod, defaultExiters, cmd, lib, ... }:
with cmd; {
  enterBy = "${mod}+r";

  binds = hjkl (a: a': let
    c = resize.${lib.toLower a} 10;
  in { "${a'}" = c; "${a}" = c; });

  exitBy = defaultExiters;
}
