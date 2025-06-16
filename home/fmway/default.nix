{ internal, config, self, lib, ... } @ x:
{ config, pkgs, inputs, osConfig ? {}, ... } @ y: let
  cfg = config.home;
in {
  imports = [
    ./packages.nix
    ./configs
    ./fish.nix
    (self.homeManagerModules.defaultWithout [
      "hyprland"
      "firefox"
    ])
  ] ++ map (name: { lib, pkgs, ... }: {
      options.programs.${name}.profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          config._module.args.pkgs = pkgs;
        });
      };
    }) [ "floorp" "firefox" "zen-browser" ];
  programs.floorp = {
    enable = true;
    nativeMessagingHosts = with pkgs ;[
      firefoxpwa
      gnome-browser-connector
    ];
    profiles.namaku = { ... }: {
      imports = [ self.firefoxProfileModules.default ];
      extensions = import ./firefox-extension.nix pkgs;
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
}
