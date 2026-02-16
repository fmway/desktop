{ internal, _file, allModules, lib, ... }:
{ config, pkgs, ... }:
{
  inherit _file;
  imports = allModules;
  search = {
    default = "ddg"; # default search engine
    privateDefault = "ddg"; # default search engine in private mode
    force = true; # Force replace the existing search configuration

    # list search engines
    engines = {
      "bing".metaData.alias = "b";
      "Wikipedia".metaData.alias = "w";
      "ddg".metaData.alias = "d";
      "google".metaData.alias = "g"; # builtin engines only support specifying one additional alias
    };
  };
}
