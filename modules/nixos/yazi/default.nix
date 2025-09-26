{ pkgs, config, lib, ... }: let
  t = by: args:
    if lib.isString args then t by {} args
    else run: map (x: { inherit run; "${by}" = x; } // args);
  run = t "name";
  run'= t "mime";
  cfg = config.programs.yazi;
in {
  programs.yazi = {
    enable = true;
    initLua = ./init.lua;
    settings.yazi = {
      opener.add-sub = [
        {
          run  = /* sh */ ''echo sub-add "'$0'" | socat - /tmp/mpv-playlist.sock'';
          desc = "Add sub to MPV";
          for = "unix";
        }
      ];

      opener.play = [
        { run = ''mpv "$@"''; orphan = true; for = "unix"; }
      ];

      opener.edit = [
        {
          for = "unix";
          block = true;
          desc = "Neovim";
          run = let
            script = pkgs.writeScript "nvim.sh" "#!${lib.getExe pkgs.bash}\n${builtins.readFile ./nvim.sh}";
          in ''${script} "$@"'';
        }
        { for = "unix"; run = ''${lib.getExe pkgs.nomacs} "$@"''; orphan = true; desc = "Nomacs"; }
      ];

      opener.extract = [
        { run = "ouch d -y %*"; desc = "Extract here with ouch"; for = "windows"; }
        { run = ''ouch d -y "$@"''; desc = "Extract here with ouch"; for = "unix"; }
      ];

      open.prepend_rules = [
        { name = "*Video{s,}/"; use = [ "play" ]; }
        { mime = "image/*"; use = [ "nomacs" ]; }
        {
          name = "*.{ass,srt,ssa,sty,sup,vtt}";
          use  = [ "add-sub" "edit" ];
        }
      ];
      plugin.prepend_previewers = run "duckdb" [
        "*.csv" "*.tsv" "*.parquet" "*.xlsx" "*.db" "*.duckdb"
      ] ++ run' "ouch" [
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
      ] ++ [ 
        { name = "*.md"; run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"''; }
      ];

      plugin.prepend_preloaders = 
        run { multi = false; } "duckdb" [ "*.csv" "*.tsv" "*.parquet" "*.xlsx" ];
    };

    settings.keymap.mgr.prepend_keymap = [
      { on = "q"; run = "plugin confirm-quit"; }
      { on = "t"; run = "plugin smart-tab"; desc = "Create a tab and enter the hovered directory"; }
      { on = "l"; run = "plugin smart-enter"; desc = "Enter the child directory, or open the file"; }
      { on = "p"; run = "plugin smart-paste"; desc = "Paste into the hovered directory or CWD"; }
      { on = "f"; run  = "plugin jump-to-char"; desc = "Jump to char"; }
      { on = "F"; run = "plugin smart-filter"; desc = "Smart filter"; }
      { on = "H"; run = "plugin duckdb -1"; desc = "Scroll one column to the left"; }
      { on = "L"; run = "plugin duckdb +1"; desc = "Scroll one column to the right"; }
      { on = ["C"]; run = "plugin ouch"; desc = "Compress with ouch"; }
      { on = ["g" "o"]; run = "plugin duckdb -open"; desc = "open with duckdb"; }
      { on = ["g" "u"]; run = "plugin duckdb -ui"; desc = "open with duckdb ui"; }
      { on = ["g" "c"]; run = "plugin vcs-files"; desc = "Show Git file changes"; }
      { on = ["c" "m"]; run = "plugin chmod"; desc = "Chmod on selected files"; }
      { on = ["g" "l" "g" ]; run = "plugin lazygit"; desc = "run lazygit"; }
      { on = "<C-d>"; run = "plugin diff"; desc = "Diff the selected with the hovered file"; }
      { on = [ "g" "t" ]; run = "plugin recycle-bin open"; desc = "Go to Trash"; }
      { on = [ "R" "o" ]; run = "plugin recycle-bin open"; desc = "Open Trash"; }
      { on = [ "R" "e" ]; run = "plugin recycle-bin empty"; desc = "Empty Trash"; }
      { on = [ "R" "d" ]; run = "plugin recycle-bin delete"; desc = "Delete from Trash"; }
      { on = [ "R" "D" ]; run = "plugin recycle-bin emptyDays"; desc = "Empty by days deleted"; }
      { on = [ "R" "r" ]; run = "plugin recycle-bin restore"; desc = "Restore from Trash"; }
      { on = [ "u" ]; run = "plugin restore"; desc = "Restore last deleted files/folders"; }
      { on = [ "U" ]; run = "plugin restore -- --interactive"; desc = "Restore deleted files/folders (Interactive)"; }
    ] ++ lib.optionals (cfg.plugins ? zoom) [
      { on = "+"; run = "plugin zoom 1"; desc = "Zoom in hovered file"; }
      { on = "-"; run = "plugin zoom -1"; desc = "Zoom out hovered file"; }
    ] ++ lib.optionals (cfg.plugins ? bunny) [
      { on = ";"; run = "plugin bunny"; desc = "Start bunny.yazi"; }
      { on = "'"; run = "plugin bunny fuzzy"; desc = "Start bunny.yazi fuzzy search"; }
    ];

    plugins = let
      toPlugin = arr: builtins.listToAttrs (map (name: {
        inherit name;
        value = pkgs.yaziPlugins.${name};
      }) arr);

      fetchPlugin = path: let
        lists = lib.filterAttrs (k: v: v == "directory") (builtins.readDir path);
      in lib.mapAttrs' (k: _: lib.nameValuePair (lib.removeSuffix ".yazi" k) "${path}/${k}") lists;
    in toPlugin ([
      "diff"
      "smart-enter"
      "smart-paste"
      "smart-filter"
      "lazygit"
      "duckdb"
      "ouch"
      "chmod"
      "jump-to-char"
      "piper"
      "full-border"
      "vcs-files"
      "restore"
      "recycle-bin"
    ] ++ lib.optionals (pkgs.yaziPlugins ? bunny) [
      "bunny"
    ] ++ lib.optionals (pkgs.yaziPlugins ? zoom) [
      "zoom"
    ]) // fetchPlugin ./plugins;
  };

  imports = [
  {
    home-manager.sharedModules = [
    {
      programs.mpv.config = {
        input-ipc-server = "/tmp/mpv-playlist.sock";
      };
    }
    ];
  }
  ];

  environment.systemPackages = with pkgs; [
    ouch
    duckdb
    glow
    trash-cli
  ];
}
