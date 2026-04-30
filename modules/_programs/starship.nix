{ lib, ... }:
{
  starship.enable = lib.mkDefault true;
  starship.enableTransience = true;
  starship.settings.add_newline = false;
}
