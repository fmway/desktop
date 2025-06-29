# Hidden secrets using agenix
{ lib, config, ... }:
let
  getNameAge = value: let
    matched = lib.match "^(.*)\\.age$" (toString value);
  in if lib.isList matched then baseNameOf (lib.elemAt matched 0) else matched;

  folder = builtins.toPath ./.;

  resultAges = import ./secrets.nix;
  files = lib.attrNames resultAges;

  # all /etc/nixos/secrets/<file>.age will be imported to age.secrets.<file>
  age.secrets = lib.listToAttrs (map (file: rec {
    name = getNameAge file;
    value = let
      isOwnedUser = name == "fmway";
    in {
      file = folder + ("/" + file);
      path = "/etc/secrets/${name}";
      owner = lib.mkIf isOwnedUser name;
      mode =
        if isOwnedUser then
          "0660"  # rw-rw----
        else
          "0664"; # rw-rw-r--
      symlink = false;
    };
  }) files);
in {
  inherit age;
}
