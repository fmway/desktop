{ self, inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = { pkgs, system, config, lib, ... }: {
    pre-commit.settings = {
      hooks.readme = {
        enable  = true;
        name    = "Compile Readme";
        files   = /* regex */ "^(docs\\/README\\.md|flake\\.(nix|lock)|top-level\\/pre-commit\\.nix)$";
        entry   = "nix run .#readme ./README.md";
        stages  = [ "pre-commit" ];
        verbose = true;
      };
      hooks.nixConf = {
        enable  = true;
        name    = "add nixConf in flake";
        files   = /* regex */ "^(top-level\\/(nixConfig|apps|pre-commit)\\.nix|modules\\/_shared\\/cache\\/.*)$";
        entry   = "${config.apps.generateNixConf.program} ./flake.nix";
        stages  = [ "pre-commit" ];
        verbose = true;
      };
    };
  };
}
