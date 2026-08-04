{ lib, inputs, ... }:
{
  fmx.nix._.runtime.includes = [ <fmx/nix/runtime/nix> ];
  fmx.nix._.runtime._.nix = lib.mkCross ({ pkgs, ... }: {
    nix.package = pkgs.nix;
    nix.settings.experimental-features = [ "pipe-operators" ];
  });

  fmx.nix._.runtime._.lix = { version ? "latest", ... }: {
    includes = [
      (lib.mkCross ({ pkgs, class, ... }: {
        key = "fmx@nix/runtime/lix";
        # TODO
        # imports = lib.optionals (version == "upstream") [
        #   (if class == "homeManager" then {
        #     nixpkgs.overlays = [
        #       inputs.dev.lix.overlays.default
        #     ];
        #   } else inputs.dev.lix."${class}Modules".default)
        # ];
        # nix = lib.optionalAttrs (version != "upstream") {
        #   package = pkgs.lixPackageSets.${version}.lix;
        # };
        nix.package = pkgs.lixPackageSets.${version}.lix;
        nix.settings.experimental-features = [ "pipe-operator" ];
      }))
    ];
    nix-options = {
      "trusted-substituters" = "https://cache.lix.systems";
      "trusted-public-keys" = "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=";
    };
  };

  # TODO
  # flake-file.specialisation.dev.inputs = {
  #   lix.url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
  #   lix.flake = false;
  #
  #   lix-module.url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
  #   lix-module.inputs.nixpkgs.follows = "nixpkgs";
  #   lix-module.inputs.lix.follows = "lix";
  # };

  # TODO
  # fmx.nix.runtime.dnix = mkCross ({ class, ... }: {
  #   imports = [
  #     inputs.dev.determinate."${class}Modules".default
  #   ];
  #   nix.settings.experimental-features = [ "wasm-builtin" "pipe-operators" ];
  # }) // {
  #   nix-options = {
  #     "substituters" = "https://install.determinate.systems";
  #     "trusted-public-keys" = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=";
  #   };
  # };
  #
  # fmx.nix.runtime.detsys.includes = [ <fmx/nix/runtime/dnix> ];
  # fmx.nix.runtime.determinate.includes = [ <fmx/nix/runtime/dnix> ];
  # fmx.nix.runtime.determinate-nix.includes = [ <fmx/nix/runtime/dnix> ];
  # flake-file.specialisation.dev.inputs.determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
}
