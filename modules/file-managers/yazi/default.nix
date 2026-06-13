{ lib, ... }: let
  t = by: args:
    if lib.isString args then t by {} args
    else run: map (x: { inherit run; "${by}" = x; } // args);
  run = t "url";
  run'= t "mime";
in {
  fmx.file-managers.yazi = {
    includes = [ <fmx/file-managers/yazi/_> ];
    # TODO: cross config
    nixos = { pkgs, ... }:
    {
      programs.yazi = {
        enable = true;

        # TODO: can append the initLua
        initLua = ./init.lua;

        settings.yazi = {
          opener.nomacs = [
            { for = "unix"; run = ''${lib.getExe pkgs.nomacs} "$@"''; orphan = true; desc = "Nomacs"; }
          ];
          open.prepend_rules = [
            { mime = "image/*"; use = [ "nomacs" ]; }
          ];
        };

        settings.keymap.mgr.prepend_keymap = [
          { on = "l"; run = "plugin smart-enter"; desc = "Enter the child directory, or open the file"; }
          { on = "p"; run = "plugin smart-paste"; desc = "Paste into the hovered directory or CWD"; }
          { on = "F"; run = "plugin smart-filter"; desc = "Smart filter"; }

          { on = "f"; run  = "plugin jump-to-char"; desc = "Jump to char"; }
          { on = ["c" "m"]; run = "plugin chmod"; desc = "Chmod on selected files"; }
          { on = "<C-d>"; run = "plugin diff"; desc = "Diff the selected with the hovered file"; }
          { on = "+"; run = "plugin zoom 1"; desc = "Zoom in hovered file"; }
          { on = "-"; run = "plugin zoom -1"; desc = "Zoom out hovered file"; }
        ];

        # TODO: use latest src
        plugins = {
          smart-enter = pkgs.yaziPlugins.smart-enter;
          smart-paste = pkgs.yaziPlugins.smart-paste;
          smart-filter= pkgs.yaziPlugins.smart-filter;
          jump-to-char= pkgs.yaziPlugins.jump-to-char;
          chmod       = pkgs.yaziPlugins.chmod;
          diff        = pkgs.yaziPlugins.diff;
          full-border = pkgs.yaziPlugins.full-border;
          zoom        = pkgs.yaziPlugins.mkYaziPlugin {
            pname = "zoom.yazi";
            version= pkgs.yaziPlugins.chmod.version;
            src = pkgs.yaziPlugins.chmod.src;
          };
        };
      };
    };

    ouch.nixos = { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.ouch
      ];
      programs.yazi.plugins.ouch = pkgs.yaziPlugins.ouch;
      programs.yazi = {
        settings.keymap.mgr.prepend_keymap = [
          { on = ["C"]; run = "plugin ouch"; desc = "Compress with ouch"; }
        ];
        settings.yazi = {
          opener.extract = [
            { run = "ouch d -y %*"; desc = "Extract here with ouch"; for = "windows"; }
            { run = ''ouch d -y "$@"''; desc = "Extract here with ouch"; for = "unix"; }
          ];

          plugin.prepend_previewers = run' "ouch" [
            # Archive previewer
            "application/*zip"
            "application/zip"
            "application/rar"
            "application/x-tar"
            "application/x-bzip2"
            "application/x-7z-compressed"
            "application/x-rar"
            "application/vnd.rar"
            "application/x-xz"
            "application/xz"
            "application/x-zstd"
            "application/zstd"
            "application/java-archive"
          ];
        };
      };
    };

    piper.nixos = { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.glow
      ];
      programs.yazi.plugins.piper = pkgs.yaziPlugins.piper;

      programs.yazi.settings.yazi.plugin.prepend_previewers = [ 
        { url = "*.md"; run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"''; }
      ];
    };

    duckdb.nixos = { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.duckdb
      ];
      programs.yazi.plugins.duckdb = pkgs.yaziPlugins.duckdb;
      programs.yazi = {
        settings.yazi.plugin.prepend_previewers = run "duckdb" [
          "*.csv" "*.tsv" "*.parquet" "*.xlsx" "*.db" "*.duckdb"
        ];

        settings.yazi.plugin.prepend_preloaders = 
          run { multi = false; } "duckdb" [ "*.csv" "*.tsv" "*.parquet" "*.xlsx" ];

        settings.keymap.mgr.prepend_keymap = [
          { on = "H"; run = "plugin duckdb -1"; desc = "Scroll one column to the left"; }
          { on = "L"; run = "plugin duckdb +1"; desc = "Scroll one column to the right"; }
          
          { on = ["g" "o"]; run = "plugin duckdb -open"; desc = "open with duckdb"; }
          { on = ["g" "u"]; run = "plugin duckdb -ui"; desc = "open with duckdb ui"; }
        ];
      };
    };

    mpv.includes = [
      { homeManager.programs.mpv.config.input-ipc-server = "/tmp/mpv-playlist.sock"; }
    ];
    mpv.nixos.programs.yazi.settings.yazi = {
      opener.add-sub = [{
        run  = /* sh */ ''echo sub-add "'$0'" | socat - /tmp/mpv-playlist.sock'';
        desc = "Add sub to MPV";
        for = "unix";
      }];

      opener.play = [
        { run = ''mpv "$@"''; orphan = true; for = "unix"; }
      ];

      open.prepend_rules = [
        { url = "*Video{s,}"; use = [ "play" ]; }
        { url = "*.{ass,srt,ssa,sty,sup,vtt}";
          use  = [ "add-sub" "edit" ];
        }
      ];
    };

    neovim.nixos = { pkgs, ... }:
    {
      programs.yazi.settings.yazi.opener.edit = [{
        for = "unix";
        block = true;
        desc = "Neovim";
        run = let
          script = pkgs.writeScript "nvim.sh" "#!${lib.getExe pkgs.bash}\n${builtins.readFile ./nvim.sh}";
        in ''${script} "$@"'';
      }];
    };

    trash.nixos = { pkgs, ... }:
    {
      programs.yazi = {
        settings.keymap.mgr.prepend_keymap = [
          { on = [ "g" "t" ]; run = "plugin recycle-bin open"; desc = "Go to Trash"; }
          { on = [ "R" "o" ]; run = "plugin recycle-bin open"; desc = "Open Trash"; }
          { on = [ "R" "e" ]; run = "plugin recycle-bin empty"; desc = "Empty Trash"; }
          { on = [ "R" "d" ]; run = "plugin recycle-bin delete"; desc = "Delete from Trash"; }
          { on = [ "R" "D" ]; run = "plugin recycle-bin emptyDays"; desc = "Empty by days deleted"; }
          { on = [ "R" "r" ]; run = "plugin recycle-bin restore"; desc = "Restore from Trash"; }
          { on = [ "u" ]; run = "plugin restore"; desc = "Restore last deleted files/folders"; }
          { on = [ "U" ]; run = "plugin restore -- --interactive"; desc = "Restore deleted files/folders (Interactive)"; }
        ];

        plugins.restore = pkgs.yaziPlugins.restore;
        plugins.recycle-bin = pkgs.yaziPlugins.recycle-bin;
      };

      environment.systemPackages = [
        pkgs.trash-cli
      ];
    };
  };
}
