{ internal, config, self, lib, ... } @ x:
{ config, pkgs, inputs, osConfig ? {}, ... } @ y: let
  cfg = config.home;
in {
  imports = [
    ./packages.nix
    ./configs
    ./fish.nix
    inputs.zen-browser.homeModules.beta
    self.homeManagerModules.default
  ] ++ map (name: { lib, pkgs, ... }: {
      options.programs.${name}.profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          config._module.args.pkgs = pkgs;
        });
      };
      config.programs.${name} = {
        nativeMessagingHosts = with pkgs; lib.optionals (osConfig.services.desktopManager.gnome.enable or false) [
          gnome-browser-connector
        ];
      };
    }) [ "floorp" "firefox" "zen-browser" ];

  programs.zellij.enable = true;
  programs.zen-browser = {
    enable = true;
    profiles.namaku = { ... }: {
      imports = [
        self.firefoxProfileModules.default
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
  };
  home = {
    username = "fmway";
    homeDirectory = "/home/fmway";
    sessionPath = map (x: "${cfg.homeDirectory}/${x}/bin") [
      ".local" # must be ${home}/.local/bin
      ".cargo" # etc
      ".deno"
      ".bun"
      ".foundry"
    ];

    sessionVariables = rec {
      ASSETS = "${cfg.homeDirectory}/assets";
      ASET = "${cfg.homeDirectory}/aset";
      GITHUB = "${ASET}/Github";
      DOWNLOADS = "${cfg.homeDirectory}/Downloads";
    } // lib.optionalAttrs (lib.pathExists "${inputs.self.outPath}/secrets/${cfg.username}.env")
      (lib.fmway.readEnv "${inputs.self.outPath}/secrets/${cfg.username}.env");

    # xkb options
    keyboard.options = [
      "grp:shifts_toggle"
      "caps:none" # disable capslock
    ];
  };
  programs.git = {
    userName = "fmway";
    userEmail = "fm18lv@gmail.com";
    extraConfig = {
      url."git@github.com:fmway/".insteadOf = "fmway:";
    };
  };

  programs.qutebrowser = {
    settings = {
      url.start_pages = "https://fmway.me";
      url.default_page= "https://fmway.me";
    };
  };
}
