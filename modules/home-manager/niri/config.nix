{ lib, pkgs, ... }: let
  inherit (lib.kdl) leaf plain node flag HJKL M seq;
  inherit (lib.niri) spawn spawn-sh window-rule proportion match spawn-at-startup sh sub bind;
  resize-state = [
    (proportion 0.33333)
    (proportion 0.5)
    (proportion 0.66667)
    (proportion 1.0)
  ];
  dmenu_path = lib.getExe' pkgs.dmenu "dmenu_path";
  fuzzel = lib.getExe pkgs.fuzzel;

  environment = {
    TERMINAL = lib.getExe' pkgs.foot "footclient";
    DISPLAY = ":0";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland,x11";
    MOZ_ENABLE_WAYLAND = 1;
    NIXOS_OZONE_WL = 1;
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
    SDL_VIDEODRIVER = "wayland";
  };

  dmenuan = pkgs.writeScript "dmenuan.sh" /* fish */ ''
    #!${lib.getExe pkgs.fish}
    set menu (${dmenu_path} | ${fuzzel} -d | xargs)
    
    if not [ -z "$menu" ]
      niri msg action spawn -- $menu &
      disown (jobs -lp)[1]
    end
  '';

  nodes.environment = map (k: let
    v = (if builtins.isString environment.${k} then x: x else builtins.toJSON) environment.${k};
  in leaf k v) (builtins.attrNames environment);
