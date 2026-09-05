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
      opencode.package = "${inputs'."numtide/llm-agents.nix".packages.opencode.out}/bin/opencode";
      opencode.permissions = c: with c; [
        loose
        network
        time-zone
        no-new-session
        tui
        vcs
        bind-project
        package-manager

        (env (regex "^OPENCODE_"))
      ] ++ map (d: rw "~/${d}") (config_dirs ++ cache_dirs);
    };

    includes = [
      ({ host, persistent, ... }: {
        persistence = builtins.concatMap (user: [
          { ${persistent.defaultDirectory}.users.${user.userName}.directories = config_dirs; }
          { ${persistent.cacheDirectory}.users.${user.userName}.directories = cache_dirs; }
        ]) (builtins.attrValues host.users) ++ [
          { ${persistent.defaultDirectory}.directories = map (d: "/root/${d}") config_dirs; }
          { ${persistent.cacheDirectory}.directories = map (d: "/root/${d}") cache_dirs; }
        ];
      })
    ];
  };
} 
