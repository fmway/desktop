{ den, lib, ... }:
{
  fmx.boot._.plymouth.nixos = { ... }:
  {
    boot.plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };
}
