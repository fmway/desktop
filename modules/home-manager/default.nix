{ internal, inputs, selfInputs ? inputs, _file, allModules, ... }:
{ lib, inputs ? {}, pkgs, ... }:
{
  inherit _file;
  imports = allModules ++ [
    (inputs.fmway-modules or selfInputs.fmway-modules).homeManagerModules.all
  ];

  nix.package = lib.mkDefault pkgs.nix;

  programs = {
    # cross shell completion
    # carapace = {
    #   enable = lib.mkDefault true;
    #   enableFishIntegration = false;
    # };

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
  };
}
