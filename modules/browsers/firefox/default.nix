{ lib, search-engines, ... }:
{
  # TODO: add impermanence for firefox / all firefox based
  fmx.browsers._.firefox = {
    firefox = 
      { pkgs, ... }:
      {
        search = {
          default = "ddg"; # default search engine
          privateDefault = "ddg"; # default search engine in private mode
          force = true; # Force replace the existing search configuration

          # list search engines
          engines = let
            additional-engines = builtins.mapAttrs toEngine search-engines;
            toEngine = lib.browsers.firefox.mkEngine { inherit pkgs; };
          in {
            "bing".metaData.alias = "b";
            "Wikipedia".metaData.alias = "w";
            "ddg".metaData.alias = "d";
            "google".metaData.alias = "g";
          } // additional-engines;
        };
      };
  };
}
