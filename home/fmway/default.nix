{ config, inputs, ... }: let
  cfg = config.home;
in {
  imports = [
    ./packages.nix
    ./configs
    ./fish.nix
    ./browser.nix
    inputs.fmway-conf.homeManagerModules.default
  ];

  programs.zellij.enable = true;
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
    };

    # xkb options
    keyboard.options = [
      "grp:shifts_toggle"
    ];
  };
  programs.git.settings = {
    user.name = "fmway";
    user.email = "fm18lv@gmail.com";
    url."git@github.com:fmway/".insteadOf = "fmway:";
  };

  programs.qutebrowser = {
    settings = {
      url.start_pages = "https://fmway.me";
      url.default_page= "https://fmway.me";
    };
  };
}
