{ config, lib, ... }: let
  # config.set(xxx, yyy)
  uncommon = {
    config = {
      # fileselect.handler = "external";
    };
  };
in {
  imports = [
    (lib.mkAliasOptionModule [ "programs" "qutebrowser" "c" ] [ "programs" "qutebrowser" "settings" ])
  ];
  programs.qutebrowser = {
    keyBindings = {
      normal = {
        "<Alt-o>" = "cmd-set-text :open {url}";
        ";;" = "cmd-set-text :";
      };
    };
    enable = lib.mkDefault true;
    greasemonkey = [];

    c.auto_save.session = true;
    
    extraConfig = lib.qutebrowser.parse uncommon;
    searchEngines = rec {
      nx = "https://nix-community.github.io/nixvim/search?query={}";
      gs = "https://github.com/search?q={}&type=repositories";
      gt = "https://github.com/search?q={}&type=topics";
      gu = "https://github.com/{}";
      hm = "https://home-manager-options.extranix.com/?type=packages&release=master&query={}";
      no = "https://search.nixos.org/options?type=packages&release=master&query={}";
      np = "https://search.nixos.org/packages?type=packages&release=master&query={}";
      w  = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
      aw = "https://wiki.archlinux.org/?search={}";
      nw = "https://wiki.nixos.org/index.php?search={}";
      g  = "https://www.google.com/search?q={}";
      b  = "https://www.bing.com/search?q={}";
      d  = "https://duckduckgo.com/?q={}";
      cb = "https://codeberg.org/{}";
      gl = "https://gitlab.org/{}";
      gls= "https://git.lix.systems/{}";
      DEFAULT = g;
    };
  };
}
