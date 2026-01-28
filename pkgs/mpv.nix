{ internal, self, pkgs ? self, ... }:
pkg: pkg.override {
  scripts = with pkgs.mpvScripts; [
    youtube-upnext
    sponsorblock
    reload
    mpv-playlistmanager
    mpv-cheatsheet
    mpris
    memo
    thumbfast
    evafast
    uosc
  ];
}
