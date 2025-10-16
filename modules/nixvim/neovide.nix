{ config, lib, ... }:
{
  config = lib.mkMerge [
    {
      extraConfigLuaPre = ''
        if vim.g.neovide then
            vim.keymap.set({ "n", "v", "i" }, "<C-=>", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.02<CR>")
            vim.keymap.set({ "n", "v", "i" }, "<C-->", ":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.02<CR>")
            vim.keymap.set({ "n", "v", "i" }, "<C-0>", ":lua vim.g.neovide_scale_factor = 1<CR>")
        end
      '';
      opts = {
        guifont = "JetBrainsMono Nerd Font:h14:b";
      };
      globals = {
        neovide_cursor_vfx_mode = [
          "railgun"
          # "sonicboom"
        ];
        neovide_cursor_antialiasing = false;
        # neovide_fullscreen = true;
        neovide_no_idle = false;
      };
    }
    (lib.mkIf config.plugins.neoscroll.enable {
      plugins.neoscroll.settings.performance_mode = true;
      plugins.neoscroll.luaConfig.content = lib.mkMerge [
        (lib.mkBefore "if not vim.g.neovide then")
        (lib.mkAfter  "end")
      ];
    })
    (lib.mkIf config.plugins.smear-cursor.enable {
      plugins.smear-cursor.luaConfig.content = lib.mkMerge [
        (lib.mkBefore /* lua */ "if not vim.g.neovide then")
        (lib.mkAfter /* lua */ ''
          else
            vim.api.nvim_create_user_command("SmearCursorToggle", function()
              -- TODO using state
              if vim.g.neovide_cursor_animation_length == 0 then
                vim.g.neovide_cursor_animation_length = ${lib.nixvim.toLuaObject config.globals.neovide_cursor_animation_length or 0.15}
                vim.g.neovide_cursor_short_animation_length = ${lib.nixvim.toLuaObject config.globals.neovide_cursor_short_animation_length or null}
                vim.g.neovide_cursor_vfx_mode = ${lib.nixvim.toLuaObject config.globals.neovide_cursor_vfx_mode or ""}
                vim.g.neovide_cursor_trail_size = ${lib.nixvim.toLuaObject config.globals.neovide_cursor_trail_size or 1}
              else
                vim.g.neovide_cursor_animation_length = 0
                vim.g.neovide_cursor_short_animation_length = 0
                vim.g.neovide_cursor_vfx_mode = ""
                vim.g.neovide_cursor_trail_size = 0
              end
            end, {})
          end
        '')
      ];
    })
  ];
}
