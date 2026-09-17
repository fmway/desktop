{ lib, ... }:
{
  # TODO: add impermanence for firefox / all firefox based
  fmx.browsers._.firefox = {
    firefox = 
      { pkgs, search-engines, ... }:
      {
        search = {
          default = "ddg"; # default search engine
          privateDefault = "ddg"; # default search engine in private mode
          force = true; # Force replace the existing search configuration

          # list search engines
          engines = {
            "bing".metaData.alias = "b";
            "Wikipedia".metaData.alias = "w";
            "ddg".metaData.alias = "d";
            "google".metaData.alias = "g";
          } // builtins.mapAttrs (_: lib.browsers.firefox.mkEngine) (search-engines pkgs);
        };
      };
  };
}
