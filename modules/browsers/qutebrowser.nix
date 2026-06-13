{ search-engines, lib, ... }:
{
  fmx.browsers.qutebrowser.homeManager.programs.qutebrowser = {
    keyBindings.normal = {
      "<Alt-o>" = "cmd-set-text :open {url}";
      ";;" = "cmd-set-text :";
    };

    greasemonkey = [];

    settings.auto_save.session = true;

    searchEngines = let
      additional-engines = lib.mapAttrs' (_: v: {
        name = lib.last v.definedAliases;
        value = builtins.replaceStrings [ "{searchTerms}" ] [ "{}" ] v.url;
      }) search-engines;
    in rec {
      g  = "https://www.google.com/search?q={}";
      b  = "https://www.bing.com/search?q={}";
      d  = "https://duckduckgo.com/?q={}";
      DEFAULT = g;
    } // additional-engines;
  };
}
