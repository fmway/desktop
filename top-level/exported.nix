{
  # exclude in self.nixosModules.default
  excludes.nixos = [
    "inputs"
    "gnome"
  ];

  excludes.home-manager = [
    "sway"
    "hyprland"
  ];
}
