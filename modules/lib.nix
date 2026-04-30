{ lib, ... }: let
  pars = min: val:
    if val > min then
      "[${toString min}-${toString val}]"
    else "${toString min}";
in {
  tmux.mkScanPlugins = pkgs: path: extendPlugins:
    extendPlugins ++ (((lib.import-tree
      .initFilter (lib.hasSuffix ".tmux"))
      .map (p: let k = lib.fmway.basename p; in {
        plugin = pkgs.tmuxPlugins.${k};
        extraConfig = lib.fileContents p;
      }) )
      .pipeTo lib.id)
      path;

  mkNuSecretReplacements = pkgs: {
    extras ? [ ],
    reader ? { },
  }: set: output: let
    script = pkgs.writeScript "nushell-secret-replacement.nu" (''
      #!/bin/env -S ${lib.getExe pkgs.nushell} -n --stdin

      ${lib.concatMapStringsSep "\n" lib.fileContents extras}
    '' + (let s = lib.fileContents ./secretreplacement.nu; in
      if reader == {} then s
      else
        builtins.replaceStrings [ "let reader = { default: {|file| open $file}, }" ] [ ("let reader = { default: {|file| open $file}, } | merge " + lib.hm.nushell.toNushell {} reader) ] s
    ) + "\n" + ''
      def main [] {
        $in | from json | replace secret | to json
      }
    '');
  in ''
    ${script} > "${output}" <<'EOF'
      ${builtins.toJSON set}
    EOF
  '';

  kdl = rec {
    m = {
      Left = "h"; Down = "j"; Up = "k"; Right = "l";
      h = "Left"; j = "Down"; k = "Up"; l = "Right";
    };
    M = {
      Left = "H"; Down = "J"; Up = "K"; Right = "L";
      H = "Left"; J = "Down"; K = "Up"; L = "Right";
    };
    hjkl = fn: lib.flatten (
      map (x: fn m.${x}) [ "h" "j" "k" "l" ]);
    HJKL = fn: lib.flatten (
      map (x: fn M.${x}) [ "H" "J" "K" "L" ]);
    seq = start: end: fn: let
      range = builtins.genList (x: x + start) (end - start + 1);
    in lib.flatten (map (x: fn x) range);
  };

  mkNestedModule = path: module: lib.setAttrByPath path (lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule module);
  });

  genRegex = x: assert lib.isInt x && x <= 100; let
    dig  = builtins.floor (x / 10);
    rest = lib.mod x 10;
  in lib.optionalString (dig >= 1) "[0-9]|"
   + lib.optionalString (dig > 1) "${pars 1 (dig - 1)}[0-9]|"
   + lib.optionalString (rest == 0) "${toString x}"
   + lib.optionalString (rest != 0 && dig != 0) (toString dig)
   + lib.optionalString (rest != 0) "[0-${toString rest}]";

  mkFishPath = pkgs:
    lib.concatStrings (
      map (x:
        "fish_add_path ${x}\n"
      ) (lib.splitString ":" (lib.makeBinPath pkgs)));

  hm.nushell = rec {
    mkNushellFn' = indent: fn: let
      args = builtins.attrNames (builtins.functionArgs fn);
      args'= builtins.listToAttrs (map (name: {
        inherit name;
        value = "$" + name;
      }) args);
      str =
        "{|"
      + builtins.concatStringsSep ", " args
      + "| \n"
      + lib.fmway.addIndent "  " (fn args')
      + "}";
    in lib.fmway.addIndent indent str;
    mkNushellFn = mkNushellFn' "";
    mkNushellFnInline = x: lib.hm.nushell.mkNushellInline (mkNushellFn x);
    mkNushellFnInline' = indent: x: lib.hm.nushell.mkNushellInline (mkNushellFn' indent x);
  };

  zellij = let
    inherit (lib.kdl) node leaf;
  in rec {
    bind = node "bind";
    unbind = node "unbind";
    Resize = leaf "Resize";
    SwitchToMode = leaf "SwitchToMode";
    MoveFocus = leaf "MoveFocus";
    NewPane = leaf "NewPane";
    SwitchToNormal = SwitchToMode "Normal";
  };
}
