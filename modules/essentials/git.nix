{ lib, ... }:
{
  fmx.essentials._.git = 
  { user, ... }:
  {
    nixos.programs.git.enable = true;
    homeManager.programs = {
      git.enable = true;
      # git.delta.enable = true; # enable git diff with delta
      # git.difftastic.enable = true; # git diff with difftastic
      # git.diff-so-fancy.enable = true; # git diff with diff-so-fancy
      git.signing.format = "ssh";
      git.settings = {
        alias = {
          a = "add";
          cm = "commit";
          ch = "checkout";
          s = "status";
        };

        user = {
          name = user.userName;
        } // lib.optionalAttrs (user ? aspect.meta.email) {
          email = user.aspect.meta.email;
        };
        url = let
          sites = {
            "github.com" = "gh" ;
            "gitlab.com" = "gl";
            "codeberg.org" = "cb";
          };
        in builtins.foldl' (acc: x: acc // {
          "https://${x}/".insteadOf = "${sites.${x}}:";
          "git@${x}:".insteadOf = "${sites.${x}}s:";
        }) {} (builtins.attrNames sites);
      };
    };
  };
}
