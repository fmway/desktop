{ lib, ... }:
{ 
  fmx.shells._.fish = { config, ... }:
  {
    nixos = {
      programs.fish.enable = true;
      programs.fish.generateCompletions = lib.mkDefault false;
    };
    homeManager = {
      programs.fish.enable = true;
      programs.fish.generateCompletions = lib.mkDefault false;
      programs.fish.interactiveShellInit = /* fish */ ''
        set fish_greeting # Disable greeting
        printf '\e[5 q'
        apply-my-prompt
        apply-my-theme
      '';
    };
    includes = builtins.attrValues config.provides ++ [
      ({ user, host, persistent, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.files = [
          ".local/share/fish/fish_history"
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/fish"
        ];
      })
    ];
    _.functions = { config, ... }: {
      description = "Collection of my fish functions";
      includes = builtins.attrValues config.provides;
      _ = ((lib.import-tree
        .initFilter (lib.hasSuffix ".fish"))
        .toAttrs ({ path, name, ... }: let
          v = lib.fmway.parseFish (lib.fileContents path);
        in {
          description = builtins.concatStringsSep ": " (["${name}.fish"] ++ lib.optional (v ? description) v.description);
          homeManager.programs.fish.functions.${name} = v;
        }))
        ./_functions;
    };
  };
}
