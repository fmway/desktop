{ lib, ... }:
lib.fix (s: {
  den.hosts.x86_64-linux.Namaku1801.users.fmway.firefox-profiles.Namaku1801 = {
    profileName = "namaku";
    classes = [ "floorp"  ];
    classAliases.floorp = [ "firefox" ];
  };

  den.homes.x86_64-linux."fmway@Namaku1801".firefox-profiles.Namaku1801 = s.den.hosts.x86_64-linux.Namaku1801.users.fmway.firefox-profiles.Namaku1801;

  den.aspects.Namaku1801.includes = [
    <fmx/browsers/firefox>
    <overlays/nur>
  ];
  den.aspects.Namaku1801.floorp =
  { pkgs, ... }:
  {
    containersForce = true; # force replace the existing containers configuration
    # color: "blue", "turquoise", "green", "yellow", "orange", "red", "pink", "purple", "toolbar"
    # icon : "briefcase", "cart", "circle", "dollar", "fence", "fingerprint", "gift", "vacation", "food", "fruit", "pet", "tree", "chill"
    containers = {
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

    # TODO
    extensions.packages = (with pkgs.nur.repos.rycee.firefox-addons; [
      # metamask
      # multi-account-containers
      violentmonkey
      # greasemonkey
      # gesturefy
      # tree-style-tab
      # react-devtools
      # search-by-image
      # firefox-color
      # vue-js-devtools
    ]) #++ pkgs.lib.optionals (pkgs ? fmway) (with pkgs.fmway.firefox-addons; [
    #   xdm_v8
    #   what-font
    #   # wakatime
    #   # stayfree
    #   firefox-relay
    #   # preact-devtools
    # ])
    ;
  };
})
