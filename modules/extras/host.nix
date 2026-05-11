{ lib, ... }:
{
  den.schema.host = { config, ... }:
  {
    options = {
      # TODO: multiple zram
      zram.size = lib.mkOption {
        description = "Your zram size";
        type = with lib.types; either str ints.unsigned;
        default = "ram / 2";
      };
      zram.priority = lib.mkOption {
        description = "Priority of the zram";
        type = lib.types.ints.unsigned;
        default = 100;
      };

      battery_limit = lib.mkOption {
        description = "Battery limit (use case: for auto shutdown)";
        type = with lib.types; addCheck ints.u8 (v: v > 0 && v < 100);
        default = 15;
      };

      timeZone = lib.mkOption {
        description = "Current timezone";
        type = with lib.types; nullOr str;
        default = null;
      };

      locale = lib.mkOption {
        description = "Locale device";
        type = lib.types.str;
        default = "en_US.UTF-8";
      };
      extraLocale = lib.mkOption {
        type = lib.types.str;
        default = config.locale;
      };

      configurationLimit = lib.mkOption {
        description = "(use case: for boot configurationLimit)";
        type = lib.types.ints.unsigned;
        default = 25;
      };
    };
  };
}
