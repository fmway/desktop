{ lib, pkgs, ... }:
{
  services.displayManager.ly.settings = {
    save = true;
    allow_empty_password = false;
    animation = "doom";
    asterisk = "0";
    auth_fails = 10;

    brightness_down_cmd = "${lib.getExe pkgs.brightnessctl} -q s 1%-";
    brightness_down_key = "F5";
    brightness_up_cmd = "${lib.getExe pkgs.brightnessctl} -q s 1%+";
    brightness_up_key = "F6";

    vi_mode = true;
    vi_default_mode = "normal";
  };
}
