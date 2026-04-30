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

  qutebrowser.parse = { config ? {} }: let
    toPyValue = value:
      if isNull value then
        "None"
      else if lib.isString value then
        "'${value}'"
      else if lib.isList value then
        "[ ${lib.concatStringsSep ", " (map (x: toPyValue x) value)} ]"
      else if lib.isBool value then
        if value then
          "True"
        else "False"
      else toString value;
    describe = x: let
      func = key: y:
        if lib.isAttrs y then
          map (x: func (key ++ [ (lib.replaceStrings [ "-" ] [ "_" ] x) ]) y.${x}) (lib.attrNames y)
        else {
          inherit key;
          value = toPyValue y;
        };
    in lib.flatten (func [] x); 
    # toPy = x: lib.concatStringsSep "\n" (map (x: "${lib.concatStringsSep "." x.key} = ${x.value}") (describe x)) + "\n";
    toPyConfig = x: lib.concatStringsSep "\n" (map (x: "config.set('${lib.concatStringsSep "." x.key}', ${x.value})") (describe x)) + "\n";
    r.config = toPyConfig config;
  in lib.optionalString (config != {}) r.config;
}
