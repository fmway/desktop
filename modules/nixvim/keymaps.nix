{ internal, _file, lib, ... }: let
  inherit (lib.nixvim) keymap mkRawFn;
in { ... }:
{
  inherit _file;
  keymaps = [
    (keymap.v   "<" "<gv" { noremap = true; })
    (keymap.v   ">" ">gv" { noremap = true; })
    (keymap.n.v "p" "p`[v`]" { noremap = true; })
    (keymap.n.v "P" "P`[v`]" { noremap = true; })
    (keymap.n   "C-t" (mkRawFn ''require("menu").open("default")'') {})
    (keymap.n   "<RightMouse>" (mkRawFn ''
      --
      vim.cmd.exec '"normal! \\<RightMouse>"'

      local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
      require("menu").open(options, { mouse = true })
    '') {})
    (keymap.n ";" ":" "CMD enter command mode" {})
    (keymap.i "<C-n>" "<cmd>NvimTreeToggle <CR><ESC>" "Toggle NvimTree" {})
    (keymap.n "<A-t>" (mkRawFn ''
      require("nvchad.themes").open { style = "compat", border = true, }
    '') "Show themes menu" {})
    (keymap.n "<leader>lx" "<CMD>LspStop<Enter>" "Stop LSP" {})
    (keymap.n "<leader>ls" "<CMD>LspStart<Enter>" "Start LSP" {})
    (keymap.n "<leader>lr" "<CMD>LspRestart<Enter>" "Restart LSP" {})
  ];
}
