{ inputs, self, config, lib, ... } @ v:
{
  perSystem = { pkgs, inputs', ... } @ w: {
    nixpkgs.config = {
      allowUnfree = true;
      packageOverrides = pkgs:
        inputs'.nixvim.legacyPackages;
    };

    packages = {
      nixvim = pkgs.makeNixvimWithModule {
        module.imports = [
          inputs.nxchad.nixvimModules.default
          config.flake.nixvimModules.default
        ];
      };

      readme = let
        var = v // w // { prefix = "<!--{"; postfix = "}-->"; };
        txt = lib.fmway.mkParse' var (builtins.readFile ../docs/README.md);
      in pkgs.writeScriptBin "gen-readme.sh" /* bash */ ''
        #!${lib.getExe pkgs.bash}

        output="''${1:-/dev/stdout}"
        cat ${pkgs.writeText "README.md" txt} > $output
      '';
    };
  };
}
