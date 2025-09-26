{ config, lib, ... }:
{
  hardware.enableAllFirmware = lib.mkDefault true;
}
