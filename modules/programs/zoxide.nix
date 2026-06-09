{
  fmx.programs._.zoxide = {
    includes = [
      ({ user, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".local/share/zoxide"
        ];
      })
    ];

    homeManager.programs.zoxide.enable = true;
  };
}
