{
  fmx.tools.dev = {
    lazygit = {
      homeManager.programs.lazygit.enable = true;
      includes = [
        ({ user, persistent, ... }: {
          persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
            ".local/state/lazygit"
          ];
        })
      ];
    };
  };
}
