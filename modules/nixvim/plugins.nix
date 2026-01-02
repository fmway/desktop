# TODO add options `plugins.xxx`
{ internal, _file, lib, ... }: let
  inherit (lib.nixvim) toLuaObject mkLuaFn mkRawFn mkRaw keymap';
in { pkgs, ... }:
{
  # Depends for git-dev plugins
  globals.git_username.__raw = "get_git_username()";
  inherit _file;
  opts.relativenumber = true;
  nvchad.config.colorify.mode = "bg";
  extraPlugins = with pkgs.vimPlugins; [
    nvzone-menu
    nvzone-volt
    nvzone-minty
    nvzone-typr
    vim-startuptime
    showkeys
    timerly
    # vim-markdown-composer
    # kitty-scrollback-nvim
    (pkgs.vimUtils.buildVimPlugin rec {
      pname = "git-dev-nvim";
      version = "0.7.1";
      src = pkgs.fetchFromGitHub {
        owner = "moyiz";
        repo = "git-dev.nvim";
        rev = version;
        hash = "sha256-W+42RmHv9wfGS42klk+y3TCmjB4lmH8Zl+RiwQtNcok=";
      };

      meta = {
        description = "Open remote git repositories in the comfort of Neovim";
        homepage = "https://github.com/moyiz/git-dev.nvim";
        license = lib.licenses.bsd3;
      };
    })
  ];
  extraConfigLua = ''
    vim.g.startuptime_tries = 10
  '';

  extraConfigLuaPre = lib.mkBefore /* lua */ ''
    function get_git_username()
      local username = vim.fn.system("git config user.name"):gsub("\n", "")
      if username == "" then
        return vim.env.USERNAME
      end
      return username
    end
  '';

  plugins.lz-n.plugins = [
    (let
      opts = {
        timeout = 2;
        maxkeys = 4;
        show_count = true;
        position = "top-right"; # bottom-left, bottom-right, bottom-center, top-left, top-right, top-center
      };
    in {
      __unkeyed-1 = "showkeys";
      # event = [ "BufEnter" ];
      cmd = [ "ShowkeysToggle" ];
      after = mkRawFn ''
        require("showkeys").setup(${toLuaObject opts})
      '';
      keys = [
        (keymap' "<leader>st" (mkRawFn ''require("showkeys").toggle()'') "Toggle ShowKeys" {})
      ];
    })
    (let
      opts = {};
    in {
      __unkeyed-1 = "timerly";
      cmd = [ "TimerlyToggle" ];
      after = mkRawFn ''
        require("timerly").setup(${toLuaObject opts})
      '';
      keys = [
        (keymap' "<leader>sw" (mkRawFn ''require("timerly").toggle()'') "Toggle Timerly" {})
      ];
    })
    (let
      opts = {};
    in {
      __unkeyed-1 = "typr";
      cmd = [ "Typr" "TyprStats" ];
      after = mkRawFn ''
        require("typr").setup(${toLuaObject opts})
      '';
      keys = [
        (keymap' "<leader>ty" (mkRawFn ''require("typr").open()'') "Open Typr" {})
        (keymap' "<leader>td" (mkRawFn ''require("typr.stats").open()'') "Show Typr Stats" {})
      ];
    })
    (let
      opts = {
        read_only = false;
        verbose = true;
        git.default_org.__raw = "vim.g.git_username";
        xdg_handler.enabled = true;
        opener = mkRawFn [ "dir" "_" "selected_path" ] ''
          vim.cmd("NvimTreeOpen " .. vim.fn.fnameescape(dir))
          if selected_path then
            vim.cmd("edit " .. selected_path)
          end
        '';
      };
    in {
      __unkeyed-1 = "git-dev.nvim";
      cmd = [ "GitDevClean" "GitDevCleanAll" "GitDevCloseBuffers" "GitDevOpen" "GitDevRecents" "GitDevToggleUI" "GitDevXDGHandle" ];
      after = mkRawFn ''
        require("git-dev").setup {${toLuaObject opts}}
      '';
      keys = [
        (keymap' "<leader>go" (mkRawFn ''
            local repo = vim.fn.input "Repository: "
            if repo ~= "" then
              require("git-dev").open(repo)
            end
          '')
          "[O]pen a remote git repository"
          {}
        )
        (keymap'.n "<leader>gc" (mkRawFn ''require("git-dev").close_buffers()'') "[C]lose buffers of current repository" {})
        (keymap'.n "<leader>gC" (mkRawFn ''require("git-dev").clean()'') "[C]lean current repository" {})
      ];
    })
  ];
  nvchad.config.base46.theme = "starlight";
  nvchad.config.base46.second_theme = "gruvbox_light";

  plugins.typst-preview = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.ft = "typst";
  };

  plugins.toggleterm = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "User FilePost";
    lazyLoad.settings.cmd = [
      "ToggleTerm"
      "ToggleTermToggleAll"
      "TermExec"
      "TermNew"
      "TermSelect"
      "ToggleTermSendVisualLines"
      "ToggleTermSendVisualSelection"
      "ToggleTermSendCurrentLine"
      "ToggleTermSetName"
    ];
    lazyLoad.settings.keys = [
      (keymap' "<leader>lg" (mkRawFn "_lazygit_toggle()") "Lazygit Toggle" {})
    ];
    settings = {
      direction = "float";
      float_opts.border = "double";
      on_open = mkLuaFn [ "term" ] ''
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
      '';
      on_close = mkLuaFn [ "term" ] ''
        vim.cmd("startinsert!")
      '';
    };
    luaConfig.post = ''
      local Terminal  = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

      function _lazygit_toggle()
        lazygit:toggle()
      end
    '';
  };
  plugins.mini = {
    enable = true;
    # lazyLoad.enable = true;
    # lazyLoad.settings.event = "BufEnter";
    modules = {
      surround = {};
      align = {};
      icons = {};
    };
  };

  plugins.notify = {
    enable = true;
    settings = {
      background_colour = "#000000";
      max_width = 40;
      # max_height = 20;
      render.__raw = ''"wrapped-default"'';
      level = "debug";
      stages = "fade";
      timeout = 1500;
    };
  };
  plugins.telescope.extensions.undo.enable = true;
  # plugins.telescope.lazyLoad.settings = {
  #   keys = [
  #     (keymap "<leader>u" "<CMD>Telescope undo<CR>" {})
  #   ];
  # };
  plugins.telescope.keymaps = {
    "<leader>u" = {
      action = "undo";
      options.desc = "Telescope undo";
    };
  };
  plugins.telescope.enabledExtensions = [
    "notify"
    "git_dev"
  ];

  plugins.neoscroll = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = "BufRead";
  };

  plugins.smear-cursor = {
    enable = true;
    settings = {
      stiffness = 0.5;
      trailing_stiffness = 0.49;
    };
    lazyLoad.enable = true;
    lazyLoad.settings = {
      event = "BufEnter";
      cmd = ["SmearCursorToggle"];
      keys = [
        (keymap' "<leader>tsc" "<cmd>SmearCursorToggle<cr>" "Toggle Animation Cursor" {})
      ];
    };
    # Disable smear-cursor in startup
    luaConfig.post = ''require("smear_cursor").enabled = false'';
  };
 

  plugins.bufferline = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings = {
      keys = map (x: let
        i = toString x;
        to = if x == 0 then "10" else i;
      in keymap' "g${i}" (mkRawFn ''require("bufferline").go_to_buffer(${to}, true)'') "Go to tab ${to}" {}
      ) (lib.range 0 9);
    };
  };

  plugins.hlchunk = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings.event = [ "BufReadPre" "BufNewFile" ];
    settings = {
      chunk.enable = true;
      line_num.enable = true;
    };
  };

  extraFiles."ftplugin/typr.lua".text = /* lua */ ''
    -- 
    vim.b.completion = false;
  '';
}
