{ lib, ... }:
{
  fmx.tools.ai.opencode = let
    config_dirs = [
      ".config/opencode"
      ".local/share/opencode"
      ".local/state/opencode"
    ];
    cache_dirs = [ ".cache/opencode" ];
  in {
    jail.opencode.type = "agent";
    jail.opencode.permissions = c: with c; [
      (agent-tui (config_dirs ++ cache_dirs))
      (env (regex "^OPENCODE_"))
    ];
    v1.jail = { inputs', ... }: { opencode.package = inputs'.llm-agents.packages.opencode; };
    v2.jail = { inputs', ... }:
    rec {
      opencode.package = inputs'.llm-agents.packages.opencode2;
      # plus completions
      opencode.buildCommand = lib.concatMapAttrsStringSep "" (shell: p: /* sh */ ''
        mkdir -p "$out/${dirOf p}"
        HOME="$TMPDIR" ${lib.getExe opencode.package} --completions ${shell} > "$out/${p}"
      '') {
        fish = "share/fish/vendor_completions.d/opencode.fish";
        bash = "share/bash-completion/completions/opencode.bash";
        zsh  = "share/zsh/site-functions/_opencode";
      };
    };

    includes = [
      <fmx/tools/ai/opencode/v2>
      ({ host, persistent, ... }: {
        persistence = builtins.concatMap (user: [
          { ${persistent.defaultDirectory}.users.${user.userName}.directories = config_dirs; }
          { ${persistent.cacheDirectory}.users.${user.userName}.directories = cache_dirs; }
        ]) (builtins.attrValues host.users);
      })
    ];
  };
} 
