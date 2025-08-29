{ mod, cmd, lib, pkgs, ... }: let
  dmenu_path = lib.getExe' pkgs.dmenu "dmenu_path";
  brightnessctl = lib.getExe pkgs.brightnessctl;
in with cmd; {
  binds = {
    "${mod}+Return" = exec "footclient";
    "${mod}+Shift+q" = "kill";
    "${mod}+d" = exec "fuzzel";
    "${mod}+Shift+d" = exec (pipe [
      dmenu_path
      "fuzzel --dmenu"
      "xargs swaymsg exec --"
    ]);

    "${mod}+i" = exec "delock --ignore-empty-password --show-failed-attempts";
    "${mod}+Shift+b" = toggle.border;

    # Moving around
  } // hjkl (a: a': let dir = lib.toLower a; in {
    # Move your focus around
    "${mod}+${a'}" = focus.${dir};
    # Or use $mod+[up|down|left|right]
    "${mod}+${a}" = focus.${dir};

    # Move the focused window with the same, but add Shift
    "${mod}+Shift+${a'}" = move.${dir};
    # Ditto, with arrow keys
    "${mod}+Shift+${a}" = move.${dir};
  }) // seq 1 10 (x: let i = toString (lib.mod x 10); in {
    # Switch to workspace
    "${mod}+${i}" = "workspace number ${toString x}";
    # Move focused container to workspace
    "${mod}+Shift+${i}" = "move container to workspace number ${toString x}";
  }) // {
    # Layout stuffs
    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    "${mod}+b" = split.h;
    "${mod}+v" = split.v;

    # Switch the current container between different layout styles
    "${mod}+s" = layout.stacking;
    "${mod}+w" = layout.tabbed;
    "${mod}+e" = layout."toggle split";

    # Make the current focus fullscreen
    "${mod}+f" = toggle.fullscreen;

    # Toggle the current focus between tiling and floating mode
    "${mod}+Shift+space" = toggle.floating;

    # Swap focus between the tiling area and the floating area
    "${mod}+space" = focus.mode_toggle;

    # Move focus to the parent container
    "${mod}+a" = focus.parent;

    # Scratchpad
    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    "${mod}+Shift+minus" = move.scratchpad;

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    "${mod}+minus" = show.scratchpad;

    # fn keys
    "XF86AudioRaiseVolume" = exec "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+";
    "XF86AudioLowerVolume" = exec "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-";
    "XF86AudioMute" = exec "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
    "XF86MonBrightnessUp" = exec brightnessctl "s +2%";
    "XF86MonBrightnessDown" = exec brightnessctl "s 2%-";

    # reload configuration
    "${mod}+Shift+r" = "reload";

    # Exit sway (logs you out of your Wayland session)
    "${mod}+Shift+e" =
      exec "swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
  };
}
