{ self, lib, inputs, inputs', modulesPath, ... } @ v:
{
  flake = let
    mkConfs = { dir, trigger }: let
      dirs = builtins.readDir dir;
      filtered = lib.filterAttrs (k: v:
        v == "directory" &&
        lib.pathIsRegularFile "${dir}/${k}/${trigger}"
      ) dirs;
    in lib.listToAttrs (map (name: {
      inherit name;
      value = lib.fmway.withImport' "${dir}/${name}/${trigger}" v;
    }) (lib.attrNames filtered));
    system = "x86_64-linux";
  in {
    diskoConfigurations = mkConfs {
      dir = "${self.outPath}/hosts";
      trigger = "disko.nix";
    };
    hostConfs = mkConfs {
      dir = "${self.outPath}/hosts";
      trigger = "configuration.nix";
    };
    homeConfs = mkConfs {
      dir = "${self.outPath}/home";
      trigger = "default.nix";
    };
    nixosConfigurations = lib.mapAttrs (_: module:
      lib.nixosSystem {
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
          inherit inputs lib;
        };
      }
    ) self.hostConfs;
    homeConfigurations = lib.mapAttrs (_: module:
      lib.homeManagerConfiguration {
        pkgs = self.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          module
        ];
      }
    ) self.homeConfs;
  };
}
