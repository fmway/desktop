{ lib, ... }:
{
  fmx.nix = {
    includes = [
      <fmx/nix/runtime>
      ({ home ? null, ... }: {
        # enable nix.conf for standalone home manager, otherwise disable
        homeManager.xdg.configFile."nix/nix.conf".enable = lib.mkDefault (!isNull home);
      })
      ({ host, persistent, ... }: {
        persistence = [
          { ${persistent.defaultDirectory}.files = [ "/root/.local/share/nix/repl-history" ]; }
          { ${persistent.cacheDirectory}.directories = [ "/root/.cache/nix" ]; }
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence = [
          { ${persistent.defaultDirectory}.users.${user.userName}.files = [ ".local/share/nix/repl-history" ]; }
          { ${persistent.cacheDirectory}.users.${user.userName}.directories = [ ".cache/nix" ]; }
        ];
      })
      (lib.mkCross {
        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = false;
        };
      })
    ];
  };
}
