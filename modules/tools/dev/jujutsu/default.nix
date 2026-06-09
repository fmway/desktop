{ lib, den, ... }: let
  inherit (den.lib) policy;
in {
  fmx.tools.dev.jujutsu = {
    includes = [
      (policy.when (ctx: ctx.hasAspect <fmx/programs/starship>) (policy.include <fmx/tools/dev/jujutsu/starship>))
    ];
    homeManager = { user, config, ... }:
    {
      programs.jujutsu.enable = true;
      programs.jujutsu.settings = {
        ui.editor = "nvim";
        ui.default-command = "log";
        user = {
          name = user.userName;
        } // lib.optionalAttrs (!isNull (user.email or null)) {
          email = user.email;
        };
      };
      programs.jjui.enable = true;
      programs.jjui.settings = {
        # preview.show_at_start = true;
        oplog.limit = 30;
        suggest.exec.mode = "fuzzy";
      };
    };

    starship.homeManager = { pkgs, ... }:
    {
      home.packages = with pkgs;[
        starship-jj
      ];

      programs.starship.settings = {
        git_commit.disabled = true;
        git_status.disabled = true;
        git_metrics.disabled = true;
        git_branch.disabled = true;
      };
      programs.starship.settings.custom.jj = {
        command = "prompt";
        format = "$output";
        ignore_timeout = true;
        shell = ["starship-jj" "--ignore-working-copy" "starship"];
        use_stdin = false;
        when = true;

        # log --revisions @ --no-graph --color always --limit 1 --template '
        #   separate(" ",
        #     change_id.shortest(4),
        #     if(bookmarks, 
        #       "[" ++ bookmarks ++ "]"
        #     ),
        #     concat(
        #       if(conflict, "💥"),
        #       if(divergent, "🚧"),
        #       if(hidden, "👻"),
        #       if(immutable, "🔒"),
        #     ),
        #     raw_escape_sequence("\x1b[1;32m") ++ "\"" ++ truncate_end(29, description.first_line(), "…") ++ "\"" ++ raw_escape_sequence("\x1b[0m"),
        #     raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)")  ++ raw_escape_sequence("\x1b[0m"),
        #   )
        # '
      };

      xdg.configFile."starship-jj/starship-jj.toml".source =
      (pkgs.formats.toml { }).generate "starship-jj-config" (import ./_starship-jj.nix);
    };
  };
}
