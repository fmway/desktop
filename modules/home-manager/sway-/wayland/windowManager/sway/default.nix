{ pkgs, uncommon, superLib, lib, config, ... }: let
  cfg = config.wayland.windowManager.sway;
in superLib.sway.parse uncommon // {
  wrapperFeatures.gtk = true;
  # swayfx problems
  checkConfig = false;

  package = lib.mkDefault pkgs.swayfx;

  extraConfig = lib.mkMerge [
    ''
      xwayland enable
      font pango:Noto Sans 1 
      gaps inner 0
      gaps outer 0
      default_border pixel 4
    ''
    (lib.mkIf (cfg.package.pname == "swayfx") ''
      # swayfx feature
      corner_radius 8
      blur enable
      blur_xray disable
      blur_passes 2
      blur_radius 4
      shadows enable
      shadows_on_csd disable
      shadow_blur_radius 16
      shadow_color #0000007F

      default_dim_inactive 0.0
      dim_inactive_colors.unfocused #000000FF
      dim_inactive_colors.urgent #900000FF
    '')
  ];
}
