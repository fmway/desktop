{ lib, ... }:
{
  den.quirks.nix-options.description = "collect all nix options (especially for binary caches), useful for autoappend into the shell (like fish abbr)";
  fmx.nix = {
    includes = [
      <fmx/nix/cache>
      <fmx/nix/runtime>
      ({ host, persistent, ... }: {
        persistence = [
        {
          ${persistent.defaultDirectory}.files = [
            "/root/.local/share/nix/repl-history"
          ];
        }
        {
          ${persistent.cacheDirectory}.directories = [
            "/root/.cache/nix"
          ];
        }
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence = [
        {
          ${persistent.defaultDirectory}.users.${user.userName}.files = [
            ".local/share/nix/repl-history"
          ];
        }
        {
          ${persistent.cacheDirectory}.users.${user.userName}.directories = [
            ".cache/nix"
          ];
        }
        ];
      })
      (lib.genAttrs [ "nixos" "homeManager" "darwin" ] (class: {
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = false;
        };
      }))
    ];
  };
}
