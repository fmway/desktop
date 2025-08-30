{ config, superLib, ... }: let
  cfg = config.wayland.windowManager.sway;
in superLib.sway // {
  mod = cfg.config.modifier;
}
