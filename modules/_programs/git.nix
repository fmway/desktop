{ lib, ... }:
{
  git.enable = lib.mkDefault true;
  # git.delta.enable = true; # enable git diff with delta
  # git.difftastic.enable = true; # git diff with difftastic
  # git.diff-so-fancy.enable = true; # git diff with diff-so-fancy
  git.signing.format = "ssh";
  git.settings = {
    url = let
      sites = {
        "github.com" = "gh" ;
        "gitlab.com" = "gl";
        "codeberg.org" = "cb";
      };
    in lib.foldl' (acc: x: acc // {
      "https://${x}/".insteadOf = "${sites.${x}}:";
      "git@${x}:".insteadOf = "${sites.${x}}s:";
    }) {
      alias = {
        a = "add";
        cm = "commit";
        ch = "checkout";
        s = "status";
      };
    } (lib.attrNames sites);
  };
}
