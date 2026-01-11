{ lib, super, ... }: let
  pars = min: val:
    if val > min then
      "[${toString min}-${toString val}]"
    else "${toString min}";
in {
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

  kdl = super.kdl // rec {
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

  mkFishPath = pkgs:
    lib.concatStrings (
      map (x:
        "fish_add_path ${x}\n"
      ) (lib.splitString ":" (lib.makeBinPath pkgs)));

  genUser = name: assert lib.isString name; args @ {
    description ? name,
    isNormalUser ? true,
    home ? "/home/${name}",
    extraGroups ? [
      "networkmanager"
      "docker"
      "wheel"
      "video"
      "gdm"
      "dialout"
      "kvm"
      "adbusers"
      "vboxusers"
      "fwupd-refresh"
    ],
    ...
  }: assert (
    lib.isString description &&
    lib.isBool isNormalUser &&
    lib.isString home &&
    lib.isList extraGroups &&
    lib.all lib.isString extraGroups
  ); {
    ${name} = args // {
      inherit description isNormalUser home extraGroups;
    };
  };

  # users :: lists, options :: ( attrs | str -> attrs )
  genUsers = users: options:
    assert (
      lib.isList users &&
      lib.length users != 0 &&
      lib.all lib.isString users &&
      (lib.isAttrs options || (lib.isFunction options && lib.isAttrs (options "test")))
    );
    lib.foldl' (acc: name: let
      opts = if lib.isAttrs options then options else options name;
    in  acc // lib.genUser name opts) {} users;

  nixvim = super.nixvim.extend (se: su: let
    k'= idx: res: x:
      if lib.isString x then
        k' (idx + 1) (res // { "__unkeyed-${toString idx}" = x; })
      else res // x;
    k = k' 1 {};
    lz-n.expand = map (x: if lib.isFunction x then let
      r = x arg;
      fArgs = builtins.functionArgs x;
      arg =
        if fArgs == {} then
          su.toLuaObject (r.opts or {})
        else
          lib.mapAttrs (k: _: r.${k}) (lib.filterAttrs (_: v: !v) fArgs);
      excludes = r.excludes or [] ++ [ "excludes" "opts" ];
    in removeAttrs r excludes else x);
  in {
    toLuaObject' = x: if isNull x then "" else se.toLuaObject x;
    inherit k lz-n;
  });

  mkFixFontsDir = pkgs: list-conflicted: packages: let res = builtins.foldl' (a: c: let
    is_conflict = builtins.elem c.pname list-conflicted;
    package = if is_conflict then c.overrideAttrs {
      # remove fonts.dir on both packages
      fixupPhase = "rm -f $out/share/fonts/X11/misc/fonts.dir";
    } else c;
    font_dir = lib.fileContents "${c}/share/fonts/X11/misc/fonts.dir";
  in a // {
    packages = a.packages ++ [package];
    fonts-dirs = a.fonts-dirs ++ lib.optional is_conflict font_dir;
  }) {
    fonts-dirs = [];
    packages = [
      # concat fonts.dir and store in another derivation
      (pkgs.writeTextFile {
        text = let
          result = builtins.foldl' (a: c: let
            # split text
            split_txt = lib.splitString "\n" c;
          in {
            # sum first elem
            sum = builtins.fromJSON (lib.head split_txt) + a.sum;
            context = a.context + builtins.concatStringsSep "\n" (lib.tail split_txt) + "\n";
          }) { sum = 0; context = ""; } res.fonts-dirs;

          # and then concat all
        in "${toString result.sum}\n${result.context}";
        destination = "/share/fonts/X11/misc/fonts.dir";
        name = "fonts.dir";
      })
    ];
  } packages; in res.packages;
}
