{
  programs = {
    # github-cli
    gh.enable = true;
    gh.settings = {
      editor = "nvim";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
      git_protocol = "ssh";
    };
    # github-cli dashboard
    gh-dash.enable = true;
    gh-dash.settings = {
      prSections = [{
        title = "My Pull Requests";
        filters = "is:open author:@me";
      }];
    };
  };
}
