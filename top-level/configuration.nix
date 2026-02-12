{ self, lib, inputs, inputs', modulesPath, ... } @ v:
{
  flake = let
    mkConfs = { dir, trigger, final ? (x: x) }: let
      dirs = builtins.readDir dir;
      filtered = lib.filterAttrs (k: v:
        v == "directory" &&
        lib.pathIsRegularFile "${dir}/${k}/${trigger}"
      ) dirs;
    in lib.listToAttrs (map (name: {
      inherit name;
      value = final "${dir}/${name}/${trigger}";
    }) (lib.attrNames filtered));
    system = "x86_64-linux";
  in {
    diskoConfigurations = mkConfs {
      dir = "${self.outPath}/hosts";
      trigger = "disko.nix";
      final = import;
    };
    nixosConfigurations = mkConfs {
      dir = "${self.outPath}/hosts";
      trigger = "configuration.nix";
      final = module: lib.nixosSystem {
        inherit system;
        modules = [
          module
          {
            nixpkgs.overlays = [
              (self: super: {
                inherit lib;
              })
            ];
          }
        ];
        specialArgs = {
          inherit lib;
          inputs = inputs // { fmway-conf = inputs.fmway-conf or inputs.self; };
        };
      } // { outPath = module; };
    };
    homeConfigurations = mkConfs {
      dir = "${self.outPath}/home";
      trigger = "default.nix";
      final = module: lib.homeManagerConfiguration {
        pkgs = self.legacyPackages.${system};
        extraSpecialArgs = {
          inputs = inputs // { fmway-conf = inputs.fmway-conf or inputs.self; };
        };
        modules = [
          module
        ];
      } // { outPath = module; };
    };
  };
}
