{ internal, lib, _file, ... }:
{ config, pkgs, ... }: let
  abbreviations = import ./abbreviations.nix { inherit lib; };
  keybindings = import ./keybindings.nix { inherit lib; };
  extraConfig = let
    listDir = (builtins.attrNames (builtins.readDir ./defs));
  in lib.concatMapStringsSep "\n" (x: builtins.readFile "${./defs}/${x}") listDir;
  cfg = config.programs.nushell;
in {
  inherit _file;
  config = lib.mkMerge [
  (lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}/nushell/config.nu".text =
      lib.mkBefore (''
        let abbreviations = ${lib.nushell.toNushell {} abbreviations.abbrs}
        # $env.config.edit_mode = "vi"
      '' + "\n" + extraConfig);

    programs.nushell = {
      settings = {
        keybindings = abbreviations.keybindings ++ keybindings;
        menus = abbreviations.menus ++ [];
        use_kitty_protocol = true;
        table.missing_value_symbol = "<empty>";
        hooks.command_not_found = lib.mkForce [
          (lib.nushell.mkNushellFnInline ({ cmd_name }: /* nu */ ''
            print $"Yeuu tolol, ngetik tuh yang bener! Masa (${cmd_name})!!"
            print "Kalo tolol dipikir mas!"
          ''))
        ];
        show_banner = false;
        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
          algorithm = "fuzzy";
          external.enable = true;
          external.max_results = 100;
          external.completer = lib.nushell.mkNushellFnInline ({ spans }: # nu
          ''
            let expanded_alias = scope aliases
            | where name == ${spans}.0
            | get -o 0.expansion

            let spans = if $expanded_alias != null {
              ${spans}
              | skip 1
              | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
              ${spans}
            }

            match $spans.0 {
              devenv => $_argc_completer
              _ => $_carapace_completer
            } | do $in $spans
          '');
        };
        cursor_shape = {
          vi_insert = "line";
          vi_normal = "block";
          emacs = "line";
        };
        
      };
      extraConfig = /* nu */ ''
        $env.PATH = ($env.PATH | split row (char esep) | prepend ($env.HOME | path join ".local/bin"))
      '';
    };
  })
  (lib.mkIf (cfg.settings.use_kitty_protocol or false) {
    home.packages = [ pkgs.kitty ];
  })
  ];
}
