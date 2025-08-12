{ self, inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
  ];
  perSystem = { pkgs, system, config, lib, ... }: {
    pre-commit.settings = {
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
