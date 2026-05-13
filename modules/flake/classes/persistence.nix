{ den, lib, inputs, ... }: let

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
in {
  den.classes.persistence = "Impermanence persistence class";

  den.policies.enable-impermanence = { host, ... }:
    lib.optionals host.impermanence.enable [
      (den.lib.policy.resolve { persistent = host.persistent; })
      (den.lib.policy.include {
        nixos.imports = [
          inputs.impermanence.nixosModules.impermanence
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
