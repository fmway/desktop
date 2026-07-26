{
  fmx.programs._.fzf.homeManager.programs.fzf = {
    enable = true;
    # colors = {
    #   "bg" = "#1e1e1e";
    #   "bg+" = "#1e1e1e";
    #   "fg" = "#d4d4d4";
    #   "fg+" = "#d4d4d4";
    # };

    tmux.enableShellIntegration = true; # enable tmux integration

    fileWidget.command = "fd --type f"; # CTRL+T

    changeDirWidget.command = "fd --type d"; # ALT+C

    historyWidget.options = [
      "--sort"
      "--exact"
    ]; # CTRL+R
  };
}
