{
  # exclude in self.nixosModules.default
  excludes.nixos = [
    "inputs"
    "gnome"
    "auto-shutdown" # FIXME: since i use niri, imho need some patch
  ];

  excludes.home-manager = [
    "sway"
    "hyprland"
  ];
}
