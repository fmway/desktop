{ pkgs, lib, ... }:
{
  programs.git.enable = lib.mkDefault true;
  # programs.git.delta.enable = true; # enable git diff with delta
  # programs.git.difftastic.enable = true; # git diff with difftastic
  # programs.git.diff-so-fancy.enable = true; # git diff with diff-so-fancy
  programs.git.signing.format = "ssh";
  programs.git.settings = {
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
