{ lib, den, ... }: let
  inherit (den.lib) policy;
  ipc = [ "noctalia-shell" "ipc" "call" ];
  inherit (lib.kdl) leaf plain node;
  inherit (lib.niri) spawn match spawn-at-startup sh mkSub bind include binds layer-rule;
in {
  fmx.desktops._.niri.includes = [
    (policy.when (ctx: ctx.hasAspect <fmx/desktops/shells/noctalia/v4>)
      (policy.include <fmx/desktops/niri/noctalia/v4>))
  ];

  fmx.desktops._.niri._.noctalia._.v4.includes = [
    <fmx/desktops/niri/noctalia/v4/config>
    ({ host, user, persistent, ... }: {
      persistence.${persistent.cacheDirectory}.users.${user.userName}.files = [
        ".config/niri/noctalia.kdl"
      ];
    })
  ];

  fmx.desktops._.niri._.noctalia._.v4._.config.niri-config = { pkgs, ... }: let
    sub = mkSub pkgs;
  in [
    (binds.append
      # fn section
      # (node "XF86AudioRaiseVolume" { allow-when-locked = true; }
      #   (spawn ipc "volume" "increase"))
      # (node "XF86AudioLowerVolume" { allow-when-locked = true; }
      #   (spawn ipc "volume" "decrease"))
      # (node "XF86AudioMute"        { allow-when-locked = true; }
      #   (spawn ipc "volume" "muteOutput"))
      # (node "XF86AudioMicMute"      { allow-when-locked = true; }
      #   (spawn ipc "volume" "muteInput"))

      (plain "XF86MonBrightnessUp"
        (spawn ipc "brightness" "increase"))
      (plain "XF86MonBrightnessDown"
        (spawn ipc "brightness" "decrease"))

      # noctalia features
      (plain "Ctrl+Alt+Delete"
        (spawn ipc "sessionMenu" "toggle"))
      (node "Mod+Shift+I" { hotkey-overlay-title = "Lock the screen (alt)"; }
        (spawn ipc "lockScreen" "lock"))
      (plain "Mod+Slash"
        (spawn ipc "launcher" "toggle"))
      (plain "Mod+Shift+C"
        (spawn ipc "launcher" "calculator"))
      (plain "Mod+Semicolon"
        (spawn ipc "launcher" "emoji"))
      (plain "Mod+V"
        (spawn ipc "launcher" "clipboard"))

      # submap for change background
      (sub "Mod+B" "Custom Binds"
        (bind "b" "Toggle Bar"
          (sh ipc "bar" "toggle"))
        (bind "c" "Change Wallpaper"
          (sh ipc "wallpaper" "toggle"))
        (bind "r" "Random Wallpaper"
          (sh ipc "wallpaper" "random"))
      )
    )

    (layer-rule
      (match { namespace = "^quickshell-wallpaper$"; })
      (match { namespace = "^quickshell-overview$"; })
      (match { namespace = "^swww-daemon$"; })
      (match { namespace = "^noctalia-overview*"; })
      (leaf "place-within-backdrop" true)
    )

    (spawn-at-startup "noctalia-shell")

    # already did in noctalia-shell
    # (spawn-at-startup
    #   "wl-paste" "--type" "image" "--watch" "cliphist" "store")
    # (spawn-at-startup
    #   "wl-paste" "--type" "text" "--watch" "cliphist" "store")

    (include { optional = true; } "./noctalia.kdl")
  ];
}
