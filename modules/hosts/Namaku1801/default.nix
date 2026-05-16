{ fmx, den, lib, inputs, ... }: let
  nixvimModule = den.lib.aspects.resolve "nixvim" den.aspects.Namaku1801;
in {
  # den.aspects.fmway.excludes = [
  #   <fmx/desktops/shells/noctalia>
  # ];
  # den.aspects.fmway.provides.Namaku1801 = {
  #   # replace noctalia to dms
  #   # meta.handleWith = den.lib.aspects.fx.constraints.substitute <fmx/desktops/shells/noctalia> <fmx/desktops/shells/dms>;
  #   excludes = [
  #     <fmx/desktops/shells/noctalia>
  #   ];
  #   includes = [
  #     <fmx/desktops/shells/dms>
  #   ];
  # };
  den.hosts.x86_64-linux.Namaku1801 = {
    impermanence.enable = true;
    persistent.cacheDirectory = "/persist/shared_cache";
    scx = {
      default.scheduler = "scx_bpfland";
      default.args = [ "-f" "-k" "-p" ];

      alter.scheduler = "scx_flash";
      alter.args = [ "-k" ];
    };

    zram.size = 16384; # 16GB
    zram.priority = 100;

    battery_limit = 10; # autoshutdown when battery under 10%

    timeZone = "Asia/Jakarta";
    locale = "en_US.UTF-8";
    extraLocale = "id_ID.UTF-8";
    configurationLimit = 20;
  };
  den.aspects.Namaku1801 = {
    includes = [
      <fmx/display-managers/ly>
      <fmx/privileges/doas>
      <fmx/privileges/please>
      <fmx/tools/nix-ld>
      <fmx/services/keyd>
      <fmx/editors/nixvim>
      <fmx/file-managers/yazi>
      <fmx/disk/zfs>
      <fmx/disk/zfs/auto-snapshot>
      <fmx/kernels/cachy>
      (fmx.disk._.zfs._.auto-scrub "weekly")
    ];
    provides.to-users.nixos = { config, pkgs, ... }:
    {
      nixpkgs.overlays = [
        (self: super: import ../../../packages { inherit lib; pkgs = self; })
      ];
      environment.systemPackages = with pkgs; [
        qr-watcher
        watch-clip-sync
      ];
      programs.fish.useBabelfish = true;

      imports = [
        inputs.nixvim.nixosModules.nixvim
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ./_impermanence.nix
      ];
      programs.nixvim.enable = true;
      programs.nixvim.imports = [
        nixvimModule
      ];

      # disable capslock
      services.xserver.xkb.options = lib.mkAfter "grp:shifts_toggle";

      services.xserver.xkb.layout = "us";
      console.keyMap = "us";
      networking.hostId = lib.mkDefault "4970ef8d"; # required for zfs

      boot.kernelModules = [ "kvm-intel" ];

      nix.settings.experimental-features = [
        ("pipe-operator" + lib.optionalString (!config.lix.enable or false) "s")
      ];

      services.zfs.autoSnapshot = {
        enable = true;
        frequent = 0;
        hourly = 0;
        daily = 0;
        weekly = 2;
        monthly = 1;
      };

      services.zfs.autoScrub.interval = "weekly";
    };
    provides.to-users.includes = [
      <fmx/essentials>
      <fmx/programs>
      <fmx/shells/fish>
      <fmx/shells/nushell>
      <fmx/editors/zed>
      <fmx/games/steam>
      # <fmx/containers/waydroid>
      <fmx/containers/flatpak>
      <fmx/containers/docker>
      # <fmx/containers/bottles>
      <fmx/desktops/shells/noctalia>
      # <fmx/desktops/shells/dms>
      <fmx/desktops/niri>
      # (fmx.nix._.gc "--delete-older-than 3d" "Mon,Fri *-*-* 00:00:00")

      {
        # disable ~/.config/nix/nix.conf since that's is already define in /etc/nix/nix.conf
        homeManager.xdg.configFile."nix/nix.conf".enable = lib.mkDefault false;
      }
      ({ home, ... }: {
        # reenable for standalone home manager
        homeManager.xdg.configFile."nix/nix.conf".enable = lib.mkOverride 999 true;
      })
    ];

    provides.to-users.homeManager =
    { config, ... }:
    {
      home = {
        sessionPath = map (x: "${config.home.homeDirectory}/${x}/bin") [
          ".local"
          ".deno"
          ".bun"
        ];

        sessionVariables = rec {
          ASSETS = "${config.home.homeDirectory}/assets";
          ASET = "${config.home.homeDirectory}/aset";
          GITHUB = "${ASET}/Github";
          DOWNLOADS = "${config.home.homeDirectory}/Downloads";
        };

        # disable capslock
        keyboard.options = [
          "grp:shifts_toggle"
        ];
      };
    };
  };

  perSystem = { pkgs, ... }:
  {
    packages.nvim = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
      module.imports = [ nixvimModule ];
    };
  };
}
