{ lib, ... }:
{
  fmx.nix = { config, ... }:
  {
    includes = [
      config._.cache
      ({ user, host, persistent, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName}.files = [
          ".local/share/nix/repl-history"
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/nix"
        ];
      })
      ({ class, aspect-chain }:
      lib.optionalAttrs (builtins.elem class [ "nixos" "homeManager" "darwin" ]) {
        ${class}.nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = false;
        };
      })
    ];
    homeManager = { pkgs, ... }: {
      nix.package = lib.mkDefault pkgs.nix;
    };
  };
}
