{ lib, ... }: let
  inherit (lib.fish) bind bind';
  c = lib.fish.c // { prepend' = x: "fish_smart_prepend \"" + x + "\""; };
in {
  programs.fish.shellAbbrs = let
    with-cursor = str: {
      setCursor = "!";
      expansion = "${str}";
    };
  in {
    "lg" = "lazygit";

    "rkol" = "set_color -o (tr -dc 'A-Fa-f0-9' </dev/urandom | head -c 6 ; echo)";
    ":q" = "exit";
    "q" = "exit";
    ":q!" = "exit";
    "..." = "cd ../..";
    "urldecode" = "sed \"s@+@ @g;s@%@\\\\x@g\" | xargs -0 printf \"%b\"";

    ":id"   = with-cursor "trans :id '!'";
    "id:en" = with-cursor "trans id:en '!'";
    ":en"   = with-cursor "trans :en '!'";
    "en:id" = with-cursor "trans :en '!'";

    "y1080"= "yt-dlp -f 'bestvideo[height<=1080]+bestaudio/best[height<=1080]'";
    "y720" = "yt-dlp -f 'bestvideo[height<=720]+bestaudio/best[height<=720]'";
    "y480" = "yt-dlp -f 'bestvideo[height<=480]+bestaudio/best[height<=480]'";
    "y360" = "yt-dlp -f 'bestvideo[height<=360]+bestaudio/best[height<=360]'";
    "ytp"  = "yt-dlp --yes-playlist -o \"%(playlist)s/%(playlist_index)s. %(title)s.%(ext)s\" -f 'bestvideo[height<=480]+bestaudio/best[height<=480]'";
    "ytplaylist" = "yt-dlp --output '%(playlist_title)s/%(playlist_index)s. %(title)s.%(ext)s'";
    "m3v"  = "mpv --no-video";

    "nob"   = "nixos-rebuild build --show-trace --verbose";
    "nobo"  = "doas nixos-rebuild boot --show-trace --verbose";
    "nos"   = "doas nixos-rebuild switch --show-trace --verbose";
    "nofu"  = "doas nix flake update --flake /etc/nixos";
    "nfu"   = "nix flake update";
    "nofl"  = "doas nix flake lock /etc/nixos";
    "nfl"   = "nix flake lock";
    "nfit"  = "nix flake init --template";
    "nfi"   = "nix flake init";
    "nfnt"  = "nix flake new --template";
    "nfn"   = "nix flake new";
    "nn"    = "nvim +\"tcd $GITHUB/fmway/myOS\"";

    "gclg"   = with-cursor "git clone https://github.com/!";
    "gclgl"  = with-cursor "git clone https://gitlab.com/!";
    "gclc"   = with-cursor "git clone https://codeberg.org/!";
    "gclsg"  = with-cursor "git clone git@github.com:!";
    "gcls"   = with-cursor "git clone git@!";
    "gclsgl" = with-cursor "git clone git@gitlab.com:!";
    "gclsc"  = with-cursor "git clone git@codeberg.org:!";
  };

  programs.fish.vim = {
    enable = true;
    shared_mode = [ "default" "insert" ];
    initial_mode = "insert";
  };

  programs.fish.keybindings = [
    (bind'.insert.erase           "alt-s" {})
    (bind'.insert.erase           "escape" {})
    (bind .insert "alt-k"         (c.prepend "doas") {})
    (bind'.insert "ctrl-shift-b"  (c.append   " --builders 'ssh://eu.nixbuild.net x86_64-linux - 100 1 big-parallel,benchmark'") "end-of-line" {})
    (bind'.insert "alt-i"         (c.prepend' "systemd-inhibit --what=idle") "end-of-line" {})
    (bind'.insert "ctrl-p,v"      (c.prepend' "env ") {})
    (bind'.visual "c,c"           "__fish_codesnap" "end-selection" { setsMode = "default"; })
  ];
}
