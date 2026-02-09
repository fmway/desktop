{ lib, ... }:
{
  abbrs = {
    "nob"   = "nixos-rebuild build --show-trace --verbose";
    "nobo"  = "doas nixos-rebuild boot --show-trace --verbose";
    "nos"   = "doas nixos-rebuild switch --show-trace --verbose";
    "nofu"  = "doas nix flake update --flake /etc/nixos";
    "nfu"   = "nix flake update";
    "nofl"  = "doas nix flake lock /etc/nixos";
    "nfl"   = "nix flake lock";
    "nfit"  = "nix flake init --template";
    "nfi"   = "nix flake init";
    "nfnt"  = "nix flake new --template";
    "nfn"   = "nix flake new";
    "y"     = "yt-dlp";
    "lg"    = "lazygit";
    ":q"    = "exit";
    "q"     = "exit";
    ":q!"   = "exit";
    # TODO: support set mouse
    ":id"   = "trans :id";
    "id:en" = "trans id:en";
    ":en"   = "trans :en";
    "en:id" = "trans :en";
  };
  menus = [
    {
      name = "abbr_menu";
      only_buffer_difference = false;
      marker = "none";
      type = {
        layout = "columnar";
        columns = 1;
        col_width = 20;
        col_padding = 2;
      };
      style = {
        text = "green";
        selected_text = "green_reverse";
        description_text = "yellow";
      };
      source = lib.nushell.mkNushellFnInline' "        " ({ buffer, position }: # nu
      ''
        let before_cursor = (${buffer} | str substring 0..${position})
        let current_word = ($before_cursor | split row ' ' | last)
  
        let match = $abbreviations | columns | where $it == $current_word
        if ($match | is-empty) {
          { value: ${buffer} }
        } else {
          # Replace only the current word, preserve rest of buffer
          let replacement = ($abbreviations | get $match.0)
          let word_len = ($current_word | str length | into int)
          let before_word_end = ($position - $word_len)
          let before_word = if $before_word_end > 0 {
            (${buffer} | str substring 0..<$before_word_end)
          } else {
            ""
          }
          let after_cursor = (${buffer} | str substring $position..)
          { value: ($before_word ++ $replacement ++ $after_cursor) }
        }
      '');
    }
  ];
  keybindings = [
    {
      name = "abbr_menu";
      modifier = "none";
      keycode = "enter";
      mode = [ "emacs" "vi_normal" "vi_insert" ];
      event = [
        { send = "menu"; name = "abbr_menu"; }
        { send = "enter"; }
      ];
    }
    {
      name = "abbr_menu";
      modifier = "none";
      keycode = "space";
      mode = [ "emacs" "vi_insert" ];
      event = [
        { send = "menu"; name = "abbr_menu"; }
        { edit = "insertchar"; value = " "; }
      ];
    }
  ];
}
