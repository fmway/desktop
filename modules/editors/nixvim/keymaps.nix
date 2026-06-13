{ lib, ... }: let
  inherit (lib.nixvim) keymap mkRawFn;
in {
  fmx.editors.nixvim.keymaps.nixvim.keymaps = [
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
      require("nvchad.themes").open { style = "compact", border = true, }
    '') "Show themes menu" {})
    (keymap.n "<leader>lx" "<CMD>lsp disable<Enter>" "Stop/Disable LSP" {})
    (keymap.n "<leader>ls" "<CMD>lsp enable<Enter>" "Start/Enable LSP" {})
    (keymap.n "<leader>lr" "<CMD>lsp restart<Enter>" "Restart LSP" {})
  ];
}
