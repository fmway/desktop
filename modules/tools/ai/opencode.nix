{
  fmx.tools.ai.opencode = let
    config_dirs = [
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
    ];
    cache_dirs = [ ".cache/opencode" ];
  in {
    jail = { inputs', ... }:
    {
      opencode.package = "${inputs'.llm-agents.packages.opencode.out}/bin/opencode";
      opencode.permissions = c: with c; [
        (agent-tui (config_dirs ++ cache_dirs))
        (env (regex "^OPENCODE_"))
      ];
    };

    includes = [
      ({ host, persistent, ... }: {
        persistence = builtins.concatMap (user: [
          { ${persistent.defaultDirectory}.users.${user.userName}.directories = config_dirs; }
          { ${persistent.cacheDirectory}.users.${user.userName}.directories = cache_dirs; }
        ]) (builtins.attrValues host.users ++ [ { userName = "root"; } ]);
      })
    ];
  };
} 
