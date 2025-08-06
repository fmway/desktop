{ lib, ... }:  let
  inherit (lib.kdl) leaf node plain serialize; kv = leaf;
  bg = "#8A8A8A";
  fg = "#000000";
  green = "#AFFF00";
in serialize.node (plain "layout"
  (node "pane" { split_direction = "vertical"; }
    (node "pane" [])
  )

  (node "pane" { size = 1; borderless = true; }
    (node "plugin" {
      location = "https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm";
    }
      (kv "format_left" "{mode} {tabs}")
      (kv "format_right" "#[bg=${bg},fg=${fg}] #[fg=#000000,bg=${bg},bold]{swap_layout} #[bg=cyan,fg=${bg}] {datetime}#[bg=${fg},fg=cyan]")

      (kv "mode_locked" "#[fg=#FF00D9,bold] {name} ")
      (kv "mode_normal" "#[fg=${green},bold] {name} ")
      (kv "mode_resize" "#[fg=#D75F00,bold] {name} ")
      (kv "mode_default_to_mode" "resize")

      (kv "tab_normal" "#[bg=${bg},fg=${fg}] #[bg=${bg},fg=${fg},bold]{name} {sync_indicator}{fullscreen_indicator}{floating_indicator} #[bg=${fg},fg=${bg}]")
      (kv "tab_active" "#[bg=${green},fg=${fg}] #[bg=${green},fg=${fg},bold]{name} {sync_indicator}{fullscreen_indicator}{floating_indicator} #[bg=${fg},fg=${green}]")

      (kv "tab_sync_indicator" " ")
      (kv "tab_fullscreen_indicator" "□ ")
      (kv "tab_floating_indicator" "󰉈 ")

      (kv "datetime" "#[fg=black,bg=cyan,bold] {format} ")
      (kv "datetime_format" "%A, %H:%M")
      (kv "datetime_timezone" "Asia/Jakarta")
    )
  )
)
