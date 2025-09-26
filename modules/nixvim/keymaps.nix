{ internal, _file, lib, ... }: let
  inherit (lib.nixvim) toKeymaps' mkRawFn;
in { ... }:
{
  inherit _file;
  keymaps = [
    (toKeymaps' "<" "<gv" { noremap = true; mode = "v"; })
    (toKeymaps' ">" ">gv" { noremap = true; mode = "v"; })
    (toKeymaps' "p" "p`[v`]" { noremap = true; mode = ["n" "v"]; })
    (toKeymaps' "P" "P`[v`]" { noremap = true; mode = ["n" "v"]; })
    (toKeymaps' "C-t" (mkRawFn ''require("menu").open("default")'') {})
    (toKeymaps' "<RightMouse>" (mkRawFn ''
      --
      vim.cmd.exec '"normal! \\<RightMouse>"'

      local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
      require("menu").open(options, { mouse = true })
    '') {})
    (toKeymaps' ";" ":" { desc = "CMD enter command mode"; })
    (toKeymaps' "<C-n>" "<cmd>NvimTreeToggle <CR><ESC>" { mode = "i"; desc = "Toggle NvimTree"; })
    (toKeymaps' "<A-t>" (mkRawFn ''
      require("nvchad.themes").open { style = "compat", border = true, }
    '') { desc = "Show themes menu"; })
    
    (toKeymaps' "<leader>db" "<CMD>DBUIToggle<CR>" {})
  ];
}
