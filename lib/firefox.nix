{ lib, ... }: let
  inherit (lib.fmway) mkParse mkResolvePath;
  inherit (builtins) toPath;
in {
  mkEngine = var: k: { url, ... } @ v: let
    rest = removeAttrs v [ "url" "icon" ];
    matchedUrl = lib.match "^(.+)[?](.+)$" url;
    template = if isNull matchedUrl then url else lib.elemAt matchedUrl 0;
    icon = toPath (mkResolvePath (toPath ./.) (mkParse var (v.icon or "")));
    params = if isNull matchedUrl then [] else map (x: let
      y = lib.match "^(.+)=(.*)$" x;
    in {
      name = lib.head y;
      value = lib.last y;
    }) (lib.splitString "&" (lib.elemAt matchedUrl 1));
  in rest // {
    urls = [ ({ inherit template; } // lib.optionalAttrs (params != []) { inherit params; }) ];
  } // lib.optionalAttrs (v ? icon) { inherit icon; };
}
