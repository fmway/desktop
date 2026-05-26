{ lib, ... }:
{
  den.schema.user.options = {
    email = lib.mkOption {
      description = "Email of the user";
      type = with lib.types; nullOr str;
      default = null;
    };
    sshKeys = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
    };
  };
}
