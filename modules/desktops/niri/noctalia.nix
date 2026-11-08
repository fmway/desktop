{ den, lib, ... }: let
  inherit (den.lib) policy;
  inherit (lib.kdl) leaf plain node;
  inherit (lib.niri) match spawn-at-startup spawn spawn-sh binds layer-rule window-rule include mkSub sh bind;
  ipc.__functor = _: spawn "noctalia" "msg";
  ipc.sh = sh "noctalia" "msg";
in {
  fmx.desktops._.niri.includes = [
    (policy.when (ctx: ctx.hasAspect <fmx/desktops/shells/noctalia/v5>)
      (policy.include <fmx/desktops/niri/noctalia/v5>))
  ];

  fmx.desktops._.niri._.noctalia._.v5.includes = [
    <fmx/desktops/niri/noctalia/v5/config>
    ({ host, user, persistent, ... }: {
      persistence.${persistent.cacheDirectory}.users.${user.userName}.files = [
        ".config/niri/noctalia.kdl"
      ];
    })
  ];

  
  fmx.desktops._.niri._.noctalia._.v5._.config.niri-config = { pkgs, ... }: let
    sub = mkSub pkgs;
  in [
    (spawn-at-startup "noctalia" "--daemon")
    (include { optional = true; } "./noctalia.kdl")

    # Floating Noctalia settings window.
    (window-rule
      (match { app-id = "dev.noctalia.Noctalia"; })
      (leaf "open-floating" true)
      (plain "default-column-width"  (leaf "fixed" 1080))
      (plain "default-window-height" (leaf "fixed" 920))
    )

    (binds.append
      (plain "Mod+Slash"       (ipc "panel-toggle" "launcher"))
      (plain "Mod+P"           (ipc "panel-toggle" "control-center"))
      (plain "Mod+Alt+S"       (ipc "settings-toggle"))
      (plain "Alt+Tab"         (ipc "window-switcher" "hold"))
      (plain "Mod+S"           (ipc "screenshot-fullscreen"))
      (plain "Mod+Shift+S"     (ipc "annotate"))
      (plain "Mod+Shift+I"     (ipc "session" "lock"))
      (plain "Mod+Alt+I"       (ipc "session" "lock-and-suspend"))
      (plain "Mod+V"           (ipc "panel-toggle" "clipboard"))
      (plain "Ctrl+Alt+Delete" (ipc "panel-toggle" "session"))
      (plain "Mod+Semicolon"   (ipc "panel-toggle" "launcher" "/emo "))
      (plain "Mod+Shift+C"     (ipc "panel-toggle" "launcher" "/calc "))

      # Audio & Brightness
      # (plain "XF86AudioRaiseVolume"  (ipc "volume-up"))
      # (plain "XF86AudioLowerVolume"  (ipc "volume-down"))
      # (plain "XF86AudioMute"         (ipc "volume-mute"))
      (plain "XF86MonBrightnessUp"   (ipc "brightness-up"))
      (plain "XF86MonBrightnessDown" (ipc "brightness-down"))

      # submap for change background
      (sub "Mod+B" "Custom Binds"
        (bind "b" "Toggle Bar"
          (ipc.sh "bar-toggle"))
        (bind "c" "Change Wallpaper"
          (ipc.sh "panel-toggle" "wallpaper"))
        (bind "r" "Random Wallpaper"
          (ipc.sh "wallpaper-random"))
      )
    )

    # ======== Overview Wallpaper =============
    # Blurred overview wallpaper
    (layer-rule
      (match { namespace = "^noctalia-backdrop"; })
      (leaf "place-within-backdrop" true)
    )

    # Stationary wallpaper
    # (layer-rule
    #   (match { namespace = "^noctalia-wallpaper"; })
    #   (leaf "place-within-backdrop" true)
    # )
    #
    # (plain "layout"
    #   (leaf "background-color" "transparent")
    # )
    #
    # (plain "overview"
    #   (plain "workspace-shadow"
    #     (flag "off")
    #   )
    # )

    # Flat colored overview
    # (plain "overview"
    #   (leaf "backdrop-color" "#26233a")
    # )
    # ==================================

    # ======= Blur my shell =======
    /* Apps: blur them all without xray so it looks more realistic. */
    (window-rule
      (plain "background-effect"
        (leaf "blur" true)
        (leaf "xray" false)
      )
    )

    /*
      Noctalia
      Disable xray on all our surfaces so it looks more realistic.
      Noctalia publishes blur regions automatically when ext-background-effects is available.
    */
    (layer-rule
      (match { namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"; })
      (plain "background-effect"
        (leaf "xray" false)
        # (leaf "blur" false)
      )
    )

    /* Enable blur on noctalia's window switcher and disable xray. */
    (layer-rule
      (match { namespace = "noctalia-window-switcher"; })
      (plain "background-effect"
        (leaf "blur" true)
        (leaf "xray" false)
      )
    )

    /* You can also fine-tune the blur effect globally. */
    (plain "blur"
      (leaf "passes" 2)        # more passes = stronger blur (default: 3)
      (leaf "offset" 3.0)      # sample distance per pass (default: 3.0)
      (leaf "noise" 0.03)      # grain overlay (default: 0.02)
      (leaf "saturation" 1.0)  # color saturation boost (default: 1.5)
    )
    # =====================

    (plain "switch-events"
      (plain "lid-close" (ipc "session" "lock-and-suspend"))
    )
  ];
}
