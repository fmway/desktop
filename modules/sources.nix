{ config, lib, inputs, ... }:
{
  options.source-archives = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  options.source-files = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config = let
    o = builtins.mapAttrs (_: url: {
      mainUrl = url; type = "tarball";
    }) config.source-archives // builtins.mapAttrs (_: url: {
      mainUrl = url;
      type = "file";
    }) config.source-files;
    p = builtins.toFile "sources.json" (builtins.toJSON o);
  in lib.mkIf (config.source-archives != {} || config.source-files != {}) {
    perSystem =
      { pkgs, ... }:
      {
        # minimal resource, maybe just using awk and bash
        packages.write-sources = let
          get-hash = pkgs.writeScript "get-hash.fish" ''
            #!${lib.getExe pkgs.fish}

            ${lib.fileContents "${inputs.fmway-lib}/scripts/get-hash.fish"}
          '';
          fetch-sources = pkgs.writeScript "fetch-sources" ''
            #!${lib.getExe pkgs.nushell}
            alias get-hash = ${get-hash}

            ${lib.fileContents "${inputs.fmway-lib}/scripts/fetch-sources.nu"}
          '';
        in pkgs.writeScriptBin "write-sources" ''
          #!${lib.getExe pkgs.bash}

          ${fetch-sources} ${p} > sources.json
        '';
      };
  };
}
