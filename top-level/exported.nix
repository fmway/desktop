{
  # exclude in self.nixosModules.default
  excludes.nixos = [
    "inputs"
    "gnome"
    "nix-gc"
    "ape-loader"
    "chaotic"
  ];

  excludes.home-manager = [
    "sway"
    "hyprland"
    "nix-gc"
    "tmux-daemon"
  ];

  # excludes.darwin = [
  #   "nix-gc"
  # ];
}
