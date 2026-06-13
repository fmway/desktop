{ inputs, config, lib, ... }:
{
  fmx.editors.nixvim = {
    includes = [
      <fmx/editors/nixvim/_>
      ({ host, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.directories = [
          "/root/.local/state/nvim"
          "/root/.local/share/nvim/nvnotify1" # ignore nvnotify
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".local/state/nvim"
          ".local/share/nvim/nvnotify1" # ignore nvnotify
        ];
      })
    ];

    nixvim = {
      imports = [
        inputs.nxchad.nixvimModules.default
      ];
      luaLoader.enable = true;

      dependencies.gcc.enable = true;

      # add some filetype alias
      filetype = {
        filename = {
          "build.zig.zon" = "zig";
          "direnvrc" = "bash";
        };

        pattern = {
          ".*%.tmux" = "tmux";
          ".*%.blade%.php" = "blade";
          ".*/ghostty/config" = "toml";
          ".*/ghostty/themes/.*%.conf" = "dosini";
          ".*/zed/.*%.json" = "jsonc";
        };
      };
    };
  };

  flake-file.inputs = {
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-parts.follows = "flake-parts";
    };
    nxchad.url = "github:fmway/nxchad";
    nxchad.inputs = {
      fmway-lib.follows = "fmway-lib";
      nixvim.follows = "nixvim";
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      systems.follows = "nixvim/systems";
    } // lib.optionalAttrs (config ? flake-file.inputs.fmway-modules) {
      fmway-modules.follows = "fmway-modules";
    };
  };
}
