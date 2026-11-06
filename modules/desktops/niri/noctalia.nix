{ den, lib, ... }: let
  inherit (den.lib) policy;
  inherit (lib.kdl) leaf plain;
  inherit (lib.niri) match spawn-at-startup spawn-sh binds layer-rule window-rule include;
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

  
  fmx.desktops._.niri._.noctalia._.v5._.config.niri-config = { pkgs, ... }:
  [
    (spawn-at-startup "noctalia")
    (include { optional = true; } "./noctalia.kdl")

    # Floating Noctalia settings window.
    (window-rule
      (match { app-id = "dev.noctalia.Noctalia"; })
      (leaf "open-floating" true)
      (plain "default-column-width"  (leaf "fixed" 1080))
      (plain "default-window-height" (leaf "fixed" 920))
    )

    (binds.append
      (plain "Mod+Slash"       (spawn-sh "noctalia msg panel-toggle launcher"))
      (plain "Mod+S"           (spawn-sh "noctalia msg panel-toggle control-center"))
      (plain "Mod+Shift+S"     (spawn-sh "noctalia msg settings-toggle"))
      (plain "Alt+Tab"         (spawn-sh "noctalia msg window-switcher hold"))
      # Niri has a built-in window switcher you might want to try it to see which one you prefer.

      # Audio & Brightness
      # (plain "XF86AudioRaiseVolume"  (spawn-sh "noctalia msg volume-up"))
      # (plain "XF86AudioLowerVolume"  (spawn-sh "noctalia msg volume-down"))
      # (plain "XF86AudioMute"         (spawn-sh "noctalia msg volume-mute"))
      (plain "XF86MonBrightnessUp"   (spawn-sh "noctalia msg brightness-up"))
      (plain "XF86MonBrightnessDown" (spawn-sh "noctalia msg brightness-down"))
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
  ];
}
