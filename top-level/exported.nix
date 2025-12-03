{
  # exclude in self.nixosModules.default
  excludes.nixos = [
    "inputs"
    "gnome"
    "nix-gc"
    "ape-loader"
  ];

  excludes.home-manager = [
    "sway"
    "hyprland"
    "nix-gc"
  ];

  # excludes.darwin = [
  #   "nix-gc"
  # ];
}
