{ lib, ... }:
{
  /*
    
  */
  parse = { config ? {} }: let
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
