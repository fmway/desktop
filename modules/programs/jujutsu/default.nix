{
  fmx.programs._.jujutsu = { config, ... }:
  {
    includes = [
      config._.starship
    ];
    homeManager = { config, ... }:
    {
      programs.jujutsu.enable = true;
      programs.jujutsu.settings = {
        user = config.programs.git.settings.user;
        ui.editor = "nvim";
        ui.default-command = "log";
      };
      programs.jjui.enable = true;
      programs.jjui.settings = {
        # preview.show_at_start = true;
        oplog.limit = 30;
        suggest.exec.mode = "fuzzy";
      };
    };

    _.starship.homeManager = { pkgs, ... }:
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
