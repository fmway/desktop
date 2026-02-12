{ inputs, osConfig ? {}, config, pkgs, lib, ... }:
{
  imports = map (name: { lib, pkgs, ... }: {
    options = lib.mkNestedModule [ "programs" name "profiles" ] {
      imports = [
        inputs.fmway-conf.firefoxProfileModules.default
      ];
      config._module.args.pkgs = pkgs;
    };
    config.programs.${name} = {
      nativeMessagingHosts = with pkgs; lib.optionals (osConfig.services.desktopManager.gnome.enable or false) [
        gnome-browser-connector
      ];
    };
  }) [ "floorp" "firefox" "librewolf" ];
  programs = lib.genAttrs [ "floorp" "librewolf" ] (_: {
    enable = true;
    profiles.namaku = { ... }: {
      imports = [
        ({ lib, ... }:
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
        })
      ];
      extensions.packages = import ./firefox-extension.nix pkgs;
    };
  });
}
