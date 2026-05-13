{ den, lib, __findFile, ... }:
{
  fmx.essentials = { config, ... }: {
    includes = builtins.attrValues config.provides ++ [
      <fmx/nix>
      <fmx/boot>
      <fmx/networking>
      ({ user, ... }: {
        nixos.nix.settings.trusted-users = [ user.userName ];
        nixos.users.users.${user.userName}.extraGroups = [
          "video"
          "dialout"
          "kvm"
          "adbusers"
          "fwupd-refresh"
        ];
      })
      ({ user, host, persistent, ... }: {
        persistence.${persistent.defaultDirectory}.users.${user.userName} = {
          directories = [
            "Downloads"
            "Music"
            "Pictures"
            "Documents"
            "Videos"
            ".ssh"
            ".gnupg"
            ".local/share/keyrings"
            ".local/share/direnv"
            ".config/sops"
            ".android"
          ];
        };
      })
    ];

    persistence = { persistent,  ... }:
    {
      ${persistent.defaultDirectory} = {
        enable = true;
        hideMounts = true;
        directories = map (x: { directory = x; mode = "0755"; user = "root"; group = "root"; }) [
          "/etc/nixos"
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd"
          "/var/db/dhcpcd"
          "/var/db/sudo/lectured"
        ] ++ [
          "/var/lib/boltd"
          "/var/lib/fwupd"
          "/etc/secrets"
          { directory = "/var/lib/sops-nix"; mode = "u=rwx,g=,o="; user = "root"; group = "root"; }
          { directory = "/var/lib/upower"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
          { directory = "/var/lib/bluetooth"; mode = "u=rwx,g=rx,o=x"; user = "root"; }
        ];

        files = [
          "/etc/machine-id"
          "/etc/kernel/entry-token"
        ];
      };
    };

    nixos = { pkgs, ... }:
    {
      imports = [
        <sources/kaku/hardware/bluetooth>
      ];

      environment.systemPackages = with pkgs; [
        android-tools
      ];

      # Enable ls colors in bash
      programs.bash.enableLsColors = true;

      # allow fuse in user mode
      programs.fuse.userAllowOther = true;

      # Some programs need SUID wrappers, can be configured further or are started in user sessions.
      programs.mtr.enable = true;
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Enable fwupd for updating firmware
      services.fwupd.enable = true;

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
      nixos = {
        hardware.enableAllFirmware = lib.mkDefault true;
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        
        boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "uas" "sd_mod" ];
      };
    };
    _.kdeconnect = {
      includes = [
        ({ user, host, persistent, ... }: {
          persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
            ".config/kdeconnect"
          ];
        })
      ];
      nixos.programs.kdeconnect.enable = true;
    };
  };

  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  source-files."kaku/hardware/bluetooth" = "https://raw.githubusercontent.com/linuxmobile/kaku/refs/heads/niri/system/hardware/bluetooth.nix";
}
