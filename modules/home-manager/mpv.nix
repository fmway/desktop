{ lib, pkgs, ... }:
{
  programs.mpv = {
    enable = lib.mkDefault true;
    config = {
      volume-max = "300";
      hwdec = "auto-safe";
      vo = "gpu";
      profile = "gpu-hq";
      gpu-context = "wayland";
    };
    bindings = {
      # zoom video
      "Alt+-" = "add video-zoom -0.25";
      "Alt+=" = "add video-zoom 0.25";

      # Rotate video
      "ctrl+left" = ''cycle-values video-rotate "90" "180" "270" "0'';

      # mirroring video
      "ctrl+l"= "vf oggle hflip";
      "ctrl+v"= "vf toggle vflip";
    };

    scripts = (with pkgs.mpvScripts;
    [
      youtube-upnext
      webtorrent-mpv-hook
      visualizer
      sponsorblock
      # seekTo
      reload
      quality-menu
      quack
      mpv-playlistmanager
      autosubsync-mpv
      # mpv-osc-modern
      mpv-cheatsheet
      mpris
      # modernx
      memo
      thumbfast
      # manga-reader
      inhibit-gnome
      evafast
      uosc
    ]) ++ lib.optionals (pkgs ? fmway) (with pkgs.fmway.mpv-scripts; [
      multiloop
      menu
      bookmarker
    ]);

    scriptOpts.playlistmanager = {
      # extra functionality keys
      key_sortplaylist = "ALT+S";
      key_shuffleplaylist = "ALT+R";
      key_reverseplaylist = "ALT+SHIFT+R";
      key_loadfiles = "";
      key_saveplaylist = "";
    };
  };
}
