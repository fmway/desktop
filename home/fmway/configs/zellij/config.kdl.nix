{ lib, ... }: let
  inherit (lib.kdl) flag leaf node plain serialize m hjkl seq; kv = leaf;
  inherit (lib.zellij) bind unbind Resize SwitchToMode MoveFocus NewPane SwitchToNormal;
in serialize.nodes [
  (node "keybinds" {
    # clear-defaults = true; # If you'd like to override the default keybindings completely
  }
    # (plain "normal"
    #   # uncomment this and adjust key if using copy_on_select=false
    #   # (bind "Alt+C" (s "Copy"))
    # )
    (plain "locked"
      (bind "Ctrl g" SwitchToNormal)
    )
    (plain "resize"
      (bind "Ctrl n"      SwitchToNormal)
      (hjkl (k: [
        (bind [k m.${k}]           (Resize "Increase ${k}"))
        (bind (lib.toUpper m.${k}) (Resize "Decrease ${k}"))
      ]))
      (bind ["=" "+"]     (Resize "Increase"))
      (bind "-"           (Resize "Decrease"))
    )

    (plain "pane"
      (bind ["Ctrl p"]    SwitchToNormal)
      (hjkl (k:
        bind [k m.${k}] (MoveFocus k)
      ))
      (bind "p" (flag "SwitchFocus"))
      (bind "n" NewPane SwitchToNormal)
      (bind "d" (NewPane "Down") SwitchToNormal)
      (bind "r" (NewPane "Right") SwitchToNormal)
      (bind "x" (flag "CloseFocus") SwitchToNormal)
      (bind "f" (flag "ToggleFocusFullscreen") SwitchToNormal)
      (bind "z" (flag "TogglePaneFrames") SwitchToNormal)
      (bind "w" (flag "ToggleFloatingPanes") SwitchToNormal)
      (bind "e" (flag "TogglePaneEmbedOrFloating") SwitchToNormal)
      (bind "c" (SwitchToMode "RenamePane") (kv "PaneNameInput" 0))
    )
    (plain "move"
      (bind "Ctrl h"      SwitchToNormal)
      (bind ["n" "Tab"]   (flag "MovePane"))
      (bind "p"           (flag "MovePaneBackwards"))
      (hjkl (k:
        bind [k m.${k}]   (kv   "MovePane" k)
      ))
    )
    (plain "tab"
      (bind "Ctrl t"  SwitchToNormal)
      (bind "n" (flag "NewTab")              SwitchToNormal)
      (bind "x" (flag "CloseTab")            SwitchToNormal)
      (bind "s" (flag "ToggleActiveSyncTab") SwitchToNormal)
      (bind "b" (flag "BreakPane")           SwitchToNormal)
      (bind "]" (flag "BreakPaneRight")      SwitchToNormal)
      (bind "[" (flag "BreakPaneLeft")       SwitchToNormal)
      (seq 1 9 (i:
        bind "${toString i}" (kv "GoToTab" i) SwitchToNormal
      ))
      (bind "Tab" (flag "ToggleTab"))
    )

    (plain "scroll"
      (bind "Ctrl s" SwitchToNormal)
      (bind "e" (flag "EditScrollback") SwitchToNormal)
      (bind "s" (SwitchToMode "EnterSearch") (kv "SearchInput" 0))
      (bind "Ctrl c" (flag "ScrollToBottom") SwitchToNormal)
      (bind ["j" "Down"] (flag "ScrollDown"))
      (bind ["k" "Up"]   (flag "ScrollUp"))
      (bind ["Ctrl f" "PageDown" "Right" "l"] (flag "PageScrollDown"))
      (bind ["Ctrl b" "PageUp" "Left" "h"] (flag "PageScrollUp"))
      (bind "d" (flag "HalfPageScrollDown"))
      (bind "u" (flag "HalfPageScrollUp"))
    )

    (plain "search"
      (bind "Ctrl s" SwitchToNormal)
      (bind "Ctrl c" (flag "ScrollToBottom") SwitchToNormal)
      (bind ["j" "Down"] (flag "ScrollDown"))
      (bind ["k" "Up"]   (flag "ScrollUp"))
      (bind ["Ctrl f" "PageDown" "Right" "l"] (flag "PageScrollDown"))
      (bind ["Ctrl b" "PageUp" "Left" "h"] (flag "PageScrollUp"))
      (bind "d" (flag "HalfPageScrollDown"))
      (bind "u" (flag "HalfPageScrollUp"))
      (bind "n" (kv "Search" "down"))
      (bind "p" (kv "Search" "up"))
      (bind "c" (kv "SearchToggleOption" "CaseSensitivity"))
      (bind "w" (kv "SearchToggleOption" "Wrap"))
      (bind "o" (kv "SearchToggleOption" "WholeWord"))
    )

    (plain "entersearch"
      (bind ["Ctrl c" "Esc"] (SwitchToMode "Scroll"))
      (bind "Enter" (SwitchToMode "Search"))
    )

    (plain "renametab"
      (bind "Ctrl c" SwitchToNormal)
      (bind "Esc" (flag "UndoRenameTab") (SwitchToMode "Tab"))
    )

    (plain "renamepane"
      (bind "Ctrl c" SwitchToNormal)
      (bind "Esc" (flag "UndoRenamePane") (SwitchToMode "Pane"))
    )

    (plain "session"
      (bind "Ctrl o" SwitchToNormal)
      (bind "Ctrl s" (SwitchToMode "Scroll"))
      (bind "d" (flag "Detach"))
      (bind "w"
        (node "LaunchOrFocusPlugin" "session-manager"
          (kv "floating" true)
          (kv "move_to_focused_tab" true)
        )
        SwitchToNormal
      )
    )

    (plain "tmux"
      (bind "[" (kv "SwitchToMode" "Scroll"))
      (bind "Ctrl b" (kv "Write" 2) SwitchToNormal)
      (bind ["\"" "-"] (NewPane "Down") SwitchToNormal)
      (bind ["%" "|"] (NewPane "Right") SwitchToNormal)
      (bind "z" (flag "ToggleFocusFullscreen") SwitchToNormal)
      (bind "c" (flag "NewTab") SwitchToNormal)
      (bind "," (SwitchToMode "RenameTab"))
      # (bind "e"
      #   (node "Run" "nvim"
      #     (kv "cwd" "${config.home.homeDirectory}/.config/zellij")
      #   )
      #   (flag "TogglePaneEmbedOrFloating")
      #   SwitchToNormal
      # )
      (bind "p" (flag "GoToPreviousTab") SwitchToNormal)
      (bind "n" (flag "GoToNextTab") SwitchToNormal)
      (hjkl (k:
        bind [ k m.${k} ] (MoveFocus k) SwitchToNormal
      ))
      (bind "o" (flag "FocusNextPane"))
      (bind "d" (flag "Detach"))
      (bind "Space" (flag "NextSwapLayout") SwitchToNormal)
      (bind "x" (flag "CloseFocus") SwitchToNormal)
      (bind "r" (SwitchToMode "Resize"))
      (bind "P" (SwitchToMode "Pane"))
      (bind "L" (SwitchToMode "Locked"))
      (bind "s" (SwitchToMode "Session"))
      (bind "t" (SwitchToMode "Tab"))
      (bind "m" (SwitchToMode "Move"))
      (bind "f" (flag "ToggleFloatingPanes"))
      (bind "F" (flag "TogglePaneEmbedOrFloating"))
      (bind ["Alt =" "Alt +"] (kv "Resize" "Increase"))
      (bind "Alt -" (kv "Resize" "Decrease"))
      (bind "Alt [" (flag "PreviousSwapLayout"))
      (bind "Alt ]" (flag "NextSwapLayout"))
      (bind "d" (flag "Detach"))
    )

    (node "shared_except" "locked"
      # (bind "Ctrl g" (SwitchToMode "Locked"))
      # (bind "Ctrl q" (flag "Quit"))
      (bind "Alt n" NewPane)
      # (bind "Alt i" (kv "MoveTab" "Left"))
      # (bind "Alt o" (kv "MoveTab" "Right"))
      # (hjkl (x:
      #   bind [ "Alt ${x}" "Alt ${m.${x}}" ] (if x == m.h || x == m.l then kv "MoveFocusOrTab" x else MoveFocus x)
      # ))
      # (bind ["Alt =" "Alt +"] (kv "Resize" "Increase"))
      # (bind "Alt -" (kv "Resize" "Decrease"))
      # (bind "Alt [" (flag "PreviousSwapLayout"))
      # (bind "Alt ]" (flag "NextSwapLayout"))
      (unbind "Alt i")
      (unbind "Alt o")
      (unbind "Alt h")
      (unbind "Alt j")
      (unbind "Alt k")
      (unbind "Alt l")
      (unbind "Alt Left")
      (unbind "Alt Right")
      (unbind "Alt Up")
      (unbind "Alt Down")
      (unbind "Alt =")
      (unbind "Alt +")
      (unbind "Alt -")
      (unbind "Ctrl g")
      (unbind "Alt [")
      (unbind "Alt ]")
    )

    (node "shared_except" ["normal" "locked"]
      (bind ["Enter" "Esc"] SwitchToNormal)
    )

    (node "shared_except" ["pane" "locked"]
      # (bind "Ctrl p" (SwitchToMode "Pane"))
      (unbind "Ctrl p")
    )

    (node "shared_except" ["resize" "locked"]
      # (bind "Ctrl n" (SwitchToMode "Resize"))
      (unbind "Ctrl n")
    )

    (node "shared_except" ["scroll" "locked"]
      # (bind "Ctrl s" (SwitchToMode "Scroll"))
      (unbind "Ctrl s")
    )

    (node "shared_except" ["session" "locked"]
       # (bind "Ctrl o" (SwitchToMode "Session"))
      (unbind "Ctrl o")
    )

    (node "shared_except" ["tab" "locked"]
      # (bind "Ctrl t" (SwitchToMode "Tab"))
      (unbind "Ctrl t")
    )

    (node "shared_except" ["move" "locked"]
      # (bind "Ctrl h" (SwitchToMode ))
      (unbind "Ctrl h")
    )

    (node "shared_except" ["tmux" "locked"]
      (bind "Ctrl b" (SwitchToMode "Tmux"))
    )
  )

  (plain "plugins"
    (node "tab-bar" { location = "zellij:tab-bar"; })
    (node "status-bar" { location = "zellij:status-bar"; })
    (node "strider" { location = "zellij:strider"; })
    (node "compact-bar" { location = "zellij:compact-bar"; })
    (node "session-manager" { location = "zellij:session-manager"; })
    (node "welcome-screen" { location = "zellij:session-manager"; }
      (kv "welcome_screen" false)
    )
    (node "filepicker" { location = "zellij:strider"; }
      (kv "cwd" "/")
    )
  )

  # Choose what to do when zellij receives SIGTERM, SIGINT, SIGQUIT or SIGHUP
  # eg. when terminal window with an active zellij session is closed
  # (kv "on_force_close" "quit") # : detach (default), quit

  # Send a request for a simplified ui (without arrow fonts) to plugins
  # (kv "simplified_ui" true) # default: false

  # Choose the path to the default shell that zellij will use for opening new panes
  # (kv "default_shell" "fish") # default: "$SHELL"

  # Choose the path to override cwd that zellij will use for opening new panes
  # (kv "default_cwd" "")

  # Toggle between having pane frames around the panes
  # (kv "pane_frames" true) # default: true

  # Toggle between having Zellij layout panes according to a predefined set of layouts whenever possible
  (kv "auto_layout" true) # default: true

  # Whether sessions should be serialized to the cache folder (including their tabs/panes, cwds and running commands) so that they can later be resurrected
  (kv "session_serialization" false) # default: true

  # Whether pane viewports are serialized along with the session
  # (kv "serialize_pane_viewport" true) # default: false

  # Scrollback lines to serialize along with the pane viewport when serializing sessions,
  # 0 is defaults to the scrollback size. If this number is higher than the scrollback size,
  # it will be also default to the scrollback size. This doas nothing if `serialize_pane_viewport`
  # is not true.
  # (kv "scrollback_lines_to_serialize" 1000)

  # Define color themes for Zellij
  # For more examples, see: https://github.com/zellij-org/zellij/tree/main/example/themes
  # Once these themes are defined, one of them should to be selected in the "theme" section of this file
  # (plain "themes"
  #   (plain "dracula"
  #     (kv "fg"      248 248 242)
  #     (kv "bg"      40 42 54)
  #     (kv "red"     255 85 85)
  #     (kv "green"   80 250 123)
  #     (kv "yellow"  241 250 140)
  #     (kv "blue"    98 114 164)
  #     (kv "magenta" 255 121 198)
  #     (kv "orange"  255 184 108)
  #     (kv "cyan"    139 233 253)
  #     (kv "black"   0 0 0)
  #     (kv "white"   255 255 255)
  #   )
  # )

  # Choose the theme that is specified in the themes section. default: default
  (kv "theme" "catppuccin-macchiato")

  # The name of the default layout to load startup
  (kv "default_layout" "fmlayout") # default: default

  # Choose the mode that zellij uses when starting up.
  # (kv "default_mode" "locked") # default: normal

  # Toggle enabling the mouse mode.
  # On certain configurations, or terminals this could
  # potentially interfere with copying text.
  (kv "mouse_mode" true) # default: true

  # Configure the scrollback buffer size
  # This is the number of lines zellij stores for each pane in the scrollback
  # buffer, Excess number of lines are discarded in a FIFO fashion.
  # Valid values: positive integers
  # (kv "scroll_buffer_size" 10000) # default: 10000

  # Provide a command to execute when copying text. The text will be piped to
  # the stdin of the program to perform the copy. This can be used with
  # terminal emulators which do not support the OSC 52 ANSI control sequence
  # that will be used by default if this option is not set.

  # (kv "copy_command" "xclip -selection clipboard") # x11
  (kv "copy_command" "wl-copy") # wayland
  # (kv "copy_command" "pbcopy") # osx

  # Choose the destination for copied text
  # Allow using the primary selection buffer (on x11/wayland) instead of the system clipboard.
  # Does not apply when using copy_command
  # (kv "copy_clipboard" "primary") # default: system

  # Enable or disable automatic copy (and clear) of selection when releasing mouse
  # (kv "copy_on_select" false) # default: true

  # Path to the default editor to use to edit pane scrollbuffer
  # (kv "scrollback_editor" "/usr/bin/vim") # default: $EDITOR or $VISUAL

  # When attaching to an existing session with other users,
  # should the session be mirrored (true)
  # or should each user have their own cursor (false)
  # (kv "mirror_session" true) # default: false

  # The folder in which Zellij will look for layouts
  # (kv "layout_dir" "/path/to/my/layout_dir")

  # The folder in which Zellij will look for themes
  # (kv "theme_dir" "/path/to/my/theme_dir")

  # Enable or disable the rendering of styled and colored underlines (undercurl)
  # May need to be disabled of certain unsupported terminals
  # (kv "styled_underlines" false) # default: true

  # Enable or disable writing of session metadata to disk (if disabled, each other sessions might not know
  # metadata info on this session)

  # (kv "disable_session_metadata" true) # default: false
]
