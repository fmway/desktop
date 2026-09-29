{ den, inputs, lib, fmx, ... }:
{
  # TODO: maybe use quirks instead
  den.classes.nixvim = { };
  den.schema.flake-system.includes = [
    <fmx/editors/nixvim>
  ];
  fmx.editors.policies.nixvim-to-host = { host, ... }: [
    (den.lib.policy.route {
      fromClass = "nixvim";
      intoClass = "nixos";
      path = [ "programs" "nixvim" ];
      guard = { options, ... }: options ? programs.nixvim;
      reinstantiate = true;
    })
  ];
  fmx.editors.policies.nixvim-to-packages = { system, ... } @ a: let
    entity = a.__entityKind or "";
  in [
    (den.lib.policy.route {
      fromClass = "nixvim";
      intoClass = if entity == "flake-parts" then "flake-parts" else "packages";
      path = lib.optional (entity == "flake-parts") "packages" ++ [ "nvim" ];
      instantiate = { modules, ... }:
        inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          module.imports = modules;
        };
    })
  ];
  fmx.editors._.nixvim = {
    inputs = { inputs, ... }:
    {
      nixvim.url = "github:nix-community/nixvim";
      nixvim.inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
      nxchad.url = "github:fmway/nxchad";
      nxchad.inputs = {
        fmway-lib.follows = "fmway-lib";
        nixvim.follows = "nixvim";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      } // lib.optionalAttrs (inputs ? fmway-modules) {
        fmway-modules.follows = "fmway-modules";
      };
    };
    includes = builtins.attrValues fmx.editors.nixvim.provides ++ [
      <fmx/editors/policies/nixvim-to-host>
      <fmx/editors/policies/nixvim-to-packages>
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
}
