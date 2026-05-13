# TODO: expose as nushell class
{ lib, ... }:
{
  fmx.shells._.nushell.includes = [
    ({ user, host, persistent, ... }: {
      persistence.${persistent.defaultDirectory}.users.${user.userName}.files = [
        ".config/nushell/history.txt"
      ];
    })
  ];
  fmx.shells._.nushell.homeManager =
    { config, ... }: let
      abbreviations = import ./_abbreviations.nix { inherit lib; };
      keybindings = import ./_keybindings.nix { inherit lib; };
      extraConfig = let
        listDir = (builtins.attrNames (builtins.readDir ./defs));
      in lib.concatMapStringsSep "\n" (x: builtins.readFile "${./defs}/${x}") listDir;
      cfg = config.programs.nushell;
    in {
      config = lib.mkIf cfg.enable {
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
      };
    };
}
