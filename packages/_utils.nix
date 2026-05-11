{ lib, pkgs, ... }:
rec {
  getRequireScript = script: builtins.concatMap (str: let
    m = builtins.match "^# @require[ ]+([^ ].*[^ ])[ ]*$" str;
  in if isNull m then
    []
  else
    map (x:
      lib.getAttrFromPath (lib.splitString "." x) pkgs
    ) (lib.splitString " " (builtins.head m))
  ) (lib.splitString "\n" script);

  toPkg = p: let
    p' = builtins.toPath p;
    content = lib.fileContents p';
    name = lib.removeSuffix ".sh" (baseNameOf p');
  in pkgs.writeScriptBin name ''
    #!${lib.getExe pkgs.bash}

    export PATH="${lib.makeBinPath (getRequireScript content)}:$PATH"

    ${content}
  '';
}
