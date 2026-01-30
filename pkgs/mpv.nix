{ internal, self, pkgs ? self, ... }:
pkg: let
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
  r = pkg.override {
    inherit scripts;
  };
in r // {
  override = { ... } @ v: r.override (v // {
    scripts = v.scripts or [] ++ scripts;
  });
}
