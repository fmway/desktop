{ internal, _file, lib, ... }:
{ config, ... }:
{
  inherit _file;
  plugins.lsp.luaConfig.pre = lib.mkMerge [
    (let
      final = lib.nixvim.toLuaObject (removeAttrs config.plugins.lsp.servers.nixd.settings [ "__raw" ]);
    in lib.nixvim.mkLuaFn' "myNixd" /* lua */ ''
      local NIXD_PATH, result = vim.env.NIXD_PATH, vim.tbl_deep_extend("force", { nixpkgs = { expr = "import <nixpkgs> {}", }, options = {}, }, ${final})
      local NIXD_PATH, result = vim.env.NIXD_PATH, { nixpkgs = { expr = "import <nixpkgs> {}", }, options = {}, }

      if NIXD_PATH == nil or NIXD_PATH == "" then return result end
      NIXD_PATH = NIXD_PATH .. ":" -- fix for single path

      -- format <name>=<flake>#<outputs>....
      -- FIXME handle extract for flake:<xxx> github:<xxx>, ...
      NIXD_PATH:gsub("[^:]+", function (e)
        if e == "" then
          return
        end
        local tmp, name, source, path, res = {}, nil, nil , nil, nil
        for i in string.gmatch(e, "[^=]+") do table.insert(tmp, i) end
        name = tmp[1]
        for i in string.gmatch(tmp[2], "[^#]+") do table.insert(tmp, i) end
        source, path = tmp[3], tmp[4]
        local flake = (string.match(source, "^/nix/store/") == nil) and '"'..source..'"' or "builtins.toPath "..source
        res = { expr = "(builtins.getFlake ("..flake.."))."..path }
        if name == "pkgs" then
          result["nixpkgs"] = res
        else
          result["options"][name] = res
        end
      end)
      return result
    '')
  ];
  plugins.lsp.servers = {
    rust_analyzer.enable = true;
    rust_analyzer.filetypes = [ "rust" ];
    rust_analyzer.cmd = [ "rust-analyzer" ];
    rust_analyzer.installRustc = false;
    rust_analyzer.installCargo = false;
    rust_analyzer.installRustfmt = false;
    rust_analyzer.settings = {
      diagnostics.enable = true;
    };
    typos_lsp.enable = true;
    typos_lsp.cmd = ["typos-lsp"];
    zls.enable = true;
    zls.cmd = ["zls"];
    zls.rootMarkers = [ "zls.json" "build.zig" ".git" ];
    zls.filetypes = [ "zig" "zir" ];
    # volar.cmd = [""];
    clangd.enable = true;
    clangd.cmd = ["clangd"];
    clangd.rootMarkers = [ ".clangd" ".clang-tidy" ".clang-format" "compile_commands.json" "compile_flags.txt" "configure.ac" ".git" ];
    clangd.filetypes = [ "c" "cpp" "objc" "objcpp" "cuda" "proto" ];
    jsonls.enable = true;
    jsonls.cmd = ["vscode-json-language-server" "--stdio"];
    jsonls.rootMarkers = [ ".git" ];
    jsonls.filetypes = [ "json" "jsonc" ];
    yamlls.enable = true;
    yamlls.cmd = ["yaml-language-server" "--stdio"];
    yamlls.rootMarkers = [ ".git" ];
    yamlls.filetypes = [ "yml" "yaml" "yaml.docker-compose" "yaml.gitlab" ];
    denols.enable = true;
    denols.cmd = ["deno" "lsp"];
    denols.filetypes = [ "javascript" "javascriptreact" "javascript.jsx" "typescript" "typescriptreact" "typescript.tsx" ];
    denols.rootMarkers = [ "deno.json" "deno.jsonc" ];
    ts_ls.cmd = ["typescript-language-server" "--stdio"];
    ts_ls.filetypes = [ "javascript" "javascriptreact" "javascript.jsx" "typescript" "typescriptreact" "typescript.tsx" ];
    ts_ls.rootMarkers = [ "package.json" ];
    nixd.settings = {
      __raw = "myNixd()";
      diagnostic.suppress = [ "sema-escaping-with" ];
    };

    tinymist.enable = true;
    tinymist.cmd = ["tinymist"];
    tinymist.rootMarkers = [ ".git" ];
    tinymist.filetypes = [ "typst" ];
    tinymist.settings = {
      formatterMode = "typstyle";
      rootPath.__raw = ''vim.env["TYPST_ROOT"] or nil'';
    };
    tinymist.onAttach.function = ''
      vim.keymap.set("n", "<leader>tp", function()
        client:exec_cmd({
          title = "pin",
          command = "tinymist.pinMain",
          arguments = { vim.api.nvim_buf_get_name(0) },
        }, { bufnr = bufnr })
      end, { desc = "[T]inymist [P]in", noremap = true })

      vim.keymap.set("n", "<leader>tu", function()
        client:exec_cmd({
          title = "unpin",
          command = "tinymist.pinMain",
          arguments = { vim.v.null },
        }, { bufnr = bufnr })
      end, { desc = "[T]inymist [U]npin", noremap = true })
    '';
    prismals = {
      enable = true;
      # TODO
      package = null;
      cmd = [ "prisma-language-server" "--stdio" ];
      filetypes = [ "prisma" ];
      rootMarkers = [ ".git" "package.json" "deno.json" "tsconfig.json" "deno.jsonc" ];
    };
  
    nil_ls = {
      enable = true;
      settings = {
        nix.flake.autoEvalInputs = false;
        nix.flake.maxMemoryMB = 2;
        # nix.flake.autoArchive = true;
      };
    };

    html.enable = true;
    html.filetypes = [ "html" "blade" "templ" ];
    html.extraOptions = {
      configurationSection = [ "html" "css" "javascript" ];
      embeddedLanguages.css = true;
      embeddedLanguages.javascript = true;
      provideFormatter = true;
    };
  };
}
