{ lib, inputs, ... }: let
  concatDirenvRc = lib.concatMapStringsSep "\n" (item:
    if lib.types.pathInStore.check item && lib.pathIsRegularFile item then
      lib.fileContents item
    else item
  );
in {
  den.quirks.direnvrc = {};
  fmx.tools.dev.direnv = lib.fix (s: {
    includes = [
      <fmx/tools/dev/direnv/nix-direnv>
    ];

    homeManager = { direnvrc, ... }:
    {
      programs.direnv.enable = true;
      programs.direnv.stdlib = concatDirenvRc direnvrc;
    };
    
    nixos = { direnvrc, ... }:
    {
      programs.direnv.enable = true;
      programs.direnv.direnvrcExtra = concatDirenvRc direnvrc;
    };

    darwin = s.nixos;

    nix-direnv = lib.mkCross {
      programs.direnv.nix-direnv.enable = true;
    };

    lorri = {
      direnvrc = /* sh */ ''
        use_lorri() {
          eval "$(lorri direnv $@)"
        }
      '';

      homeManager.services.lorri = {
        enable = true;
        enableNotifications = true;
      };
    };

    direnv-instant = {
      homeManager = {
        imports = [
          (inputs.fmway-inputs.direnv-instant or inputs.direnv-instant).homeModules.direnv-instant
        ];

        programs.direnv-instant = {
          enable = true;
        };
      };
    };
  });
}