in [
  (flag "prefer-no-csd")
  (leaf "screenshot-path" "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png")
  (plain "input"
    (plain "keyboard"
      (plain "xkb"
        # For more information, see xkeyboard-config(7).
        (leaf "options" "grp:shifts_toggle, caps:none")
      )
    )

    (plain "touchpad"
      (flag "tap")
      # (flag "dwt")
      # (flag "dwtp")
      (flag "natural-scroll")
      # (leaf "accel-speed" 0.2)
      # (leaf "accel-profile" "flat")
      # (leaf "tap-button-map" "left-middle-right")
    )

    # (plain "mouse"
    #   (flag "off")
    #   (flag "natural-scroll")
    #   (leaf "accel-speed" 0.2)
    #   (leaf "accel-profile" "flat")
    #   (leaf "scroll-method" "no-scroll")
    # )

    # (plain "trackpoint"
    #   (flag "off")
    #   (flag "natural-scroll")
    #   (leaf "accel-speed" 0.2)
    #   (leaf "accel-profile" "flat")
    #   (leaf "scroll-method" "on-button-down")
    #   (leaf "scroll-button" 273)
    #   (flag "middle-emulation")
    # )

    # (plain "touch"
    #   # Set the name of the output (see below) which touch input will map to.
    #   # If this is unset or the output doesn't exist, touch input maps to one of the
    #   # existing outputs.
    #   (leaf "map-to-output" "eDP-1")
    # )

    # (leaf "focus-follows-mouse" /*{ max-scroll-amount = "50%"; }*/)

    # (flag "warp-mouse-to-focus")

    # By default, niri will take over the power button to make it sleep
    # instead of power off.
    # Uncomment this if you would like to configure the power button elsewhere
    # (i.e. logind.conf).
    # (flag "disable-power-key-handling")
     
    # custom mod
    (leaf "mod-key" "Super") # in primary wm
    (leaf "mod-key-nested" "Alt") # in nested
  )

  (node "output" "eDP-1"
    (leaf "mode" "1920x1080@120.030")
    (leaf "scale" 1)
    # Transform allows to rotate the output counter-clockwise, valid values are:
    # normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
    (leaf "transform" "normal")
    (leaf "position" { x = 1280; y = 0; })
  )

  (plain "cursor"
    # Change the theme and size of the cursor as well as set the
    # `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
    (leaf "xcursor-theme" "default")
    (leaf "xcursor-size" 40)
    # (flag "hide-when-typing")
    (leaf "hide-after-inactive-ms" 30000)
  )

  (plain "gestures"
    (plain "hot-corners"
      (flag "off") # disable the hot corners
    )
  )

  (plain "layout"
    (leaf "gaps" 8)
    (leaf "background-color" "#00000000")

    (leaf "center-focused-column" "never")

    (plain "preset-column-widths" resize-state)
    (plain "preset-window-heights" resize-state)
    (plain "default-column-width" (proportion 0.5))
    # (plain "default-window-height" (proportion 0.5))

    (plain "focus-ring"
      # (flag "off")
      (leaf "width" 3)

      (leaf "active-color" "#7fc8ff")
      (leaf "inactive-color" "#505050")

      # (leaf "active-gradient" { from = "#80c8ff"; to = "#bbddff"; angle = 45; })
      # (leaf "inactive-gradient" { from = "#505050"; to = "#808080"; angle = 45; relative-to = "workspace-view"; })
    )

    # You can also add a border. It's similar to the focus ring, but always visible.
    (plain "border"
      (flag "off")
      # (plain "width" 4)
      # (plain "active-color" "#ffc87f")
      # (plain "inactive-color" "#505050")
      #
      # (plain "urgent-color" "#9b0000")

      # (leaf "active-gradient" { from = "#ffbb66"; to = "#ffc880"; angle = 45; relative-to = "workspace-view"; })
      # (leaf "inactive-gradient" { from = "#505050"; to = "#808080"; angle = 45; relative-to = "workspace-view"; })
    )

    # You can enable drop shadows for windows.
    (plain "shadow"
      (flag "on")
      (leaf "draw-behind-window" true)

      # Softness controls the shadow blur radius.
      (leaf "softness" 30)
      # Spread expands the shadow.
      (leaf "spread" 5)
      # Offset moves the shadow relative to the window.
      (leaf "offset" { x = 0; y = 5; })
      # You can also change the shadow color and opacity.
      (leaf "color" "#0007")
    )

    # (plain "struts"
    #   (leaf "left" 64)
    #   (leaf "right" 64)
    #   (leaf "top" 64)
    #   (leaf "bottom" 64)
    # )
  )

  # (plain "animations"
  #   (flag "off")
  #   (leaf "slowdown" 3.0)
  # )

  (plain "environment" nodes.environment)

  # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
  (window-rule
    (match { app-id = ''^org\.wezfurlong\.wezterm$''; })
    (plain "default-column-width")
  )

  (window-rule
    (match {
      app-id = "steam";
      title = ''^notificationtoasts_\d+_desktop$'';
    })
    (leaf "default-floating-position" { x = 10; y = 10; relative-to = "bottom-right"; })
  )

  # floating section
  (window-rule
    (match { app-id = "firefox$"; title = "^Picture-in-Picture$"; })
    (match { app-id = "^xdm-app$"; })
    (match { app-id = "control.exe"; })
    (match { app-id = "wineboot.exe"; })
    (match { app-id = "pop-up"; })
    (match { app-id = "dialog"; })
    (match { app-id = "task_dialog"; })
    (match { app-id = "bubble"; })
    (match { app-id = "menu"; })
    (match { app-id = "connman-gtk"; })
    (match { app-id = ''^org\.telegram\..+''; })
    (match { app-id = "org.kde.kdeconnect.app"; })
    (match { app-id = "mpv"; })
    (match { app-id = "pavucontrol"; })
    (match { app-id = "floating-window"; })
    (match { app-id = "scrcpy"; })
    (match { app-id = "nz.co.mega."; })
    (leaf "exclude" { app-id = "nz.co.mega."; title = "Transfer manager"; })
    (leaf "open-floating" true)
  )

  # fullscreen section
  (window-rule
    (match { app-id = "fullscreen-window"; })
    (match { title  = "fullscreen-window"; })
    (leaf "open-fullscreen" true)
  )
  
  # Example: block out two password managers from screen capture.
  # (This example rule is commented out with a "/-" in front.)
  (window-rule
    (match { app-id = ''^org\.keepassxc\.KeePassXC$''; })
    (match { app-id = ''^org\.gnome\.World\.Secrets$''; })

    (leaf "block-out-from" "screen-capture")
    # Use this instead if you want them visible on third-party screenshot tools.
    # (leaf "block-out-from" "screencast")
  )

  # rounded corner for all windows
  (window-rule
    (leaf "geometry-corner-radius" 20)
    (leaf "clip-to-geometry" true)
  )

  # (window-rule
  #   (match { app-id =  })
  # )

  (plain "layer-rule"
    (match { namespace = "^quickshell-wallpaper$"; })
    (match { namespace = "^quickshell-overview$"; })
    (match { namespace = "^swww-daemon$"; })
    (leaf "place-within-backdrop" true)
  )

  # Keybindings section
  (plain "binds"
    (plain "Mod+Slash"
      (spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"))
    (plain "Mod+Shift+Slash" (flag "show-hotkey-overlay"))
    (node "Mod+Return"       { hotkey-overlay-title = "Open a Terminal: footclient"; }
      (spawn
        (lib.getExe' pkgs.foot "footclient") "-a" "foot"))
    (node "Mod+Shift+Return" { hotkey-overlay-title = "Open a Terminal: foot"; }
      (spawn (lib.getExe pkgs.foot)))
    (node "Mod+D"            { hotkey-overlay-title = "Run an Application:fuzzel"; } 
      (spawn fuzzel))
    (plain "Mod+Shift+D"
      (spawn "${dmenuan}"))
    (node "Mod+I"            { hotkey-overlay-title = "Lock the screen"; }
      (spawn (lib.getExe pkgs.scripts.delock)))
    (node "Mod+Shift+I"      { hotkey-overlay-title = "Lock the screen (alt)"; }
      (spawn "noctalia-shell" "ipc" "call" "lockScreen" "lock"))

    (plain "Mod+Shift+Q" (flag "close-window"))

    (plain "Mod+Shift+Comma"  (flag "consume-or-expel-window-left"))
    (plain "Mod+Shift+Period" (flag "consume-or-expel-window-right"))

    (plain "Mod+R"       (flag "switch-preset-column-width"))
    (plain "Mod+Shift+R" (flag "switch-preset-window-height"))
    (plain "Mod+Ctrl+R"  (flag "reset-window-height"))
    (plain "Mod+F"       (flag "maximize-column"))
    (plain "Mod+Shift+F" (flag "fullscreen-window"))

    # (plain "Mod+C"       (spawn "cliphist-fuzzel-img"))
    (plain "Mod+V"        (spawn "noctalia-shell" "ipc" "call" "launcher" "clipboard"))
    (plain "Mod+C"        (flag "center-column"))
    (plain "Mod+Shift+C"  (flag "center-visible-columns"))

    (plain "Mod+Minus" (leaf "set-column-width" "-10%"))
    (plain "Mod+Equal" (leaf "set-column-width" "+10%"))

    # Finer height adjustments when in column with other windows.
    (plain "Mod+Shift+Minus" (leaf "set-window-height" "-10%"))
    (plain "Mod+Shift+Equal" (leaf "set-window-height" "+10%"))

    # Move the focused window between the floating and the tiling layout.
    (plain "Mod+Shift+Space" (flag "toggle-window-floating"))
    (plain "Mod+Space"       (flag "switch-focus-between-floating-and-tiling"))

    # Toggle tabbed column display mode.
    # Windows in this column will appear as vertical tabs,
    # rather than stacked on top of each other.
    (plain "Mod+W" (flag "toggle-column-tabbed-display"))

    (plain "Print"      (flag "screenshot"))
    (plain "Ctrl+Print" (flag "screenshot-screen"))
    (plain "Alt+Print"  (flag "screenshot-window"))

    (node "Mod+Escape" { allow-inhibiting = false; }
      (flag "toggle-keyboard-shortcuts-inhibit"))

    # The quit action will show a confirmation dialog to avoid accidental exits.
    (plain "Mod+Shift+E"     (flag "quit"))
    (plain "Ctrl+Alt+Delete" (spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle"))

    # Powers off the monitors. To turn them back on, do any input like
    # moving the mouse or pressing any other key.
    (plain "Mod+Shift+P" (flag "power-off-monitors"))

    # fn section
    # (node "XF86AudioRaiseVolume" { allow-when-locked = true; }
    #   (spawn "noctalia-shell" "ipc" "call" "volume" "increase"))
    # (node "XF86AudioLowerVolume" { allow-when-locked = true; }
    #   (spawn "noctalia-shell" "ipc" "call" "volume" "decrease"))
    # (node "XF86AudioMute"        { allow-when-locked = true; }
    #   (spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"))
    # (node "XF86AudioMicMute"      { allow-when-locked = true; }
    #   (spawn "noctalia-shell" "ipc" "call" "volume" "muteInput"))
    (node "XF86AudioRaiseVolume" { allow-when-locked = true; }
      (spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"))
    (node "XF86AudioLowerVolume" { allow-when-locked = true; }
      (spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"))
    (node "XF86AudioMute"        { allow-when-locked = true; }
      (spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"))
    (node "XF86AudioMicMute"      { allow-when-locked = true; }
      (spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"))
    (plain "XF86MonBrightnessUp"
      (spawn "noctalia-shell" "ipc" "call" "brightness" "increase"))
    (plain "XF86MonBrightnessDown"
      (spawn "noctalia-shell" "ipc" "call" "brightness" "decrease"))
    # (plain "XF86MonBrightnessUp"
    #   (spawn (lib.getExe pkgs.brightnessctl) "s" "+2%"))
    # (plain "XF86MonBrightnessDown"
    #   (spawn (lib.getExe pkgs.brightnessctl) "s" "2%-"))
    # (plain "XF86MonBrightnessUp"
    #   (spawn "brightness" "up"))
    # (plain "XF86MonBrightnessDown"
    #   (spawn "brightness" "down"))

    (node "Mod+O" { repeat = false; } (flag "toggle-overview"))
    (HJKL (k: let
      dir  = lib.toLower k; isJk = k == M.J || k == M.K;
      move = flag (if isJk then "move-window-${dir}-or-to-workspace-${dir}" else "move-column-${dir}");
      focus= flag (if isJk then "focus-window-or-workspace-${dir}" else "focus-column-${dir}");
      additional = { "${M.H}" = "Mod+Comma"; "${M.L}" = "Mod+Period"; };
    in [
      (plain "Mod+${k}"            focus)
      (plain "Mod+${M.${k}}"       focus)
      (plain "Mod+Shift+${k}"      move)
      (plain "Mod+Shift+${M.${k}}" move)
    ] ++ lib.optionals (!isJk) [
      (plain additional.${k}       focus)
    ]))
    (seq 1 10 (i: let i' = toString (lib.mod i 10); in [
      (plain "Mod+${i'}"       (leaf "focus-workspace" i))
      (plain "Mod+Shift+${i'}" (leaf "move-window-to-workspace" i))
      (plain "Mod+Ctrl+${i'}"  (leaf "move-column-to-workspace" i))
    ]))
    (node "Mod+WheelScrollDown"      { cooldown-ms = 150; } (flag "focus-workspace-down"))
    (node "Mod+WheelScrollUp"        { cooldown-ms = 150; } (flag "focus-workspace-up"))
    (node "Mod+Ctrl+WheelScrollDown" { cooldown-ms = 150; } (flag "move-column-to-workspace-down"))
    (node "Mod+Ctrl+WheelScrollUp"   { cooldown-ms = 150; } (flag "move-column-to-workspace-up"))
  )

  (plain "hotkey-overlay"
    (flag "skip-at-startup")
  )

  (plain "overview"
    (plain "workspace-shadow"
      (flag "off")
    )
  )

  (plain "debug"
    (leaf "honor-xdg-activation-with-invalid-serial")
  )

  # (spawn-at-startup (lib.getExe pkgs.xwayland-satellite))
  # (spawn-at-startup (lib.getExe pkgs.mako))
  # (spawn-at-startup
  #   "wl-clip-persist" "--clipboard" "regular")
  # (spawn-at-startup
  #   "wl-paste" "--type" "image" "--watch"
  #     "clipman" "store" "--no-persist" "--max-items" "500")
  # (spawn-at-startup
  #   "wl-paste" "--type" "text" "--watch"
  #     "clipman" "store" "--no-persist" "--max-items" "500")
  # (spawn-at-startup "noctalia-shell")
  # (spawn-at-startup "foot" "--server")

  # already did in noctalia-shell
  # (spawn-at-startup
  #   "wl-paste" "--type" "image" "--watch" "cliphist" "store")
  # (spawn-at-startup
  #   "wl-paste" "--type" "text" "--watch" "cliphist" "store")
  (spawn-at-startup
    "swayidle"
      "timeout" "300"
        "swaylock -f -c 000000"
      "timeout" "600"
        "niri msg output off"
      "timeout" "1000"
        "systemctl suspend"
      "resume"
        "niri msg output on"
      "before-sleep"
        "swaylock -f -c 000000")
  (spawn-at-startup "wayland-pipewire-idle-inhibit")
  # (spawn-at-startup "uwsm" "finalize")
  (spawn-at-startup "systemctl" "--user" "start" "hyprpolkitagent")
  # (spawn-at-startup (lib.getExe' pkgs.dbus "dbus-update-activation-environment") "--systemd" "DISPLAY" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" "XDG_SESSION_TYPE" "NIXOS_Ozone_WL")
]
