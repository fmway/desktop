{ lib, ... }:
{
  containersForce = true; # force replace the existing containers configuration
  # color: "blue", "turquoise", "green", "yellow", "orange", "red", "pink", "purple", "toolbar"
  # icon : "briefcase", "cart", "circle", "dollar", "fence", "fingerprint", "gift", "vacation", "food", "fruit", "pet", "tree", "chill"
  containers = lib.mkDefault {
    general = {
      color = "blue";
      icon = "fingerprint";
      id = 1;
    };
    UPI = {
      color = "green";
      icon = "fruit";
      id = 2;
    };
    fmway = {
      color = "orange";
      icon = "fence";
      id = 3;
    };
  };
}
