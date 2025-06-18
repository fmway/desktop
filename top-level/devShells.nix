{ self, inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = { pkgs, system, config, lib, ... }: {
    pre-commit.settings = {
      hooks.readme = {
        enable = true;
        name = "Compile Readme";
        files = /* regex */ "^docs\\/README\\.md$";
        entry = "nix run .#readme ./README.md";
        stages = [ "pre-commit" ];
        verbose = true;
      };
    };
    devShells.default = pkgs.mkShellNoCC {
      shellHook = ''
        ${config.pre-commit.installationScript}
      '';
      NIXD_PATH = lib.concatStringsSep ":" [
        "pkgs=${self.outPath}#legacyPackages.${system}"
        "nixos=${self.outPath}#nixosConfigurations.Namaku1801.options"
        "home-manager=${self.outPath}#nixosConfigurations.Namaku1801.options.home-manager.users.type.getSubOptions []"
        "flake-parts=${self.outPath}#debug.options.perSystem.type.getSubOptions []"
      ];
    };
  };
}
