{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = lib.mkDefault true;
    package = pkgs.zed-editor_git or pkgs.zed-editor;
    extraPackages = with pkgs; [
      rust-analyzer
      gopls
    ];

    userSettings = {
      ui_font_size = 16;
      buffer_font_size = 16;
      vim_mode = true;
      auto_update = false;
      relative_line_numbers = true;
      # calls.mute_on_join = false;

      # Only deno for ts / typescript 😏
      languages = lib.pipe [ "TypeScript" "TSX" ] [
        (map (name: {
          inherit name;
          value.language_servers = [
            "deno"
            "!typescript-language-server"
            "!vtsls"
            "!eslint"
          ];
          value.formatter = "language_server";
        })) 
        (builtins.listToAttrs)
      ];

      lsp = {
        deno.settings.deno.enable = true;
        rust-analyzer.initialization_options = {
          snippets = {
            "Arc::new" = {
              "postfix" = "arc";
              "body" = ["Arc::new(\${receiver})"];
              "requires" = "std::sync::Arc";
              "scope" = "expr";
            };
            "Some" = {
              "postfix" = "some";
              "body" = ["Some(\${receiver})"];
              "scope" = "expr";
            };
            "Ok" = {
              "postfix" = "ok";
              "body" = ["Ok(\${receiver})"];
              "scope" = "expr";
            };
          };
          rust.analyzerTargetDir = true;
          check.command = "clippy";
        };
      };
    };

    userKeymaps = [
      # insert mode
      {
        context = "Editor && vim_mode == insert && !menu";
        bindings = {
        };
      }
      {
        context = "vim_mode != insert";
        bindings = {
          # "tab" = "tab_switcher::Toggle";
          # "shift-tab" = ["tab_switcher::Toggle" { select_last = true; }];
        };
      }
      # visual / normal mode
      {
        bindings = {
          "ctrl-n" = "project_panel::ToggleFocus";
        };
        context = "(vim_mode != insert || vim_mode == normal) && vim_mode != waiting && !menu";
      }
      {
        context = "Editor && vim_mode != insert && vim_mode != waiting && !menu";
        bindings = {
          "space /" = ["editor::ToggleComments"  { advance_downwards = false; }];
        };
      }
      {
        context = "not_editing && ProjectPanel";
        bindings."ctrl-n" = "workspace::ToggleLeftDock";
      }
    ];

    extensions = [ "nix" "deno" ];
  };
}
