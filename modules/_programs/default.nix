{ lib, ... }:
{
  # ls alternative
  eza = {
    enable = lib.mkDefault true;
    icons = "auto"; # display icons
    git = true; # List each file's Git status if tracked or ignored
  };

  fd.enable = lib.mkDefault true; # find alternative, more wuzz wuzz
  fd.hidden = lib.mkDefault true; # show hidden file

  jq.enable = lib.mkDefault true;

  lazygit.enable = lib.mkDefault true;

  zoxide.enable = lib.mkDefault true; # cd alternative

  translate-shell.enable = lib.mkDefault true; # google or bing translate in terminal

  yt-dlp.enable = lib.mkDefault true; # all in one video downloader

  ripgrep.enable = lib.mkDefault true; # alternative grep

  dircolors = {
    enable = lib.mkDefault true;
    settings = {
      OTHER_WRITABLE = "30;46";
      ".sh" = "01;32";
      ".csh" = "01;32";
    };
  };
}
