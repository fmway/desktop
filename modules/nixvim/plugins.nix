# TODO add options `plugins.xxx`
{ internal, _file, lib, ... }: let
  inherit (lib.nixvim) toKeymaps toLuaObject mkLuaFn mkRawFn;
in { pkgs, ... }:
{
  inherit _file;
  opts.relativenumber = true;
  nvchad.config.colorify.mode = "bg";
  extraPlugins = with pkgs.vimPlugins; [
    nvzone-menu
    nvzone-volt
    nvzone-minty
    nvzone-typr
    vim-startuptime
    # vim-markdown-composer
    # kitty-scrollback-nvim
    (pkgs.vimUtils.buildVimPlugin {
      pname = "showkeys";
      version = "1.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "nvzone";
        repo = "showkeys";
        rev = "8daf5abb5fece0c9e1fa2c5679aaf226a80f5c38";
        hash = "sha256-0ZONzsCWJzzCYnZpr/O8t9Rmkc4A5+i7X7bkjEk5xmc=";
      };
    })
    (pkgs.vimUtils.buildVimPlugin {
      pname = "timerly";
      version = "unstable-2025-04-16";

      src = pkgs.fetchFromGitHub {
        owner = "nvzone";
        repo = "timerly";
        rev = "17299a4d332c483ce09052fe8478b41b992f2594";
        hash = "sha256-olax+zPVIOYEjK7n8cVHS6Ss3o2KdnsbcK2kZVHi3lk=";
      };

      dependencies = [
        nvzone-volt
      ];

      meta = {
        description = "Beautiful countdown timer plugin for Neovim";
        homepage = "https://github.com/nvzone/timerly";
        license = lib.licenses.gpl3Only;
        maintainers = with lib.maintainers; [ ];
        mainProgram = "timerly";
        platforms = lib.platforms.all;
      };
    })
  ];
  extraConfigLua = ''
    vim.g.startuptime_tries = 10
  '';

  plugins.lz-n.plugins = [
    # (let
    #   opts = {};
    # in {
    #   __unkeyed-1 = "kitty-scrollback-nvim";
    #   cmd = [ "KittyScrollbackGenerateKittens" "KittyScrollbackCheckHealth" "KittyScrollbackGenerateCommandLineEditing" ];
    #   event = [ "User KittyScrollbackLaunch" ];
    #   after.__raw = ''
    #     function()
    #       require("kitty-scrollback").setup(${lib.optionalString (opts != {}) (toLuaObject opts)})
    #     end
    #   '';
    # })
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
        {
          __unkeyed-1 = "<leader>st";
          __unkeyed-2 = mkRawFn ''
            require("showkeys").toggle()
          '';
        }
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
        {
          __unkeyed-1 = "<leader>sw";
          __unkeyed-2 = mkRawFn ''
            require("timerly").toggle()
          '';
        }
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
        {
          __unkeyed-1 = "<leader>ty";
          __unkeyed-2 = mkRawFn ''
            require("typr").open()
          '';
        }
        {
          __unkeyed-1 = "<leader>td";
          __unkeyed-2 = mkRawFn ''
            require("typr.stats").open()
          '';
        }
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
      {
        __unkeyed-1 = "<leader>lg";
        __unkeyed-2 = mkRawFn ''
          _lazygit_toggle()
        '';
        desc = "Lazygit Toggle";
      }
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
  #     (toKeymaps "<leader>u" "<CMD>Telescope undo<CR>" {})
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
        (toKeymaps "<leader>tsc" "<cmd>SmearCursorToggle<cr>" { desc = "Toggle Animation Cursor"; })
      ];
    };
  };
 

  plugins.bufferline = {
    enable = true;
    lazyLoad.enable = true;
    lazyLoad.settings = {
      keys = map (x: let
        i = toString x;
        to = if x == 0 then "10" else i;
      in toKeymaps
        "g${i}"
        ''<CMD>lua require("bufferline").go_to_buffer(${to}, true)<CR>''
        { desc = "Go to tab ${to}"; }
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
