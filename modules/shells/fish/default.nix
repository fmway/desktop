{ lib, fmx, den, inputs, ... }: let
  fishModule = den.lib.aspects.resolve "fish" fmx.shells._.fish;
  ev = (lib.evalModules {
    specialArgs.pkgs.fish = { type = "derivation"; };
    modules = [
      ({ config, lib, pkgs, ... }: {
        options = removeAttrs (import "${inputs.home-manager}/modules/programs/fish.nix" { inherit config lib pkgs; }).options.programs.fish [ "generateCompletions" "package" "enable" "sessionVariablesPackage" ];
      })
      fishModule
    ];
  }).config;

  fish.generateCompletions = lib.mkDefault false; # dont create fish completions by manpage, very very useless
  fish.enable = lib.mkDefault true;
  fish.interactiveShellInit = /* fish */ ''
    set fish_greeting # Disable greeting
    printf '\e[5 q'
    apply-my-prompt
    apply-my-theme
  '';
  # overlay = self: super: {
  #
  # };
  mkFish = pkgs: let
    dotfiles = den.lib.fish.package pkgs;
  in pkgs.wrapFish {
    # TODO: add shellAliases, abbrs, initFish, etc.
    functionDirs = [ "${dotfiles}/functions" ];
    pluginPkgs = map (x: x.src) ev.plugins;
  } // { inherit dotfiles; passthru = { inherit dotfiles; }; };

  modulePackage = { pkgs, ... }: {
    programs.fish.package = mkFish pkgs;
  };
in { 
  fmx.shells._.fish = { config, ... }:
  {
    packages =
      { pkgs, ... }:
      {
        fish = mkFish pkgs;
      };
    nixos.imports = [ modulePackage ];
    homeManager.imports = [
      ({ osConfig, ... }:
      {
        imports = lib.optional (!osConfig.useGlobalPkgs or false) modulePackage;
      })
    ];
    nixos.programs.fish = fish;
    homeManager.programs.fish = fish;
    # darwin ...
    includes = builtins.attrValues config.provides;
    _.functions = { config, ... }: {
      description = "Collection of my fish functions";
      includes = builtins.attrValues config.provides;
      _ = (((lib.import-tree
        .initFilter (lib.hasSuffix ".fish"))
        .toAttrs ({ path, ... }: lib.fmway.parseFish (lib.fileContents path)))
        .pipeTo (x: lib.listToAttrs (map ({ name, value }: {
          inherit name;
          value = {
            description = builtins.concatStringsSep ": " (["${name}.fish"] ++ lib.optional (value ? description) value.description);
            fish.functions.${name} = value;
            # homeManager.programs.fish.functions.${name} = value;
          };
        }) x)))
        ./_functions;
    };
  };

  den.ctx.flake-packages.includes = [ fmx.shells._.fish ];

  den.lib.fish.package = let
    f = name: obj: let
      body = obj.body or obj;
      opts = map (x: let k = lib.fmway.kebabize x; v = obj.${x}; in
        if x == "onEvent" then
          lib.concatMapStringsSep " " (o: "--on-event=\"${toString o}\"") v
        else if x == "argumentNames" then
          "--argument-names=${toString v}"
        else if builtins.isBool x then
          "--${k}"
        else
          "--${k}=\"${toString v}\""
      ) names;
      names = builtins.filter (x: x != "body" && !builtins.elem obj.${x} [ null false ]) (builtins.attrNames obj);
      begin = builtins.concatStringsSep " " (["function" name] ++ lib.optionals (builtins.isAttrs obj) opts);
    in ''
      ${begin}
        ${lib.fmway.addIndent "  " body}
      end
    '';
  in pkgs: pkgs.symlinkJoin {
    name = "wrapper-fish";
    paths = map (name: pkgs.writeTextDir "functions/${name}.fish" (f name ev.functions.${name})) (builtins.attrNames ev.functions);
  };
}
