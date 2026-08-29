{
  fmx.tools.ai.opencode = {
    jail = { inputs', ... }:
    {
      opencode.package = inputs'.llm-agents.packages.opencode;
      opencode.permissions = c: with c; [
        loose
        network
        time-zone
        no-new-session

        (env "COLORTERM" "truecolor")

        (add-runtime /* sh */ ''
          if [ -d "$PROJECT_DIR" ]; then
            RUNTIME_ARGS+=(--bind "$PROJECT_DIR" "$PROJECT_DIR")
          else
            echo "Error: PROJECT_DIR '$PROJECT_DIR' does not exist" >&2
            exit 1
          fi
        '')
        (env (regex "^OPENCODE_"))

        (rw "~/.config/opencode")
        (rw "~/.local/share/opencode")
        (rw "~/.local/state/opencode")
        (ro "~/.config/git")
        (ro "~/.config/jj")

        # prevent re-downloading models and packages
        (rw "~/.cache/opencode")
        (rw "~/.npm")

        (rw "~/.deno")
        (rw "~/.gradle")
      ];
    };

    includes = [
      ({ host, persistent, ... }: {
        persistence = builtins.concatMap (user: [
        {
          ${persistent.defaultDirectory}.users.${user.userName}.directories = [
            ".config/opencode"
            ".local/state/opencode"
            ".local/share/opencode"
          ];
        }
        {
          ${persistent.cacheDirectory}.users.${user.userName}.directories = [
            ".cache/opencode"
          ];
        }
        ]) (builtins.attrValues host.users) ++ [
        {
          ${persistent.defaultDirectory}.directories = [
            "/root/.config/opencode"
            "/root/.local/state/opencode"
            "/root/.local/share/opencode"
          ];
        }
        {
          ${persistent.cacheDirectory}.directories = [
            "/root/.cache/opencode"
          ];
        }
        ];
      })
    ];
  };
} 
