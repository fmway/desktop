{ menu, ... }:
{
  font = "JetBrainsMono Nerd Font 12";
  background = "#282828d0";
  color = "#fbf1c7";
  border = "#7fc8ff";
  separator = " ➜ ";
  border_width = 2.3;
  corner_r = 20;
  padding = 15; # Defaults to corner_r
  rows_per_column = 5; # No limit by default
  column_padding = 25; # Defaults to padding

  # Anchor and margin
  anchor = "bottom-right"; # One of center, left, right, top, bottom, bottom-left, top-left, etc.
  # Only relevant when anchor is not center
  margin_right = 4;
  margin_bottom = 4;
  # margin_left = 0;
  # margin_top = 0;

  # Permits key bindings that conflict with compositor key bindings.
  # Default is `false`.
  inhibit_compositor_keyboard_shortcuts = true;

  # Try to guess the correct keyboard layout to use. Default is `false`.
  auto_kbd_layout = true;
  inherit menu;
}
