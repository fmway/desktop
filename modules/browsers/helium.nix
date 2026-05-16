{
  fmx.browsers._.helium.homeManager =
    { inputs', ... }:
    {
      home.packages = [ inputs'.helium.packages.default ];
    };
  fmx.browsers._.helium = {
    includes = [
      ({ host, user, persistent, ... }: {
        persistence.${persistent.cacheDirectory}.users.${user.userName}.directories = [
          ".cache/net.imput.helium"
        ];
        persistence.${persistent.defaultDirectory}.users.${user.userName}.directories = [
          ".config/net.imput.helium"
        ];
      })
    ];
  };
  flake-file.inputs = {
    helium.url = "github:vikingnope/helium-browser-nix-flake";
    helium.inputs.nixpkgs.follows = "nixpkgs";
  };
}
