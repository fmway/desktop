{
  # exclude in self.nixosModules.default
  excludes.nixos = [
    "inputs"
    "gnome"
    "nix-gc"
  ];

  excludes.home-manager = [
    "sway"
    "hyprland"
    "nix-gc"
  ];

  excludes.darwin = [
    "nix-gc"
  ];
}
