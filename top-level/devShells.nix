{ self, inputs, ... }:
{
  perSystem = { pkgs, system, config, lib, ... }: {
    nixpkgs.overlays = [
      inputs.fmway-lib.overlays.devshell-lorri-fix
    ];
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
