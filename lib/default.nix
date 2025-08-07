{ lib, super, ... }: let
  pars = min: val:
    if val > min then
      "[${toString min}-${toString val}]"
    else "${toString min}";
in {
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

  nixvim = super.nixvim.extend (se: su: {
    toLuaObject' = x: if isNull x then "" else se.toLuaObject x;
  });
}
