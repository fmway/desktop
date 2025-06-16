{ internal, lib, _file, ... } @ v:
{ pkgs ? {}, config, ... } @ w: let

  var = v // w // { inherit pkgs config; };
  inherit (lib.fmway) mkParse mkResolvePath;
  data = with builtins; fromJSON (readFile ./engines.json);

  toEngine = k: { url, ... } @ v: let
    rest = removeAttrs v [ "url" "icon" ];
    matchedUrl = lib.match "^(.+)[?](.+)$" url;
    template = if isNull matchedUrl then url else lib.elemAt matchedUrl 0;
    icon = with builtins; toPath (mkResolvePath (toPath ./.) (mkParse var (v.icon or "")));
    params = if isNull matchedUrl then [] else map (x: let
      y = lib.match "^(.+)=(.*)$" x;
    in {
      name = lib.head y;
      value = lib.last y;
    }) (lib.splitString "&" (lib.elemAt matchedUrl 1));
  in rest // {
    urls = [ ({ inherit template; } // lib.optionalAttrs (params != []) { inherit params; }) ];
  } // lib.optionalAttrs (v ? icon) { inherit icon; };

  extracted = lib.mapAttrs toEngine data;
in {
  assertions = [
  {
    assertion = pkgs != {};
    message = ''
      You must add pkgs to profiles, e.g:
      ```nix
        { pkgs, ... }: let
          superPkgs = pkgs;
        in {
          programs.firefox.profiles.default = { pkgs, ... }: {
            _module.args.pkgs = superPkgs;
          };
        }
      ```
    '';
  }
  ];
  inherit _file;
  search.engines = extracted;
}
