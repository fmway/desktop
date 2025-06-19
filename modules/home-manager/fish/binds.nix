{
  programs.fish.binds = {
    "alt-s".erase = true;
    "alt-s".operate = "preset";
    "alt-k".command = "fish_commandline_prepend doas";
  };
}
