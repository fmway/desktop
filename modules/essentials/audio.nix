{
  source-files."kaku/services/pipewire" = "https://raw.githubusercontent.com/linuxmobile/kaku/refs/heads/niri/system/services/pipewire.nix";

  fmx.essentials.audio.includes = [
    ({ user, persistent, ... }: {
      persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
        ".local/state/wireplumber"
      ];
    })
  ];
  fmx.essentials.audio.nixos = {
    imports = [
      <sources/kaku/services/pipewire>
    ];

    # pipewire
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;
      wireplumber.extraConfig = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = true;
        };
      };
    };

    # disable pulseaudio
    services.pulseaudio.enable = false;
  };
}
