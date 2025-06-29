{ pkgs, lib, config, ... }:
{
  environment.systemPackages = with pkgs; [
    # session-desktop
    # protonmail-desktop
    # appimagekit # ..
    # popsicle # bootable creator
    vscode # 🤫
    mpv # video player
    # zed-editor # another text editor
    bottles # for management wine
    # google-chrome
    # youtube-music # ...
    gst_all_1.gstreamer # ...
    keepassxc # password manager
    # qutebrowser
    # fmpkgs.keypunch # monkeytype for gnome
    firefoxpwa # pwa for firefox

    # terminal
    # contour
    # wezterm
  ];

  # programs.winbox = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # programs.noisetorch.enable = true;
}
