{ internal, sources, ... }:
{ ... }:
{
  imports = [
    sources."kaku/services/pipewire"
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
}
