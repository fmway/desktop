{ den, lib, __findFile, ... }:
{
  fmx.essentials = { config, ... }: {
    includes = builtins.attrValues config.provides ++ [
      <fmx/nix>
      <fmx/boot>
      <fmx/networking>
    ];

    nixos = { pkgs, ... }:
    {
      imports = [
        <sources/kaku/hardware/bluetooth>
      ];

      environment.systemPackages = with pkgs; [
        android-tools
      ];

      # emulate /bin
      services.envfs.enable = true;

      security.polkit.enable = true;

      services.xserver.excludePackages = [ pkgs.xterm ];
      xdg.portal.enable = true;
      xdg.portal.xdgOpenUsePortal = true;

      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;
    };

    # FIXME: specific hardware
    _.hardware = {
      includes = [
        (den._.unfree [
          "broadcom-bt-firmware"
          "b43-firmware"
          "facetimehd-calibration"
          "facetimehd-firmware"
          "xone-dongle-firmware"
        ])
      ];
      nixos.hardware.enableAllFirmware = lib.mkDefault true;
    };
    _.kdeconnect.nixos.programs.kdeconnect.enable = true;
  };

  source-files."kaku/hardware/bluetooth" = "https://raw.githubusercontent.com/linuxmobile/kaku/refs/heads/niri/system/hardware/bluetooth.nix";
}
