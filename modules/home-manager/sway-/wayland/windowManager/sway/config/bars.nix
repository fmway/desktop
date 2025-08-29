{ pkgs, config, lib, ... }: let
  i3status-rust = lib.getExe config.programs.i3status-rust.package;
in lib.mkIf (
  # deps
  config.programs.i3status-rust.enable &&
  config.programs.i3status-rust.bars ? sway
) [
  {
    position = "top";
    fonts.names = [ "Noto Sans" ];
    fonts.size = 10.0;

    statusCommand = "${i3status-rust} ~/.config/i3status-rust/config-sway.toml";
  }
]
