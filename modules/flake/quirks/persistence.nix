{ den, lib, inputs, ... }: let
  inherit (den.lib) policy;
  inherit (policy) pipe;

  persysOpt = { config, ... }:
  {
    options.persistent = {
      enable = lib.mkEnableOption "Enable impermanence/preservation support for this host";
      implementation = lib.mkOption {
        type = lib.types.enum [ "impermanence" "preservation" ];
        default = "impermanence";
      };
      defaultDirectory = lib.mkOption {
        description = "Primary persistence directory path";
        type = lib.types.str;
        default = "/persist";
      };
      cacheDirectory = lib.mkOption {
        description = "Cache persistence directory path";
        type = lib.types.str;
        default = config.persistent.defaultDirectory;
      };
    };
  };

  deepMergeList =
    builtins.zipAttrsWith (_: v: let
      f = builtins.head v;
    in
      if builtins.length v == 1 then
        f
      else if builtins.isAttrs f then
        deepMergeList v
      else if builtins.isList f then
        builtins.concatLists v
      else
        lib.last v
    );

  _impermanenceOpts = { mode = null; method = null; directory = null; file = null; hideMount = null; allowTrash = null; persistentStoragePath = null; user = null; group = null; };
  _preservationOpts = { mode = null; how = null; directory = null; file = null; inInitrd = null; user = null; group = null; configureParent = null; parent = null; mountOptions = null; createLinkTarget = null; };
  f = impl: v:
    if impl == "impermanence" then
      map (x: if builtins.isString x then x else builtins.intersectAttrs _impermanenceOpts x) v
    else
      map (x: if builtins.isString x then x else builtins.intersectAttrs _preservationOpts x) v;

  normalize = impl: builtins.mapAttrs (k: v: {
    directories = f impl (v.directories or []);
    files = f impl (v.files or []);
  } // lib.optionalAttrs (v ? users) {
    users = normalize impl v.users;
  });

  fix = implementation: v:
    if implementation == "impermanence" then {
      environment.persistence = v;
    } else {
      preservation = {
        enable = true;
        preserveAt = v;
      };

      systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

      # FIXME: still not understand wtf this is for
      # let the service commit the transient ID to the persistent volume
      # systemd.services.systemd-machine-id-commit = {
      #   unitConfig.ConditionPathIsMountPoint = [
      #     ""
      #     "/persist/etc/machine-id"
      #   ];
      #   serviceConfig.ExecStart = [
      #     ""
      #     "systemd-machine-id-setup --commit --root /persist"
      #   ];
      # };
    };
in {
  den.quirks.persistence.description = "Persistence quirks";

  den.schema.host.imports = [ persysOpt ];
  den.schema.host.includes = [
    den.policies.persistence-to-host
    den.policies.persistence-to-nixos
  ];

  den.schema.user.includes = [
    den.policies.expose-persistence
    den.policies.persistence-to-host
  ];

  den.policies.persistence-to-nixos = { host, ... }: let
    x = host.persistent.implementation;
  in lib.optional (host.persistent.enable)
    (policy.include {
      nixos = { persistence, ... }:
      {
        imports = [
          inputs.${x}.nixosModules.${x}
        ];
        config = fix x (deepMergeList (map (normalize x) (lib.unique persistence)));
      };
    });

  den.policies.expose-persistence =
    { host, ... }:
      pipe.from "persistence" [ pipe.expose ];

  den.policies.persistence-to-host =
    { host, ... }:
      (policy.resolve.shared { persistent = host.persistent; });
    
}

