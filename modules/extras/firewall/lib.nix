{ lib, ... }: let
  portRegex = /* regex */ "([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])";
in {
  parse-range = value: let
    parts = builtins.match "^${portRegex}-${portRegex}$" value;
  in if isNull parts then null else {
    from = lib.toInt (builtins.elemAt parts 0);
    to = lib.toInt (builtins.elemAt parts 1);
  };
}
