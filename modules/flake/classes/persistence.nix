{ den, lib, inputs, ... }: let
  uniqBy = fn: arr:
    builtins.foldl' (acc: e: if builtins.any (x: fn x == fn e) acc then
      acc
    else acc ++ [ e ]) [] arr;

  uniqLastBy = fn: arr: let
    rev = lib.reverseList arr;
  in lib.reverseList (uniqBy fn rev);

  persysOpt = { config, ... }:
  {
    options.impermanence.enable = lib.mkEnableOption "Enable impermanence support for this host.";
    options.persistent = {
      defaultDirectory = lib.mkOption {
        description = "Primary persistence directory path.";
        type = lib.types.str;
        default = "/persist";
      };
      cacheDirectory = lib.mkOption {
        description = "Cache persistence directory path. Defaults to persistent.defaultDirectory.";
        type = lib.types.str;
        default = config.persistent.defaultDirectory;
        defaultText = lib.literalExpression "persistent.defaultDirectory";
      };
    };
  };

  # Patch impermanence with auto dedup
  submodule-options = builtins.toFile "options.nix"
    (builtins.replaceStrings
      ["type = listOf (coercedTo str (f: { file = f; }) file);" "type = listOf (coercedTo str (d: { directory = d; }) dir);" "./lib.nix"]
      ["type = listOf (coercedTo str (f: { file = f; }) file); apply = lib.uniqLastBy (x: x.file);" "type = listOf (coercedTo str (d: { directory = d; }) dir); apply = lib.uniqLastBy (x: x.directory);" "${inputs.impermanence}/lib.nix"]
      (builtins.readFile "${inputs.impermanence}/submodule-options.nix"));
  patchModule = builtins.toFile "module.nix"
    (builtins.replaceStrings
      [ "./lib.nix" "./mount-file.bash" "./submodule-options.nix" "./home-manager.nix" "./create-directories.bash" ]
      [ "${inputs.impermanence}/lib.nix" "${inputs.impermanence}/mount-file.bash" "${submodule-options}" "${inputs.impermanence}/home-manager.nix" "${inputs.impermanence}/create-directories.bash" ]
      (builtins.readFile "${inputs.impermanence}/nixos.nix"));
in {
  den.classes.persistence = "Impermanence persistence class";

  den.policies.enable-impermanence = { host, ... }:
    lib.optionals host.impermanence.enable [
      (den.lib.policy.resolve { persistent = host.persistent; })
      (den.lib.policy.include {
        nixos.imports = [
          ({ pkgs, config, lib, options, utils, ... }: import patchModule { inherit pkgs config options utils; lib = lib // { inherit uniqLastBy uniqBy; }; })
        ];
      })
    ];

  den.policies.persistence-to-nixos = { host, ... }:
    lib.optional host.impermanence.enable
      (den.lib.policy.route {
        fromClass = "persistence";
        intoClass = "nixos";
        path = [ "environment" "persistence" ];
        adaptArgs = { config, ... }: { osConfig = config; };
      });

  den.schema.host.imports = [ persysOpt ];
  den.schema.host.includes = [
    den.policies.enable-impermanence
  ];
  den.default.includes = [ den.policies.persistence-to-nixos ];

  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.home-manager.follows = "home-manager";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
  };
}
