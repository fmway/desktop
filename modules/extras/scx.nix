{ lib, den, ... }: let
  moduleScx = {
    options.scx = rec {
      default.scheduler = lib.mkOption {
        description = "default scheduler";
        type = lib.types.str;
        default = "scx_bpfland";
      };
      default.args = lib.mkOption {
        description = "args for the scheduler";
        type = lib.types.listOf lib.types.str;
        default = [];
      };

      alter.scheduler = lib.mkOption {
        description = "Alternative scheduler (activate when power on), set null to disable";
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      alter.args = default.args;
    };
  };
in {
  den.schema.host = {
    includes = [
      den.policies.expose-scx-to-host
    ];
    imports = [
      moduleScx
    ];
  };

  den.policies.expose-scx-to-host = { host, ... }: den.lib.policy.resolve { scx = host.scx; };
}
