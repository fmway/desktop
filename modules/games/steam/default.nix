{ inputs, den, ... }:
{
  fmx.games._.steam.includes = [
    (den._.unfree [
      "steam"
      "steam-unwrapped"
    ])
    ({ user, host, persistent, ... }: {
      persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
        ".steam"
        ".local/share/Steam"
      ];
    })
  ];
  fmx.games._.steam.nixos =
  { config, lib, pkgs, ... }:
  {
    nixpkgs.overlays = [
      inputs.self.overlays.steam
    ];
    environment.systemPackages = with pkgs; [
      # steamcmd
      # steam-tui
    ];

    # required for steam gamescope
    programs.gamescope = lib.mkIf config.programs.steam.enable {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession = {
        enable = true;
        # env = {};
        args = [
          "--tap-to-click"
          "--tap-and-drag"
          "--drag-lock"
          "--middle-emulation"
          "--natural-scrolling=touchpad"
        ];
      };

      protontricks.enable = true;
      extraPackages = with pkgs; [
      ];
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
